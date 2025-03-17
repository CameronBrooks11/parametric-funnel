/**
 * @file funnel.scad
 * @brief Generate a funnel shape using the given parameters.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains modules for generating a funnel shape using the given parameters.
 * Uses polygon() and rotate_extrude() to create the funnel shape in an efficient manner.
 *
 */

// height of the slanted funneling section
test_funnel_height = 60;

// top radius of the funnel
test_funnel_top_radius = 50;

// height of the throat section
test_throat_height = 20;

// radius of the throat
test_throat_radius = 15;

// thickness of the funnel wall
test_wall_thickness = 0.8;

// additional height at the funnel's top edge
test_top_edge_height = 5;

funnel(funnel_height = test_funnel_height, funnel_top_radius = test_funnel_top_radius,
       throat_height = test_throat_height, throat_radius = test_throat_radius, wall_thickness = test_wall_thickness,
       top_edge_height = test_top_edge_height);

/*
 * @brief Generate a funnel shape using the given parameters.
 *
 * @param funnel_height Height of the funnel section.
 * @param funnel_top_radius Horizontal offset defining the funnel's top.
 * @param throat_height Vertical height of the throat section.
 * @param throat_radius Radius of the throat.
 * @param wall_thickness Thickness of the funnel wall.
 * @param top_edge_height Additional height at the funnel's top edge.
 * @param smoothness_segments Number of segments for a smooth rotation.
 */
module funnel(funnel_height, funnel_top_radius, throat_height, throat_radius, wall_thickness, top_edge_height,
              smoothness_segments = 128)
{
    rotate_extrude($fn = smoothness_segments) translate([ funnel_top_radius, 0 ])
        polygon(points = [[throat_radius - funnel_top_radius, 0], [throat_radius - funnel_top_radius, throat_height],
                          [0, throat_height + funnel_height], [0, throat_height + funnel_height + top_edge_height],
                          [wall_thickness, throat_height + funnel_height + top_edge_height],
                          [wall_thickness, throat_height + funnel_height],
                          [throat_radius + wall_thickness - funnel_top_radius, throat_height],
                          [throat_radius + wall_thickness - funnel_top_radius, 0],
                          [throat_radius - funnel_top_radius, 0] // Closing point (optional)
    ]);
}