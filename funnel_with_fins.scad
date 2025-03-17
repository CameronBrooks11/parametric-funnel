/**
 * @file funnel.scad
 * @brief Generate a funnel shape using the given parameters.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains modules for generating a funnel with a cone section, stem, air gap, and turbo fins using the given
 * parameters.
 *
 * Original design:
 * vase mode parametric funnel v2
 * by DrJones   printables.com/@DrJones   makerworld.com/@DrJones
 * License: CC-BY
 * Source: https://www.printables.com/model/895032-parametric-vase-mode-funnel-v2
 *
 * Printing:
 *    Use VASE MODE and set EXTUSION WIDTH (LINE WIDTH) to 0.7mm
 *
 */

/*          [Parameters]       */

outer_diameter = 70;     // Outer diameter in mm [20:150]
cone_angle = 60;         // Cone angle in degrees [30:100]
stem_diameter = 12;      // Stem diameter (where it meets the cone) [10:60]
stem_length = 50;        // Length of stem [5:150]
stem_taper = 15;         // Stem taper; diameter reduction at the end in % [0:50]
air_gap_percentage = 40; // Air gap diameter as % of stem diameter [0:70]

fin_type = 1;         // Type of "turbo" fins [0:off, 1:common fins, 2:improved]
fin_count = 10;       // Number of fins [0:15]
fin_twist_angle = 45; // Twist angle for fins [0:60]
fin_direction = 0;    // Twist direction [0:clockwise, 1:counterclockwise]
fin_depth = 3;        // Depth of fins [1:8]

$fn = $preview ? 128 : 128 * 2;

finned_funnel(outer_diameter, cone_angle, stem_diameter, stem_length, stem_taper, air_gap_percentage, fin_type,
              fin_count, fin_twist_angle, fin_direction, fin_depth);

/**
 * @brief: Module to create a funnel with fins and an air gap.
 *
 * This module creates a funnel with a cone section, a stem section, an air gap, and fins.
 *
 * @param outer_d: Outer diameter of the funnel.
 * @param cone_ang: Cone angle of the funnel.
 * @param stem_d: Stem diameter of the funnel.
 * @param stem_len: Length of the stem.
 * @param stem_tap: Taper percentage of the stem.
 * @param air_gap_pct: Air gap diameter as a percentage of the stem diameter.
 * @param fin_typ: Type of "turbo" fins.
 * @param fin_ct: Number of fins.
 * @param fin_twist_ang: Twist angle of the fins.
 * @param fin_dir: Twist direction of the fins.
 * @param fin_dep: Depth of the fins.
 */
module finned_funnel(outer_d, cone_ang, stem_d, stem_len, stem_tap, air_gap_pct, fin_typ, fin_ct, fin_twist_ang,
                     fin_dir, fin_dep)
{

    // Derived values:
    cone_h = (outer_d - stem_d) / 2 / tan(cone_ang / 2);
    air_gap_d = stem_d * air_gap_pct / 100;

    difference()
    {
        union()
        {
            // Cone section: from the outer diameter to the stem diameter.
            cylinder(h = cone_h, d1 = outer_d, d2 = stem_d);
            // Stem section: translated upward by the cone height.
            translate([ 0, 0, cone_h ]) cylinder(h = stem_len, d1 = stem_d, d2 = stem_d * (1 - stem_tap / 100));
        }
        if (air_gap_pct > 0)
            airgap(outer_d, cone_ang, stem_d, cone_h, stem_len, stem_tap, air_gap_d);
        if (fin_typ == 1)
            fins_original(outer_d, cone_h, stem_d, fin_ct, fin_twist_ang, fin_dir, fin_dep);
        if (fin_typ == 2)
            improved_fins(outer_d, cone_h, stem_d, fin_ct, fin_twist_ang, fin_dir, fin_dep);
    }

    // Thumb tab: a small cylinder translated along X.
    translate([ outer_d / 2 - tan(cone_ang / 2), 0, 0 ]) cylinder(h = 2, d = 5 + outer_d * 0.05);
}

