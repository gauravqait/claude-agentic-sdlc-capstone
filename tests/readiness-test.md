# PR readiness tests (KAN-5 AC 12)
Run from the repo root in Git Bash. Checks (a)-(c) need GitHub MCP, so only their definitions are checked here. (d), (e), (f) run on temp files. Fake tokens are built at run time so no secret is stored.

## 1. All six checks are defined
```bash
S=.claude/skills/02-pr-validation-skill.md
for c in a b c d e f; do echo "($c) want 1: $(grep -c "^| ($c) |" $S)"; done
grep -c 'Any FAIL blocks the PR, names the check' $S | sed 's/^/want 1: /'
```

## 2. Check (d): verdict and FAIL rows
```bash
d() { grep -q '^Verdict: PASS' "$1" && ! grep -qE '\|[[:space:]]*FAIL[[:space:]]*\|' "$1" && echo PASS || echo "FAIL (d)"; }
T=$(mktemp -d)
printf 'Verdict: PASS\n| t | Status |\n|---|---|\n| a | PASS |\n' > $T/ok.md;   echo "want PASS: $(d $T/ok.md)"
printf 'Verdict: PASS\n| t | Status |\n|---|---|\n| a | FAIL |\n' > $T/row.md;  echo "want FAIL (d): $(d $T/row.md)"
printf '| t | Status |\n|---|---|\n| a | PASS |\n' > $T/nov.md;             echo "want FAIL (d): $(d $T/nov.md)"
```

## 3. Check (e): one case per prefix, no secret value in output
```bash
H=.claude/hooks; x() { printf 'a%.0s' $(seq 24); }
for p in ghp_ gho_ ghs_ github_pat_ ATATT "Bearer "; do
  out=$(echo '{"tool_name":"Write","tool_input":{"content":"'"$p$(x)"'"}}' | bash $H/check-secrets.sh 2>&1); rc=$?
  echo "$p want 2: $rc; value leaked (want 0): $(echo "$out" | grep -c "$(x)")"
done
pem="-----BEGIN ""RSA PRIVATE KEY-----"
echo '{"tool_name":"Write","tool_input":{"content":"'"$pem"'"}}' | bash $H/check-secrets.sh 2>/dev/null; echo "pem want 2: $?"
echo '{"tool_name":"Write","tool_input":{"content":"Bearer short"}}' | bash $H/check-secrets.sh; echo "short Bearer want 0: $?"
echo '{"tool_name":"Write","tool_input":{"content":"plain text"}}'   | bash $H/check-secrets.sh; echo "clean want 0: $?"
```

## 4. Check (f): required sections
```bash
f() { for s in Summary "Changes Made" "Test Evidence" "Known Limitations" "Reviewer Checklist"; do grep -q "^#* *$s" "$1" || { echo "FAIL (f): $s"; return; }; done; echo PASS; }
T=$(mktemp -d)
printf '## Summary\n## Changes Made\n## Test Evidence\n## Known Limitations\n## Reviewer Checklist\n' > $T/ok.md; echo "want PASS: $(f $T/ok.md)"
printf '## Summary\n## Changes Made\n' > $T/bad.md;                                                            echo "want FAIL (f): Test Evidence: $(f $T/bad.md)"
```

## 5. Checks (a)-(c) fail cases (definitions only, GitHub MCP not run here)
Fail examples: (a) head is `main` or commits not pushed; (b) base has conflicts; (c) any step 1-7 not `approved`. Status: Not Found (needs live GitHub MCP).
