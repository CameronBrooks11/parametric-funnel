default:
    @just --list

# Run the profile checks, then render each design and check its solids and size
test:
    @out=$(openscad --hardwarnings -o - --export-format echo tests/test_funnel.scad 2>/dev/null); echo "$out" | grep -q 'all checks passed' || { echo "$out" | grep -E 'ERROR|WARNING'; exit 1; }; echo "profile checks passed"
    @# funnel.scad defaults: 2 * (50 + 0.8) across, 20 + 60 + 5 tall.
    @just _check funnel.scad "" 1 101.6 101.6 85
    @# funnel_with_fins.scad defaults: 100 across in y, the thumb tab adds to x, and the
    @# cone (100 - 20) / 2 / tan(30) = 69.28 plus the 50 mm stem tall.
    @just _check funnel_with_fins.scad "-D fin_type=0" 1 104.42 100 119.28
    @just _check funnel_with_fins.scad "-D fin_type=1" 1 104.42 100 119.28
    @just _check funnel_with_fins.scad "-D fin_type=2" 1 104.42 100 119.28
    @# examples/narrow_funnel.scad: 2 * (35 + 1.2) across, 15 + 40 + 4 tall.
    @just _check examples/narrow_funnel.scad "" 1 72.4 72.4 59

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

[private]
_check file defines solids x y z:
    @# A failed assert leaves OpenSCAD's exit status at 0, so its stderr is read too.
    @stl=$(mktemp --suffix .stl); err=$(openscad --hardwarnings {{defines}} --export-format binstl -o "$stl" {{file}} 2>&1); rc=$?; if echo "$err" | grep -E '^(ERROR|WARNING)'; then rc=1; fi; if [ $rc -eq 0 ]; then python3 tests/check_stl.py "$stl" {{solids}} {{x}} {{y}} {{z}}; rc=$?; fi; rm -f "$stl"; [ $rc -eq 0 ] || echo "{{file}} {{defines}} failed"; exit $rc

# Render the README pictures into assets/
images:
    @mkdir -p assets
    @openscad --render --camera=0,0,0,70,0,30,0 --viewall --autocenter --imgsize=600,500 -o assets/funnel.png funnel.scad 2>/dev/null && echo "assets/funnel.png"
    @openscad --render -D fin_type=1 --camera=0,0,0,235,0,30,0 --viewall --autocenter --imgsize=600,500 -o assets/funnel_with_fins.png funnel_with_fins.scad 2>/dev/null && echo "assets/funnel_with_fins.png"