/**
 *  @brief: Module to create an air gap in the funnel.
 *
 * This module creates an air gap in the funnel to allow air to escape.
 *
 *  @param outer_d: Outer diameter of the funnel.
 *  @param cone_ang: Cone angle of the funnel.
 *  @param stem_d: Stem diameter of the funnel.
 *  @param cone_h: Height of the cone section.
 *  @param stem_len: Length of the stem.
 *  @param stem_tap: Taper percentage of the stem.
 *  @param air_gap_d: Diameter of the air gap.
 */
module airgap(outer_d, cone_ang, stem_d, cone_h, stem_len, stem_tap, air_gap_d)
{
    air_gap_rot_ang = cone_ang / 2 + air_gap_d * cos(cone_ang / 2) * 28.6 / (cone_h - 2);
    stem_ext_ang = atan((stem_d * stem_tap / 100) / 2 / stem_len);

    translate([ stem_d / 2, 0, cone_h ])
    {
        sphere(d = air_gap_d);
        rotate([ 0, 180 - air_gap_rot_ang, 0 ]) cylinder(h = sqrt(outer_d * outer_d / 4 + cone_h ^ 2), d = air_gap_d);
        rotate([ 0, -stem_ext_ang, 0 ]) cylinder(h = stem_len + 10, d = air_gap_d);
    }
}

/**
 * @brief: Module to create the original turbo fins.
 *
 * This module creates the original turbo fins for the funnel.
 *
 * @param outer_d: Outer diameter of the funnel.
 * @param cone_h: Height of the cone section.
 * @param stem_d: Stem diameter of the funnel.
 * @param fin_ct: Number of fins.
 * @param fin_twist_ang: Twist angle of the fins.
 * @param fin_dir: Twist direction of the fins.
 */
module fins_original(outer_d, cone_h, stem_d, fin_ct, fin_twist_ang, fin_dir, fin_dep)
{
    difference()
    {
        mirror([ 0, fin_dir, 0 ]) union() for (fin_ang = [2.5 + 360 / outer_d:360 / fin_ct:359])
            rotate([ 0, 0, fin_ang ]) linear_extrude(cone_h, twist = -tan(fin_twist_ang) * 2 * 57.3 * cone_h / outer_d)
                translate([ stem_d / 2 + 3, 0, 0 ]) square([ outer_d / 2, 0.1 ]);
        cylinder(h = cone_h - fin_dep, d1 = outer_d - 2 * fin_dep, d2 = stem_d);
    }
}

/**
 * @brief: Module to create the improved turbo fins.
 *
 * This module creates the improved turbo fins for the funnel.
 *
 * @param outer_d: Outer diameter of the funnel.
 * @param cone_h: Height of the cone section.
 * @param stem_d: Stem diameter of the funnel.
 * @param fin_ct: Number of fins.
 * @param fin_twist_ang: Twist angle of the fins.
 * @param fin_dir: Twist direction of the fins.
 */
module improved_fins(outer_d, cone_h, stem_d, fin_ct, fin_twist_ang, fin_dir, fin_dep, n = 12)
{
    sub_h = cone_h / n;
    twist_fact = -tan(fin_twist_ang) * 2 * 57.3 * sub_h;

    // Recursive helper module
    module sub(i)
    {
        if (i < n)
        {
            current_d = outer_d + (i + 0.5) * sub_h / cone_h * (stem_d - outer_d);
            section_twist = twist_fact / current_d;
            for (fin_ang = [2.5 + 360 / outer_d:360 / fin_ct:359])
                rotate([ 0, 0, fin_ang ]) linear_extrude(sub_h, twist = section_twist)
                    translate([ stem_d / 2 + 3, 0, 0 ]) square([ current_d / 2, 0.1 ]);
            translate([ 0, 0, sub_h ]) rotate([ 0, 0, -section_twist ]) sub(i + 1);
        }
    }

    mirror([ 0, fin_dir, 0 ]) difference()
    {
        sub(0);
        cylinder(h = cone_h - fin_dep, d1 = outer_d - 2 * fin_dep, d2 = stem_d);
    }
}