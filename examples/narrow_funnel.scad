// A small funnel for filling bottles, called from another file.
use <../funnel.scad>

funnel(
    funnel_height=40, funnel_top_radius=35, throat_height=15,
    throat_radius=6, wall_thickness=1.2, top_edge_height=4
);
