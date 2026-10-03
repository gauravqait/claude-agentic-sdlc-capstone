# PR validation checks (T10)
No real PR is created. A tiny checker applies skill items 1 and 7 (sections, base/head) to sample bodies.

```bash
chk(){ body="$1"; base="$2"; head="$3"; ok=""
 for s in Summary "Changes Made" "Test Evidence" "Known Limitations" "Reviewer Checklist"; do grep -q "^## $s" <<<"$body" || { ok="$ok; missing $s"; }; done
 [ "$base" = main ] || ok="$ok; base=$base"
 [[ "$head" =~ ^feature/[a-z0-9]+-[0-9]+-.+$ ]] || ok="$ok; head=$head"
 [ -z "$ok" ] && echo PASS || echo "FAIL$ok"; }
GOOD=$'## Summary\n## Changes Made\n## Test Evidence\n## Known Limitations\n## Reviewer Checklist\n- [ ] ok'
chk "$GOOD" main feature/kan-4-sdlc-pipeline                              # P1 want PASS
chk "$(grep -v "Known Limitations" <<<"$GOOD")" main feature/kan-4-sdlc-pipeline      # P2 want FAIL missing
chk "$GOOD" develop feature/kan-4-sdlc-pipeline                           # P3 want FAIL base
chk "$(grep -v "Known Limitations" <<<"$GOOD")" develop main              # P4 want 3 failures
```
