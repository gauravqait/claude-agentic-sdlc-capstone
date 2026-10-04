# Artifact and scope tests (KAN-5 AC 2-10)
Run from the repo root in Git Bash.

## 1. Each agent names a single artifact
```bash
for a in 01-requirements 02-architecture 03-design-review 04-impl-plan 05-implementation-summary 06-code-review 07-verification-report; do
  n=$(grep -l "Write exactly one artifact (\`docs/<STORY-ID>/$a.md\`)" .claude/agents/0*.agent.md | wc -l); echo "$a want 1: $n"
done
```

## 2. The 8 artifacts exist for a finished story (use a story with all steps done; pass its ID)
```bash
ID=${1:-KAN-5}; miss=0
for a in 01-requirements 02-architecture 03-design-review 04-impl-plan 05-implementation-summary 06-code-review 07-verification-report 08-pr-summary; do
  [ -s docs/$ID/$a.md ] || { echo "Not Found: docs/$ID/$a.md"; miss=$((miss+1)); }
done; echo "missing count (0 when story is finished): $miss"
```
Not Found cases print the missing path. A story still in progress shows the later artifacts as Not Found.

## 3. Scope check: stray file is rejected
```bash
T=$(mktemp -d); mkdir -p $T/docs/ABC-1; cd $T && git init -q && touch docs/ABC-1/01-requirements.md && git add -A && git -c user.email=a@b -c user.name=t commit -qm x
echo x > docs/ABC-1/02-architecture.md     # expected file
echo x > docs/ABC-1/extra.md               # stray file in folder
echo x > outside.txt                       # file outside docs/ABC-1/
check() { git status --porcelain -uall | awk '{print $2}' | grep -vx "docs/ABC-1/$1.md" | wc -l; }
echo "want 2 (extra.md, outside.txt => reject): $(check 02-architecture)"
rm docs/ABC-1/extra.md outside.txt
echo "want 0 (only expected file => approve): $(check 02-architecture)"
```

## 4. Orchestrator rules are written
```bash
C=.claude/commands/run-sdlc-workflow.md
grep -c 'reject the step' $C | sed 's/^/want 1: /'
grep -c 'One active run per story' $C | sed 's/^/want 1: /'
```
