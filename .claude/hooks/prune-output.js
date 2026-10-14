#!/usr/bin/env node
// PostToolUse hook (Bash): shrink long successful command output before the model sees it.
// Failed commands never reach PostToolUse, so error output is always kept whole.
// Strips ANSI/progress noise, folds passing-test lines and dot runs, collapses repeats,
// then keeps head + tail + error/summary lines. Original goes to a temp file the model can Grep.
// Tune: PRUNE_MIN_LINES (default 80), PRUNE_HEAD (25), PRUNE_TAIL (40). Disable: PRUNE_OUTPUT=off.
const fs = require('fs');
const os = require('os');
const path = require('path');

if (process.env.PRUNE_OUTPUT === 'off') process.exit(0);

const num = (k, d) => Number(process.env[k]) || d;
const MIN_LINES = num('PRUNE_MIN_LINES', 80);
const MIN_CHARS = 6000;
const HEAD = num('PRUNE_HEAD', 25);
const TAIL = num('PRUNE_TAIL', 40);
const MAX_KEPT_MIDDLE = 60;

// Commands whose output IS the content the user asked to see
const CONTENT_CMD = /\b(cat|head|tail|sed|awk|type|git\s+(diff|show|log|blame))\b/;
const PASS_NOISE = /^\s*(✓|✔|√|PASS\b|ok\s+\d+)/;
const DOT_NOISE = /^\S*\s*[.·s]{3,}\s*(\[\s*\d+%\])?\s*$/;
const IMPORTANT = new RegExp(
  [
    '\\b(error|errors|fail|failed|failure|failures|exception|traceback|warn|warning|fatal|panic|denied|assert\\w*)\\b',
    '✗|✖|×|^E\\s',
    '\\b\\d+\\s+(passed|failed|skipped|tests?|errors?)\\b',
    '^\\s*(Tests?|Test Suites?|Snapshots?|Time|Ran)\\b',
    '\\b(summary|total|done|finished|completed|build)\\b',
  ].join('|'),
  'i',
);
const SECRETISH = /(token|secret|password|passwd|api[_-]?key|authorization)\s*[=:]/i;

function exitQuiet() {
  process.exit(0);
}

function clean(text) {
  return text
    .replace(/\x1b\[[0-9;?]*[A-Za-z]/g, '')
    .split('\n')
    .map((l) => (l.includes('\r') ? l.split('\r').filter(Boolean).pop() || '' : l))
    .join('\n');
}

function prune(text) {
  const raw = clean(text);
  let lines = raw.split('\n');
  const origCount = lines.length;
  if (origCount < MIN_LINES && text.length < MIN_CHARS) return null;

  let folded = 0;
  lines = lines.filter((l) => {
    if (PASS_NOISE.test(l) || DOT_NOISE.test(l)) {
      folded++;
      return false;
    }
    return true;
  });

  // Collapse runs of identical lines and blank lines
  const dedup = [];
  for (let i = 0; i < lines.length; ) {
    let j = i;
    while (j < lines.length && lines[j] === lines[i]) j++;
    const run = j - i;
    if (lines[i].trim() === '') dedup.push('');
    else if (run > 2) dedup.push(lines[i], `[line repeated ${run - 1} more times]`);
    else for (let k = i; k < j; k++) dedup.push(lines[k]);
    i = j;
  }
  lines = dedup;

  if (lines.length > HEAD + TAIL + MAX_KEPT_MIDDLE) {
    const keep = new Set();
    for (let i = 0; i < Math.min(HEAD, lines.length); i++) keep.add(i);
    for (let i = Math.max(0, lines.length - TAIL); i < lines.length; i++) keep.add(i);
    let middle = 0;
    for (let i = HEAD; i < lines.length - TAIL && middle < MAX_KEPT_MIDDLE; i++) {
      if (IMPORTANT.test(lines[i])) {
        keep.add(i);
        middle++;
      }
    }
    const out = [];
    let gap = 0;
    lines.forEach((l, i) => {
      if (keep.has(i)) {
        if (gap) out.push(`[... ${gap} lines pruned ...]`);
        gap = 0;
        out.push(l);
      } else gap++;
    });
    if (gap) out.push(`[... ${gap} lines pruned ...]`);
    lines = out;
  }

  const result = lines.join('\n').trimEnd();
  if (result.length > text.length * 0.8) return null;
  return { result, origCount, keptCount: lines.length, folded };
}

let input;
try {
  input = JSON.parse(fs.readFileSync(0, 'utf8'));
} catch {
  exitQuiet();
}
const resp = input.tool_response;
if (input.tool_name !== 'Bash' || !resp || typeof resp.stdout !== 'string') exitQuiet();
if (resp.isImage || resp.interrupted) exitQuiet();
if (CONTENT_CMD.test((input.tool_input && input.tool_input.command) || '')) exitQuiet();

const out = prune(resp.stdout);
const err = typeof resp.stderr === 'string' ? prune(resp.stderr) : null;
if (!out && !err) exitQuiet();

// Keep the full original on disk (temp dir, 24h) unless it looks like it holds a secret
let saved = '';
const original = `${resp.stdout}\n--- stderr ---\n${resp.stderr || ''}`;
if (!SECRETISH.test(original)) {
  try {
    const dir = path.join(os.tmpdir(), 'claude-prune');
    fs.mkdirSync(dir, { recursive: true, mode: 0o700 });
    const now = Date.now();
    for (const f of fs.readdirSync(dir)) {
      const p = path.join(dir, f);
      if (now - fs.statSync(p).mtimeMs > 24 * 3600 * 1000) fs.unlinkSync(p);
    }
    const file = path.join(dir, `${input.tool_use_id || now}.log`);
    fs.writeFileSync(file, original, { mode: 0o600 });
    saved = `; full output: ${file.replace(/\\/g, '/')} (use Grep or Read with limit)`;
  } catch {
    // saving is best-effort
  }
}
if (!saved) saved = '; full output not saved, re-run the command to see it';

const before = resp.stdout.length + (resp.stderr || '').length;
const stdout = out ? out.result : resp.stdout;
const stderr = err ? err.result : resp.stderr;
const after = stdout.length + (stderr || '').length;
const parts = [];
if (out) parts.push(`stdout ${out.origCount} -> ${out.keptCount} lines`);
if (err) parts.push(`stderr ${err.origCount} -> ${err.keptCount} lines`);
const folded = (out ? out.folded : 0) + (err ? err.folded : 0);
if (folded) parts.push(`${folded} passing/progress lines folded`);
const note = `\n[prune-output: ${parts.join(', ')}, ~${Math.round((before - after) / 4)} tokens saved${saved}]`;

process.stdout.write(
  JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PostToolUse',
      updatedToolOutput: { ...resp, stdout: stdout + note, stderr },
    },
  }),
);
