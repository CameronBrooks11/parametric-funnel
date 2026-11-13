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
funnel_height = 60;

// top radius of the funnel
funnel_top_radius = 50;

// height of the throat section
throat_height = 20;

// radius of the throat
throat_radius = 15;

// thickness of the funnel wall
wall_thickness = 0.8;

// additional height at the funnel's top edge
top_edge_height = 5;

funnel(funnel_height = funnel_height, funnel_top_radius = funnel_top_radius, throat_height = throat_height,
       throat_radius = throat_radius, wall_thickness = wall_thickness, top_edge_height = top_edge_height);

/*
 * @brief Generate a funnel shape using the given parameters.
 *
 * @param funnel_height Height of the funnel section.
 * @param funnel_top_radius Inner radius of the funnel's top.
 * @param throat_height Vertical height of the throat section.
 * @param throat_radius Inner radius of the throat.
 * @param wall_thickness Thickness of the funnel wall, measured square to the wall.
 * @param top_edge_height Additional height at the funnel's top edge.
 * @param smoothness_segments Number of segments for a smooth rotation.
 */
module funnel(funnel_height, funnel_top_radius, throat_height, throat_radius, wall_thickness, top_edge_height,
              smoothness_segments = 128)
{
    rotate_extrude($fn = smoothness_segments)
        polygon(funnel_profile(funnel_height, funnel_top_radius, throat_height, throat_radius, wall_thickness,
                               top_edge_height));
}

/*
 * @brief The funnel's cross-section as [radius, height] points, inside wall
 * first from the bottom of the throat to the top edge, then back down the
 * outside.
 *
 * The outside of the sloped section is parallel to the inside and
 * wall_thickness away from it, so its corners sit below the inside ones by
 * wall_thickness * (slope length - funnel_height) / (top radius - throat radius).
 */
function funnel_profile(funnel_height, funnel_top_radius, throat_height, throat_radius, wall_thickness,
                        top_edge_height) =
    let(run = funnel_top_radius - throat_radius, slope = norm([ run, funnel_height ]),
        drop = wall_thickness * (slope - funnel_height) / run,
        top = throat_height + funnel_height + top_edge_height)
        assert(run > 0, "funnel_top_radius must be larger than throat_radius")
            assert(drop < throat_height, str("throat_height must be more than ", drop,
                                             " mm, or the outside of the slope runs below the throat"))
                [
                    [ throat_radius, 0 ], [ throat_radius, throat_height ],
                    [ funnel_top_radius, throat_height + funnel_height ], [ funnel_top_radius, top ],
                    [ funnel_top_radius + wall_thickness, top ],
                    [ funnel_top_radius + wall_thickness, throat_height + funnel_height - drop ],
                    [ throat_radius + wall_thickness, throat_height - drop ], [ throat_radius + wall_thickness, 0 ]
                ];
