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

[private]
_check file defines solids x y z:
    @stl=$(mktemp --suffix .stl) && openscad --hardwarnings {{defines}} --export-format binstl -o "$stl" {{file}} 2>/dev/null && python3 tests/check_stl.py "$stl" {{solids}} {{x}} {{y}} {{z}}; rc=$?; rm -f "$stl"; [ $rc -eq 0 ] || echo "{{file}} {{defines}} failed"; exit $rc

# Render the README pictures into assets/
images:
    @mkdir -p assets
    @openscad --render --camera=0,0,0,70,0,30,0 --viewall --autocenter --imgsize=600,500 -o assets/funnel.png funnel.scad 2>/dev/null && echo "assets/funnel.png"
    @openscad --render -D fin_type=1 --camera=0,0,0,235,0,30,0 --viewall --autocenter --imgsize=600,500 -o assets/funnel_with_fins.png funnel_with_fins.scad 2>/dev/null && echo "assets/funnel_with_fins.png"
