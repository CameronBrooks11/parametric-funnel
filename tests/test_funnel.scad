// Checks for funnel_profile(). Prints "funnel: all checks passed" as its
// last line only if every assert held: an echo export reports a failed
// assert in its output and still exits 0.
// Run: openscad --hardwarnings -o - --export-format echo tests/test_funnel.scad

use <../funnel.scad>

eps = 1e-9;

// Distance from point p to the line through a and b.
function line_distance(p, a, b) = let(d = b - a) abs(d.x * (p.y - a.y) - d.y * (p.x - a.x)) / norm(d);

// [funnel_height, funnel_top_radius, throat_height, throat_radius, wall_thickness, top_edge_height]
for (c = [ [ 60, 50, 20, 15, 0.8, 5 ], [ 30, 80, 10, 10, 1.2, 3 ], [ 100, 25, 15, 12, 0.6, 0 ] ])
{
    P = funnel_profile(c[0], c[1], c[2], c[3], c[4], c[5]);
    w = c[4];
    // Points: inside throat bottom, throat top, slope top, rim top; then the
    // outside from the rim top back down to the throat bottom.
    assert(len(P) == 8, "eight points");
    assert(abs(line_distance(P[5], P[1], P[2]) - w) < eps, str(c, ": upper slope wall is ", w));
    assert(abs(line_distance(P[6], P[1], P[2]) - w) < eps, str(c, ": lower slope wall is ", w));
    assert(abs(P[7].x - P[0].x - w) < eps && abs(P[6].x - P[1].x - w) < eps, str(c, ": throat wall is ", w));
    assert(abs(P[4].x - P[3].x - w) < eps && abs(P[5].x - P[2].x - w) < eps, str(c, ": rim wall is ", w));
    assert(P[0] == [ c[3], 0 ] && abs(P[3].y - (c[0] + c[2] + c[5])) < eps, str(c, ": inside radius and height"));
}

echo("funnel: all checks passed");
