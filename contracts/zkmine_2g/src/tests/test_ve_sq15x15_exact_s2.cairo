// AUTO-GENERATED — do not edit by hand
// Square 15x15/35 correctness shard 2

use zkmine_2g::ve::{count_joint_component_with_order, count_ordinary_component, Constraint, JointEntry};
use zkmine_2g::cell::{convolve_joint, convolve_ordinary, apply_unconstrained_local, extract_outcomes};
use zkmine_2g::bigint::u512_eq;
use core::integer::u512;

#[test]
fn sq15_exact_s2_f068() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182, 183, 198];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181, 182, 183], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![168, 183], rhs: 1 }, Constraint { variables: array![168, 183, 198], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 198, 136, 151, 166, 168, 181, 182, 183];
    let sp_nbrs: Array<u32> = array![183, 198];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 199, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 41, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4496388, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 749398, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s006 c8');
}
#[test]
fn sq15_exact_s2_f069() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182, 183, 198, 213];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181, 182, 183], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![168, 183], rhs: 1 }, Constraint { variables: array![168, 183, 198], rhs: 1 }, Constraint { variables: array![183, 198, 213], rhs: 0 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 213, 198, 136, 151, 166, 168, 181, 182, 183];
    let sp_nbrs: Array<u32> = array![198, 213];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 214, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 41, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4496388, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s007 c8');
}
#[test]
fn sq15_exact_s2_f070() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181, 182], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182];
    let sp_nbrs: Array<u32> = array![168, 182];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 183, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 40, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 3838380, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 658008, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s011 c8');
}
#[test]
fn sq15_exact_s2_f071() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182, 197];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181, 182], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![168, 182, 197], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 197, 136, 151, 166, 168, 181, 182];
    let sp_nbrs: Array<u32> = array![182, 197];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 198, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 39, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 3262623, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 575757, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s012 c8');
}
#[test]
fn sq15_exact_s2_f072() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 182, 197, 212];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181, 182], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![168, 182, 197], rhs: 1 }, Constraint { variables: array![182, 197, 212], rhs: 0 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 212, 197, 136, 151, 166, 168, 181, 182];
    let sp_nbrs: Array<u32> = array![197, 212];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 213, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 39, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 3262623, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s013 c8');
}
#[test]
fn sq15_exact_s2_f073() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181];
    let sp_nbrs: Array<u32> = array![166, 168, 181];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 182, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 38, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2760681, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 501942, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s014 c8');
}
#[test]
fn sq15_exact_s2_f074() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 196];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181], rhs: 2 }, Constraint { variables: array![166, 168, 181, 196], rhs: 1 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 196];
    let sp_nbrs: Array<u32> = array![181, 196];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 197, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 37, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2324784, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 435897, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s015 c8');
}
#[test]
fn sq15_exact_s2_f075() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168, 181, 196, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168, 181], rhs: 2 }, Constraint { variables: array![166, 168, 181, 196], rhs: 1 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![181, 196, 211], rhs: 0 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 211, 136, 151, 166, 168, 181, 196];
    let sp_nbrs: Array<u32> = array![196, 211];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 212, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 37, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2324784, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s016 c8');
}
#[test]
fn sq15_exact_s2_f076() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168], rhs: 2 }, Constraint { variables: array![166, 168], rhs: 1 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 166, 168];
    let sp_nbrs: Array<u32> = array![166];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 181, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 34, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1344904, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 834768, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 139128, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 5984, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s017 c8');
}
#[test]
fn sq15_exact_s2_f077() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 165, 166, 168, 180, 195];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168], rhs: 2 }, Constraint { variables: array![165, 166, 180, 195], rhs: 0 }, Constraint { variables: array![166, 168], rhs: 1 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 168, 165, 166, 180, 195];
    let sp_nbrs: Array<u32> = array![180, 195];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 196, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 33, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1107568, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 237336, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s018 c8');
}
#[test]
fn sq15_exact_s2_f078() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 165, 166, 168, 180, 195, 210];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 166, 168], rhs: 3 }, Constraint { variables: array![151, 166, 168], rhs: 2 }, Constraint { variables: array![165, 166, 180, 195], rhs: 0 }, Constraint { variables: array![166, 168], rhs: 1 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![180, 195, 210], rhs: 0 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 210, 136, 151, 168, 165, 166, 180, 195];
    let sp_nbrs: Array<u32> = array![195, 210];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 211, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 33, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1107568, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s019 c8');
}
#[test]
fn sq15_exact_s2_f079() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 168];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 168], rhs: 3 }, Constraint { variables: array![151, 168], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 76, 91, 106, 121, 136, 151, 168];
    let sp_nbrs: Array<u32> = array![151];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 165, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 32, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 906192, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 201376, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s020 c8');
}
#[test]
fn sq15_exact_s2_f080() {
    let sp_vars: Array<u32> = array![75, 76, 91, 106, 121, 136, 150, 151, 168];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106], rhs: 2 }, Constraint { variables: array![91, 106, 121], rhs: 1 }, Constraint { variables: array![106, 121, 136], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![136, 151, 168], rhs: 3 }, Constraint { variables: array![150, 151], rhs: 1 }, Constraint { variables: array![151, 168], rhs: 2 }, Constraint { variables: array![168], rhs: 1 }];
    let sp_hint: Array<u32> = array![75, 150, 76, 91, 106, 121, 136, 151, 168];
    let sp_nbrs: Array<u32> = array![150, 151];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 166, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 26, 27, 42, 43, 49, 56, 58, 64, 66, 69, 72, 73, 81, 84, 86, 88, 96, 103, 118, 127, 133, 147, 148, 156, 161, 162, 163, 173, 176, 178, 188, 189, 190, 191, 192, 193, 203, 218];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4, 19], rhs: 2 }, Constraint { variables: array![4, 5, 6, 19], rhs: 1 }, Constraint { variables: array![5, 6, 7], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9], rhs: 2 }, Constraint { variables: array![8, 9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 1 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![26, 27, 42, 56], rhs: 2 }, Constraint { variables: array![26, 56], rhs: 1 }, Constraint { variables: array![42, 43, 56, 58, 72, 73], rhs: 2 }, Constraint { variables: array![49, 64], rhs: 2 }, Constraint { variables: array![49, 64, 66], rhs: 3 }, Constraint { variables: array![49, 64, 66, 81], rhs: 4 }, Constraint { variables: array![56, 69], rhs: 2 }, Constraint { variables: array![56, 69, 84, 86], rhs: 4 }, Constraint { variables: array![56, 72, 86], rhs: 3 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 66, 81, 96], rhs: 4 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 81], rhs: 2 }, Constraint { variables: array![66, 81, 96], rhs: 3 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 84], rhs: 2 }, Constraint { variables: array![69, 84, 86], rhs: 3 }, Constraint { variables: array![72, 73, 86, 88, 103], rhs: 3 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 86], rhs: 2 }, Constraint { variables: array![86], rhs: 1 }, Constraint { variables: array![86, 88, 103, 118], rhs: 2 }, Constraint { variables: array![96], rhs: 1 }, Constraint { variables: array![96, 127], rhs: 2 }, Constraint { variables: array![103, 118, 133], rhs: 1 }, Constraint { variables: array![118, 133, 147, 148], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 156], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 173], rhs: 2 }, Constraint { variables: array![156, 173, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 3 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 1 }, Constraint { variables: array![173, 188, 203], rhs: 2 }, Constraint { variables: array![188, 203, 218], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 32, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 906192, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00148g0f04_s021 c8');
}
#[test]
fn sq15_exact_s2_f081() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![11];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![11], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![14];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![14], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![17, 32, 37, 47, 51, 65, 74, 79, 83, 85, 89, 90, 95, 98, 104, 106, 113, 115, 119, 132, 133, 134, 136, 138, 143, 149, 155, 156, 162, 163, 164, 175, 179, 192, 193, 194, 203, 207, 209, 218, 219, 220, 221, 222, 223, 224];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![17], rhs: 1 }, Constraint { variables: array![17, 32], rhs: 2 }, Constraint { variables: array![17, 32, 47], rhs: 3 }, Constraint { variables: array![32, 47], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 51], rhs: 2 }, Constraint { variables: array![47], rhs: 1 }, Constraint { variables: array![47, 79], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 65], rhs: 2 }, Constraint { variables: array![51, 83], rhs: 2 }, Constraint { variables: array![65], rhs: 1 }, Constraint { variables: array![65, 79], rhs: 2 }, Constraint { variables: array![65, 79, 95], rhs: 3 }, Constraint { variables: array![65, 95], rhs: 2 }, Constraint { variables: array![74], rhs: 1 }, Constraint { variables: array![74, 89], rhs: 1 }, Constraint { variables: array![74, 89, 104], rhs: 1 }, Constraint { variables: array![79], rhs: 1 }, Constraint { variables: array![79, 95], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 85], rhs: 2 }, Constraint { variables: array![83, 85, 98], rhs: 3 }, Constraint { variables: array![83, 85, 98, 113, 115], rhs: 5 }, Constraint { variables: array![83, 98], rhs: 2 }, Constraint { variables: array![83, 98, 113], rhs: 3 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 115], rhs: 2 }, Constraint { variables: array![89, 104, 119], rhs: 1 }, Constraint { variables: array![90], rhs: 1 }, Constraint { variables: array![90, 106], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![98, 113], rhs: 2 }, Constraint { variables: array![98, 113, 115], rhs: 3 }, Constraint { variables: array![104, 119, 132, 133, 134], rhs: 3 }, Constraint { variables: array![106], rhs: 1 }, Constraint { variables: array![106, 136], rhs: 2 }, Constraint { variables: array![106, 136, 138], rhs: 3 }, Constraint { variables: array![113, 115, 143], rhs: 3 }, Constraint { variables: array![113, 143], rhs: 2 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![115, 132], rhs: 2 }, Constraint { variables: array![132, 133], rhs: 2 }, Constraint { variables: array![132, 133, 134, 149, 162, 163, 164], rhs: 5 }, Constraint { variables: array![132, 133, 162, 163], rhs: 4 }, Constraint { variables: array![132, 162], rhs: 2 }, Constraint { variables: array![136], rhs: 1 }, Constraint { variables: array![136, 138], rhs: 2 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 155], rhs: 2 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 156], rhs: 2 }, Constraint { variables: array![143, 175], rhs: 2 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 156], rhs: 2 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![162, 163, 164, 179, 192, 193, 194], rhs: 4 }, Constraint { variables: array![162, 163, 192, 193], rhs: 4 }, Constraint { variables: array![162, 175], rhs: 2 }, Constraint { variables: array![162, 175, 192], rhs: 3 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 192, 207], rhs: 3 }, Constraint { variables: array![175, 203], rhs: 2 }, Constraint { variables: array![192, 193, 194, 207, 209, 222, 223, 224], rhs: 3 }, Constraint { variables: array![192, 207, 220, 221, 222], rhs: 2 }, Constraint { variables: array![203], rhs: 1 }, Constraint { variables: array![203, 218], rhs: 1 }, Constraint { variables: array![203, 218, 219, 220], rhs: 2 }, Constraint { variables: array![219, 220, 221], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 0, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00255g0f07_s004 c8');
}
#[test]
fn sq15_exact_s2_f082() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 47, 48, 52, 56, 57, 62, 70, 72, 77, 78, 81, 87, 92, 102, 107, 108, 113, 117, 122, 125, 131, 132, 133, 134, 137, 141, 142, 143, 152, 153, 158, 159, 168, 169, 170, 171, 172, 173, 188];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48], rhs: 1 }, Constraint { variables: array![34, 35, 36], rhs: 1 }, Constraint { variables: array![35, 36, 37, 52], rhs: 1 }, Constraint { variables: array![37, 38, 39, 52], rhs: 1 }, Constraint { variables: array![38, 39, 40, 70], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 70], rhs: 1 }, Constraint { variables: array![47, 48, 62, 77, 78], rhs: 1 }, Constraint { variables: array![48, 78], rhs: 1 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 81], rhs: 2 }, Constraint { variables: array![56, 57, 70, 72, 87], rhs: 1 }, Constraint { variables: array![70], rhs: 1 }, Constraint { variables: array![70, 72, 87, 102], rhs: 1 }, Constraint { variables: array![77, 78, 92, 107, 108], rhs: 2 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 108], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 113], rhs: 2 }, Constraint { variables: array![87, 102, 117], rhs: 1 }, Constraint { variables: array![102, 117, 131, 132], rhs: 2 }, Constraint { variables: array![107, 108, 122, 137], rhs: 1 }, Constraint { variables: array![108, 125], rhs: 2 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 141, 142, 143], rhs: 4 }, Constraint { variables: array![113, 142, 143], rhs: 3 }, Constraint { variables: array![113, 143], rhs: 2 }, Constraint { variables: array![122, 137, 152, 153], rhs: 1 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 141], rhs: 2 }, Constraint { variables: array![125, 141, 142], rhs: 3 }, Constraint { variables: array![125, 153], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 132], rhs: 1 }, Constraint { variables: array![131, 132, 133], rhs: 2 }, Constraint { variables: array![131, 159], rhs: 2 }, Constraint { variables: array![132, 133, 134], rhs: 1 }, Constraint { variables: array![133, 134], rhs: 1 }, Constraint { variables: array![141, 142, 143, 158, 171, 172, 173], rhs: 4 }, Constraint { variables: array![141, 142, 170, 171, 172], rhs: 3 }, Constraint { variables: array![141, 169, 170, 171], rhs: 2 }, Constraint { variables: array![143, 158, 159], rhs: 3 }, Constraint { variables: array![153, 168, 169, 170], rhs: 2 }, Constraint { variables: array![158, 159, 173, 188], rhs: 3 }, Constraint { variables: array![159], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 97, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 793067310934426018, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00298g0f02_s016 c8');
}
#[test]
fn sq15_exact_s2_f083() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25];
    let sp_nbrs: Array<u32> = array![24, 25];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 40, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 84, 85, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 84], rhs: 1 }, Constraint { variables: array![83, 84, 85], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 51, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 267569120, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 122151120, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 15593760, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 541450, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s053 c8');
}
#[test]
fn sq15_exact_s2_f084() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 56];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }, Constraint { variables: array![24, 25, 26, 41, 56], rhs: 2 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 56];
    let sp_nbrs: Array<u32> = array![41, 56];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 55, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 84, 85, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 84], rhs: 1 }, Constraint { variables: array![83, 84, 85], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 50, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 36018920, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 76735960, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 9396240, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s054 c8');
}
#[test]
fn sq15_exact_s2_f085() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![104];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![109, 110, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 42, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1086008, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 271502, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 13244, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s008 c8');
}
#[test]
fn sq15_exact_s2_f086() {
    let sp_vars: Array<u32> = array![7, 11, 12, 20, 27, 35, 39, 53, 70, 71];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7], rhs: 1 }, Constraint { variables: array![7, 20], rhs: 2 }, Constraint { variables: array![7, 20, 35], rhs: 3 }, Constraint { variables: array![7, 39], rhs: 2 }, Constraint { variables: array![11, 12, 27], rhs: 1 }, Constraint { variables: array![11, 39], rhs: 1 }, Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 35], rhs: 2 }, Constraint { variables: array![27], rhs: 1 }, Constraint { variables: array![35], rhs: 1 }, Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 53], rhs: 2 }, Constraint { variables: array![39, 53, 70], rhs: 3 }, Constraint { variables: array![39, 70, 71], rhs: 3 }, Constraint { variables: array![53], rhs: 1 }, Constraint { variables: array![53, 70], rhs: 2 }, Constraint { variables: array![70], rhs: 1 }, Constraint { variables: array![70, 71], rhs: 2 }, Constraint { variables: array![71], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 11, 20, 35, 7, 53, 39, 70, 71];
    let sp_nbrs: Array<u32> = array![11];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 10, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![1, 15, 16];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![1, 16], rhs: 1 }, Constraint { variables: array![15, 16], rhs: 1 }, Constraint { variables: array![16], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 76, 78, 80, 90, 91, 108, 109, 141, 153, 156, 165, 166, 168, 180, 181, 182, 184, 185, 195, 197, 203, 204, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75, 76], rhs: 1 }, Constraint { variables: array![76, 78], rhs: 2 }, Constraint { variables: array![76, 78, 91], rhs: 3 }, Constraint { variables: array![76, 78, 91, 108], rhs: 4 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 80], rhs: 2 }, Constraint { variables: array![78, 80, 108, 109], rhs: 4 }, Constraint { variables: array![78, 108, 109], rhs: 3 }, Constraint { variables: array![80], rhs: 1 }, Constraint { variables: array![80, 109], rhs: 2 }, Constraint { variables: array![90, 91], rhs: 1 }, Constraint { variables: array![91, 108], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 109], rhs: 2 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 141], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 156], rhs: 2 }, Constraint { variables: array![153], rhs: 1 }, Constraint { variables: array![153, 166, 168], rhs: 3 }, Constraint { variables: array![153, 166, 168, 181, 182], rhs: 5 }, Constraint { variables: array![153, 168], rhs: 2 }, Constraint { variables: array![153, 168, 184, 185], rhs: 4 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 184, 185], rhs: 3 }, Constraint { variables: array![156, 185], rhs: 2 }, Constraint { variables: array![165, 166], rhs: 2 }, Constraint { variables: array![168, 182, 184, 197], rhs: 4 }, Constraint { variables: array![180, 181, 182, 195, 197, 210, 211, 212], rhs: 3 }, Constraint { variables: array![182, 184, 197, 212, 213, 214], rhs: 3 }, Constraint { variables: array![184, 185, 213, 214, 215], rhs: 2 }, Constraint { variables: array![184, 185, 214, 215, 216], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 215, 216, 217], rhs: 1 }, Constraint { variables: array![203], rhs: 1 }, Constraint { variables: array![203, 204], rhs: 2 }, Constraint { variables: array![203, 216, 217, 218], rhs: 1 }, Constraint { variables: array![204], rhs: 1 }, Constraint { variables: array![204, 219, 220, 221], rhs: 1 }, Constraint { variables: array![208], rhs: 1 }, Constraint { variables: array![208, 209], rhs: 1 }, Constraint { variables: array![208, 221, 222, 223], rhs: 3 }, Constraint { variables: array![220, 221, 222], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![129, 145, 146];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![129], rhs: 1 }, Constraint { variables: array![129, 145], rhs: 2 }, Constraint { variables: array![129, 145, 146], rhs: 3 }, Constraint { variables: array![145], rhs: 1 }, Constraint { variables: array![145, 146], rhs: 2 }, Constraint { variables: array![146], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 2, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00196g0f03_s001 c8');
}
#[test]
fn sq15_exact_s2_f087() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25];
    let sp_nbrs: Array<u32> = array![6, 21];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 5, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![46, 61, 76, 77, 83, 84, 85, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 84], rhs: 1 }, Constraint { variables: array![83, 84, 85], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![224];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 56, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 927669600, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s050 c8');
}
#[test]
fn sq15_exact_s2_f088() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }, Constraint { variables: array![24, 25, 26, 41], rhs: 2 }, Constraint { variables: array![41], rhs: 1 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41];
    let sp_nbrs: Array<u32> = array![41];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 56, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 46, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 21475146, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 9203634, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 1070190, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 32430, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s056 c8');
}
#[test]
fn sq15_exact_s2_f089() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 42, 57, 72];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }, Constraint { variables: array![24, 25, 26, 41], rhs: 2 }, Constraint { variables: array![41], rhs: 1 }, Constraint { variables: array![41, 42, 57, 72], rhs: 1 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 42, 57, 72];
    let sp_nbrs: Array<u32> = array![57, 72];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 71, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 45, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 18733638, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2741508, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s057 c8');
}
#[test]
fn sq15_exact_s2_f090() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![104];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![109, 110, 122, 123, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![122, 123, 151, 152, 153], rhs: 4 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 39, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 749398, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 202540, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 10660, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s012 c8');
}
#[test]
fn sq15_exact_s2_f091() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![6, 12, 21, 22, 23, 24, 25, 26, 27, 42, 49, 52, 55, 56, 57, 58, 59, 71, 72, 80, 84, 100, 104, 113, 122, 123, 133, 137, 141, 144, 156, 158, 169, 180, 195, 196, 197, 201, 207, 212, 216, 218, 220, 222];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![12, 27], rhs: 0 }, Constraint { variables: array![21, 22, 23, 52], rhs: 2 }, Constraint { variables: array![21, 22, 52], rhs: 2 }, Constraint { variables: array![21, 49], rhs: 2 }, Constraint { variables: array![22, 23, 24, 52], rhs: 1 }, Constraint { variables: array![23, 24, 25, 55], rhs: 1 }, Constraint { variables: array![24, 25, 26, 55, 56], rhs: 2 }, Constraint { variables: array![25, 26, 27, 42, 55, 56, 57], rhs: 4 }, Constraint { variables: array![27, 42, 57, 58, 59], rhs: 4 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![49, 80], rhs: 2 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 80], rhs: 2 }, Constraint { variables: array![52, 84], rhs: 2 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 56, 71, 84], rhs: 4 }, Constraint { variables: array![55, 84], rhs: 2 }, Constraint { variables: array![57, 58, 59, 72], rhs: 4 }, Constraint { variables: array![58, 59], rhs: 2 }, Constraint { variables: array![71, 72], rhs: 2 }, Constraint { variables: array![71, 72, 100], rhs: 3 }, Constraint { variables: array![71, 84, 100], rhs: 3 }, Constraint { variables: array![72, 104], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 100, 113], rhs: 3 }, Constraint { variables: array![84, 113], rhs: 2 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 113], rhs: 2 }, Constraint { variables: array![104], rhs: 1 }, Constraint { variables: array![104, 133], rhs: 2 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 141], rhs: 2 }, Constraint { variables: array![113, 144], rhs: 2 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 137], rhs: 3 }, Constraint { variables: array![122, 137], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![133], rhs: 1 }, Constraint { variables: array![137], rhs: 1 }, Constraint { variables: array![137, 169], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 156], rhs: 2 }, Constraint { variables: array![141, 156, 158], rhs: 3 }, Constraint { variables: array![141, 156, 169], rhs: 3 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 158], rhs: 2 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 158], rhs: 2 }, Constraint { variables: array![156, 169], rhs: 2 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![169], rhs: 1 }, Constraint { variables: array![169, 197], rhs: 2 }, Constraint { variables: array![169, 201], rhs: 2 }, Constraint { variables: array![180], rhs: 1 }, Constraint { variables: array![180, 195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 2 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216], rhs: 2 }, Constraint { variables: array![201, 216, 218], rhs: 3 }, Constraint { variables: array![207], rhs: 1 }, Constraint { variables: array![207, 220, 222], rhs: 3 }, Constraint { variables: array![207, 222], rhs: 2 }, Constraint { variables: array![218], rhs: 1 }, Constraint { variables: array![218, 220], rhs: 2 }, Constraint { variables: array![220], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 7, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 7, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00265g2f07_s002 c8');
}
#[test]
fn sq15_exact_s2_f092() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![13, 23, 27, 28, 29, 44, 52, 55, 66, 67, 68, 78, 85, 99, 109, 121, 123, 128, 139, 147, 148, 149, 156, 157, 161, 162, 163, 168, 172, 173, 176, 178, 187, 188, 189, 190, 191, 192, 193, 202, 217];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![13, 27, 28], rhs: 1 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 52], rhs: 2 }, Constraint { variables: array![23, 55], rhs: 2 }, Constraint { variables: array![27], rhs: 1 }, Constraint { variables: array![27, 28], rhs: 1 }, Constraint { variables: array![27, 28, 29, 44], rhs: 2 }, Constraint { variables: array![27, 55], rhs: 2 }, Constraint { variables: array![44], rhs: 1 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 66, 67], rhs: 3 }, Constraint { variables: array![52, 67, 68], rhs: 3 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 68], rhs: 2 }, Constraint { variables: array![55, 68, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 67], rhs: 2 }, Constraint { variables: array![66, 67, 68], rhs: 3 }, Constraint { variables: array![67, 68, 99], rhs: 3 }, Constraint { variables: array![68, 85, 99], rhs: 3 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 109], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 123], rhs: 2 }, Constraint { variables: array![109, 123, 139], rhs: 3 }, Constraint { variables: array![109, 139], rhs: 2 }, Constraint { variables: array![121], rhs: 1 }, Constraint { variables: array![121, 123], rhs: 2 }, Constraint { variables: array![123, 139], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![139, 156], rhs: 2 }, Constraint { variables: array![139, 168], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 148], rhs: 1 }, Constraint { variables: array![147, 148, 149], rhs: 2 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![148, 149], rhs: 1 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 157], rhs: 2 }, Constraint { variables: array![156, 157, 172, 187], rhs: 4 }, Constraint { variables: array![157, 172, 173], rhs: 3 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 4 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![172, 187, 202], rhs: 3 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![17, 30];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![17], rhs: 1 }, Constraint { variables: array![17, 30], rhs: 2 }, Constraint { variables: array![30], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![212];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![212], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 18, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1377, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s007 c8');
}
#[test]
fn sq15_exact_s2_f093() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![13, 23, 27, 28, 29, 44, 52, 55, 66, 67, 68, 78, 85, 99, 109, 121, 123, 128, 139, 147, 148, 149, 156, 157, 161, 162, 163, 168, 172, 173, 176, 178, 187, 188, 189, 190, 191, 192, 193, 202, 217];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![13, 27, 28], rhs: 1 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 52], rhs: 2 }, Constraint { variables: array![23, 55], rhs: 2 }, Constraint { variables: array![27], rhs: 1 }, Constraint { variables: array![27, 28], rhs: 1 }, Constraint { variables: array![27, 28, 29, 44], rhs: 2 }, Constraint { variables: array![27, 55], rhs: 2 }, Constraint { variables: array![44], rhs: 1 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 66, 67], rhs: 3 }, Constraint { variables: array![52, 67, 68], rhs: 3 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 68], rhs: 2 }, Constraint { variables: array![55, 68, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 67], rhs: 2 }, Constraint { variables: array![66, 67, 68], rhs: 3 }, Constraint { variables: array![67, 68, 99], rhs: 3 }, Constraint { variables: array![68, 85, 99], rhs: 3 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 109], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 123], rhs: 2 }, Constraint { variables: array![109, 123, 139], rhs: 3 }, Constraint { variables: array![109, 139], rhs: 2 }, Constraint { variables: array![121], rhs: 1 }, Constraint { variables: array![121, 123], rhs: 2 }, Constraint { variables: array![123, 139], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![139, 156], rhs: 2 }, Constraint { variables: array![139, 168], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 148], rhs: 1 }, Constraint { variables: array![147, 148, 149], rhs: 2 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![148, 149], rhs: 1 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 157], rhs: 2 }, Constraint { variables: array![156, 157, 172, 187], rhs: 4 }, Constraint { variables: array![157, 172, 173], rhs: 3 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 4 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![172, 187, 202], rhs: 3 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![17, 30];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![17], rhs: 1 }, Constraint { variables: array![17, 30], rhs: 2 }, Constraint { variables: array![30], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![212];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![212], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 18, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1377, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s008 c8');
}
#[test]
fn sq15_exact_s2_f094() {
    let sp_vars: Array<u32> = array![103, 104];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![103, 104], rhs: 1 }];
    let sp_hint: Array<u32> = array![103, 104];
    let sp_nbrs: Array<u32> = array![103];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 87, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![33, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 62], rhs: 2 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![39, 40, 51, 56, 57, 67, 68, 84, 98, 112, 116, 117, 132, 138, 140, 142, 144, 146, 147, 156, 157, 158, 159, 161, 170, 176, 180, 181, 185, 186, 187, 188, 189, 190, 191, 196, 200, 211, 212, 213, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 40], rhs: 2 }, Constraint { variables: array![39, 40, 56], rhs: 2 }, Constraint { variables: array![39, 40, 68], rhs: 3 }, Constraint { variables: array![39, 67, 68], rhs: 3 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 56, 57], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 67], rhs: 2 }, Constraint { variables: array![51, 67, 68], rhs: 3 }, Constraint { variables: array![56, 57], rhs: 1 }, Constraint { variables: array![56, 84], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 68, 84, 98], rhs: 4 }, Constraint { variables: array![67, 68, 98], rhs: 3 }, Constraint { variables: array![68, 84], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 98], rhs: 2 }, Constraint { variables: array![84, 116], rhs: 2 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 112], rhs: 2 }, Constraint { variables: array![112], rhs: 1 }, Constraint { variables: array![112, 140, 142], rhs: 3 }, Constraint { variables: array![112, 142], rhs: 2 }, Constraint { variables: array![112, 142, 144], rhs: 3 }, Constraint { variables: array![116], rhs: 1 }, Constraint { variables: array![116, 117], rhs: 1 }, Constraint { variables: array![116, 117, 132, 146, 147], rhs: 1 }, Constraint { variables: array![116, 144, 146], rhs: 2 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 140], rhs: 2 }, Constraint { variables: array![138, 140, 170], rhs: 3 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 142, 156, 157], rhs: 4 }, Constraint { variables: array![140, 156, 170], rhs: 3 }, Constraint { variables: array![142, 144, 157, 158, 159], rhs: 5 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 146, 159, 161], rhs: 3 }, Constraint { variables: array![144, 146, 159, 161, 176], rhs: 3 }, Constraint { variables: array![156, 157, 158, 186, 187, 188], rhs: 3 }, Constraint { variables: array![156, 157, 170, 185, 186, 187], rhs: 4 }, Constraint { variables: array![157, 158, 159, 187, 188, 189], rhs: 3 }, Constraint { variables: array![158, 159, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![170, 185], rhs: 2 }, Constraint { variables: array![170, 185, 200], rhs: 3 }, Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![181], rhs: 1 }, Constraint { variables: array![181, 196], rhs: 1 }, Constraint { variables: array![181, 196, 211, 212, 213], rhs: 2 }, Constraint { variables: array![185, 200, 213, 214, 215], rhs: 3 }, Constraint { variables: array![212, 213, 214], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 35, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 9970840, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 9970840, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f02_s003 c8');
}
#[test]
fn sq15_exact_s2_f095() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![66, 67, 68, 69, 70, 79, 80, 81, 85, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 170, 171, 172, 173, 178, 179, 185, 193, 194, 200, 215];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![66, 67, 68, 81, 96, 98], rhs: 3 }, Constraint { variables: array![67, 68, 69, 98], rhs: 1 }, Constraint { variables: array![68, 69, 70, 85, 98, 100], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![85, 98, 100, 114], rhs: 3 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![170, 171, 172, 185, 200], rhs: 2 }, Constraint { variables: array![171, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![185, 200, 215], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![200, 215], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 118, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 161429102720087305194, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s047 c8');
}
#[test]
fn sq15_exact_s2_f096() {
    let sp_vars: Array<u32> = array![212];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![212], rhs: 1 }];
    let sp_hint: Array<u32> = array![212];
    let sp_nbrs: Array<u32> = array![212];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 198, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![13, 23, 27, 28, 29, 44, 52, 55, 66, 67, 68, 78, 85, 99, 109, 121, 123, 128, 139, 147, 148, 149, 156, 157, 161, 162, 163, 168, 172, 173, 176, 178, 187, 188, 189, 190, 191, 192, 193, 202, 217];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![13, 27, 28], rhs: 1 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 52], rhs: 2 }, Constraint { variables: array![23, 55], rhs: 2 }, Constraint { variables: array![27], rhs: 1 }, Constraint { variables: array![27, 28], rhs: 1 }, Constraint { variables: array![27, 28, 29, 44], rhs: 2 }, Constraint { variables: array![27, 55], rhs: 2 }, Constraint { variables: array![44], rhs: 1 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 66, 67], rhs: 3 }, Constraint { variables: array![52, 67, 68], rhs: 3 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 68], rhs: 2 }, Constraint { variables: array![55, 68, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 67], rhs: 2 }, Constraint { variables: array![66, 67, 68], rhs: 3 }, Constraint { variables: array![67, 68, 99], rhs: 3 }, Constraint { variables: array![68, 85, 99], rhs: 3 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 109], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 123], rhs: 2 }, Constraint { variables: array![109, 123, 139], rhs: 3 }, Constraint { variables: array![109, 139], rhs: 2 }, Constraint { variables: array![121], rhs: 1 }, Constraint { variables: array![121, 123], rhs: 2 }, Constraint { variables: array![123, 139], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![139, 156], rhs: 2 }, Constraint { variables: array![139, 168], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 148], rhs: 1 }, Constraint { variables: array![147, 148, 149], rhs: 2 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![148, 149], rhs: 1 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 157], rhs: 2 }, Constraint { variables: array![156, 157, 172, 187], rhs: 4 }, Constraint { variables: array![157, 172, 173], rhs: 3 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 4 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![172, 187, 202], rhs: 3 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![17, 30];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![17], rhs: 1 }, Constraint { variables: array![17, 30], rhs: 2 }, Constraint { variables: array![30], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 18, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1377, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s005 c8');
}
#[test]
fn sq15_exact_s2_f097() {
    let sp_vars: Array<u32> = array![212];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![212], rhs: 1 }];
    let sp_hint: Array<u32> = array![212];
    let sp_nbrs: Array<u32> = array![212];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 213, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![13, 23, 27, 28, 29, 44, 52, 55, 66, 67, 68, 78, 85, 99, 109, 121, 123, 128, 139, 147, 148, 149, 156, 157, 161, 162, 163, 168, 172, 173, 176, 178, 187, 188, 189, 190, 191, 192, 193, 202, 217];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![13, 27, 28], rhs: 1 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 52], rhs: 2 }, Constraint { variables: array![23, 55], rhs: 2 }, Constraint { variables: array![27], rhs: 1 }, Constraint { variables: array![27, 28], rhs: 1 }, Constraint { variables: array![27, 28, 29, 44], rhs: 2 }, Constraint { variables: array![27, 55], rhs: 2 }, Constraint { variables: array![44], rhs: 1 }, Constraint { variables: array![52], rhs: 1 }, Constraint { variables: array![52, 66, 67], rhs: 3 }, Constraint { variables: array![52, 67, 68], rhs: 3 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 68], rhs: 2 }, Constraint { variables: array![55, 68, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![66], rhs: 1 }, Constraint { variables: array![66, 67], rhs: 2 }, Constraint { variables: array![66, 67, 68], rhs: 3 }, Constraint { variables: array![67, 68, 99], rhs: 3 }, Constraint { variables: array![68, 85, 99], rhs: 3 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![78, 109], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 123], rhs: 2 }, Constraint { variables: array![109, 123, 139], rhs: 3 }, Constraint { variables: array![109, 139], rhs: 2 }, Constraint { variables: array![121], rhs: 1 }, Constraint { variables: array![121, 123], rhs: 2 }, Constraint { variables: array![123, 139], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![139, 156], rhs: 2 }, Constraint { variables: array![139, 168], rhs: 2 }, Constraint { variables: array![147], rhs: 1 }, Constraint { variables: array![147, 148], rhs: 1 }, Constraint { variables: array![147, 148, 149], rhs: 2 }, Constraint { variables: array![147, 161, 162], rhs: 3 }, Constraint { variables: array![148, 149], rhs: 1 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 157], rhs: 2 }, Constraint { variables: array![156, 157, 172, 187], rhs: 4 }, Constraint { variables: array![157, 172, 173], rhs: 3 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163, 176, 178, 191, 192, 193], rhs: 4 }, Constraint { variables: array![161, 176], rhs: 2 }, Constraint { variables: array![161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![168], rhs: 1 }, Constraint { variables: array![172, 187, 202], rhs: 3 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![173, 188, 189, 190], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![17, 30];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![17], rhs: 1 }, Constraint { variables: array![17, 30], rhs: 2 }, Constraint { variables: array![30], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 18, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1377, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00291g1f06_s006 c8');
}
#[test]
fn sq15_exact_s2_f098() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![66, 67, 68, 69, 70, 79, 80, 81, 85, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 172, 173, 178, 179, 187, 193, 202, 208, 217, 223];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![66, 67, 68, 81, 96, 98], rhs: 3 }, Constraint { variables: array![67, 68, 69, 98], rhs: 1 }, Constraint { variables: array![68, 69, 70, 85, 98, 100], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![85, 98, 100, 114], rhs: 3 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173, 187, 202], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![178, 193, 208], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 0 }, Constraint { variables: array![193, 208, 223], rhs: 1 }, Constraint { variables: array![202, 217], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 129, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4155829554544690393800, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s034 c8');
}
#[test]
fn sq15_exact_s2_f099() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![66, 67, 68, 69, 70, 79, 80, 81, 85, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 172, 173, 178, 179, 187, 193, 202, 208, 217, 223];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![66, 67, 68, 81, 96, 98], rhs: 3 }, Constraint { variables: array![67, 68, 69, 98], rhs: 1 }, Constraint { variables: array![68, 69, 70, 85, 98, 100], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![85, 98, 100, 114], rhs: 3 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173, 187, 202], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![178, 193, 208], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 0 }, Constraint { variables: array![193, 208, 223], rhs: 1 }, Constraint { variables: array![202, 217], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 129, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4155829554544690393800, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s035 c8');
}
#[test]
fn sq15_exact_s2_f100() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![66, 67, 68, 69, 70, 79, 80, 81, 85, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 172, 173, 178, 179, 187, 193, 202, 208, 217, 223];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![66, 67, 68, 81, 96, 98], rhs: 3 }, Constraint { variables: array![67, 68, 69, 98], rhs: 1 }, Constraint { variables: array![68, 69, 70, 85, 98, 100], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![85, 98, 100, 114], rhs: 3 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173, 187, 202], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![178, 193, 208], rhs: 2 }, Constraint { variables: array![187, 202, 217], rhs: 0 }, Constraint { variables: array![193, 208, 223], rhs: 1 }, Constraint { variables: array![202, 217], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 129, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4155829554544690393800, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f00_s036 c8');
}
#[test]
fn sq15_exact_s2_f101() {
    let sp_vars: Array<u32> = array![11, 12, 27, 42, 57, 67, 71, 72, 84, 85];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![11], rhs: 1 }, Constraint { variables: array![11, 12, 27, 42], rhs: 2 }, Constraint { variables: array![27, 42, 57], rhs: 2 }, Constraint { variables: array![42, 57, 71, 72], rhs: 3 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 84], rhs: 2 }, Constraint { variables: array![71], rhs: 1 }, Constraint { variables: array![71, 72, 85], rhs: 2 }, Constraint { variables: array![71, 84, 85], rhs: 3 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 85], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }];
    let sp_hint: Array<u32> = array![67, 84, 85, 11, 12, 27, 42, 57, 71, 72];
    let sp_nbrs: Array<u32> = array![71, 72];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 87, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![4, 5, 17, 18, 19, 31, 32, 34, 46, 48, 61, 76, 91, 106, 108, 109, 110, 121, 126, 132, 133, 136, 137, 138, 147, 151, 153, 162, 166, 167, 168, 169, 176, 177, 184, 185, 186, 187, 188, 189, 190, 191];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![4, 5, 19, 34], rhs: 2 }, Constraint { variables: array![5], rhs: 1 }, Constraint { variables: array![17, 18, 19, 32, 34, 48], rhs: 3 }, Constraint { variables: array![19, 34], rhs: 1 }, Constraint { variables: array![31, 32, 46, 48, 61], rhs: 3 }, Constraint { variables: array![34], rhs: 1 }, Constraint { variables: array![34, 48], rhs: 2 }, Constraint { variables: array![46, 48, 61, 76], rhs: 2 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![61, 76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106, 108], rhs: 1 }, Constraint { variables: array![91, 106, 108, 121], rhs: 2 }, Constraint { variables: array![106, 108, 121, 136, 137, 138], rhs: 4 }, Constraint { variables: array![108, 109], rhs: 2 }, Constraint { variables: array![108, 109, 110], rhs: 3 }, Constraint { variables: array![108, 109, 110, 138], rhs: 4 }, Constraint { variables: array![108, 109, 137, 138], rhs: 4 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 126], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![110, 126], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![132], rhs: 1 }, Constraint { variables: array![132, 133], rhs: 1 }, Constraint { variables: array![132, 147], rhs: 1 }, Constraint { variables: array![132, 147, 162], rhs: 1 }, Constraint { variables: array![136, 137, 138, 151, 153, 166, 167, 168], rhs: 5 }, Constraint { variables: array![138, 153], rhs: 2 }, Constraint { variables: array![138, 153, 168, 169], rhs: 4 }, Constraint { variables: array![147, 162, 176, 177], rhs: 1 }, Constraint { variables: array![169], rhs: 1 }, Constraint { variables: array![169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![176], rhs: 1 }, Constraint { variables: array![176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 2 }, Constraint { variables: array![187, 188, 189], rhs: 1 }, Constraint { variables: array![188, 189, 190], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 72, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 5356762560, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 552665988, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s001 c8');
}
#[test]
fn sq15_exact_s2_f102() {
    let sp_vars: Array<u32> = array![11, 12, 27, 42, 57, 67, 71, 72, 73, 84, 85];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![11], rhs: 1 }, Constraint { variables: array![11, 12, 27, 42], rhs: 2 }, Constraint { variables: array![27, 42, 57], rhs: 2 }, Constraint { variables: array![42, 57, 71, 72], rhs: 3 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 84], rhs: 2 }, Constraint { variables: array![71], rhs: 1 }, Constraint { variables: array![71, 72, 73], rhs: 1 }, Constraint { variables: array![71, 72, 85], rhs: 2 }, Constraint { variables: array![71, 84, 85], rhs: 3 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 85], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }];
    let sp_hint: Array<u32> = array![67, 73, 84, 85, 11, 12, 27, 42, 57, 71, 72];
    let sp_nbrs: Array<u32> = array![72, 73];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 88, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![4, 5, 17, 18, 19, 31, 32, 34, 46, 48, 61, 76, 91, 106, 108, 109, 110, 121, 126, 132, 133, 136, 137, 138, 147, 151, 153, 162, 166, 167, 168, 169, 176, 177, 184, 185, 186, 187, 188, 189, 190, 191];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![4, 5, 19, 34], rhs: 2 }, Constraint { variables: array![5], rhs: 1 }, Constraint { variables: array![17, 18, 19, 32, 34, 48], rhs: 3 }, Constraint { variables: array![19, 34], rhs: 1 }, Constraint { variables: array![31, 32, 46, 48, 61], rhs: 3 }, Constraint { variables: array![34], rhs: 1 }, Constraint { variables: array![34, 48], rhs: 2 }, Constraint { variables: array![46, 48, 61, 76], rhs: 2 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![61, 76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106, 108], rhs: 1 }, Constraint { variables: array![91, 106, 108, 121], rhs: 2 }, Constraint { variables: array![106, 108, 121, 136, 137, 138], rhs: 4 }, Constraint { variables: array![108, 109], rhs: 2 }, Constraint { variables: array![108, 109, 110], rhs: 3 }, Constraint { variables: array![108, 109, 110, 138], rhs: 4 }, Constraint { variables: array![108, 109, 137, 138], rhs: 4 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 126], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![110, 126], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![132], rhs: 1 }, Constraint { variables: array![132, 133], rhs: 1 }, Constraint { variables: array![132, 147], rhs: 1 }, Constraint { variables: array![132, 147, 162], rhs: 1 }, Constraint { variables: array![136, 137, 138, 151, 153, 166, 167, 168], rhs: 5 }, Constraint { variables: array![138, 153], rhs: 2 }, Constraint { variables: array![138, 153, 168, 169], rhs: 4 }, Constraint { variables: array![147, 162, 176, 177], rhs: 1 }, Constraint { variables: array![169], rhs: 1 }, Constraint { variables: array![169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![176], rhs: 1 }, Constraint { variables: array![176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 2 }, Constraint { variables: array![187, 188, 189], rhs: 1 }, Constraint { variables: array![188, 189, 190], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 69, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 3955956576, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1281190482, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 116707635, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 2907867, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s002 c8');
}
#[test]
fn sq15_exact_s2_f103() {
    let sp_vars: Array<u32> = array![11, 12, 27, 42, 57, 67, 71, 72, 73, 74, 84, 85, 89, 104];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![11], rhs: 1 }, Constraint { variables: array![11, 12, 27, 42], rhs: 2 }, Constraint { variables: array![27, 42, 57], rhs: 2 }, Constraint { variables: array![42, 57, 71, 72], rhs: 3 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 84], rhs: 2 }, Constraint { variables: array![71], rhs: 1 }, Constraint { variables: array![71, 72, 73], rhs: 1 }, Constraint { variables: array![71, 72, 85], rhs: 2 }, Constraint { variables: array![71, 84, 85], rhs: 3 }, Constraint { variables: array![72, 73, 74, 89, 104], rhs: 1 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 85], rhs: 2 }, Constraint { variables: array![85], rhs: 1 }];
    let sp_hint: Array<u32> = array![67, 84, 85, 11, 12, 27, 42, 57, 71, 72, 73, 74, 89, 104];
    let sp_nbrs: Array<u32> = array![89, 104];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 103, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![4, 5, 17, 18, 19, 31, 32, 34, 46, 48, 61, 76, 91, 106, 108, 109, 110, 121, 126, 132, 133, 136, 137, 138, 147, 151, 153, 162, 166, 167, 168, 169, 176, 177, 184, 185, 186, 187, 188, 189, 190, 191];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![4, 5, 19, 34], rhs: 2 }, Constraint { variables: array![5], rhs: 1 }, Constraint { variables: array![17, 18, 19, 32, 34, 48], rhs: 3 }, Constraint { variables: array![19, 34], rhs: 1 }, Constraint { variables: array![31, 32, 46, 48, 61], rhs: 3 }, Constraint { variables: array![34], rhs: 1 }, Constraint { variables: array![34, 48], rhs: 2 }, Constraint { variables: array![46, 48, 61, 76], rhs: 2 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![61, 76, 91], rhs: 1 }, Constraint { variables: array![76, 91, 106, 108], rhs: 1 }, Constraint { variables: array![91, 106, 108, 121], rhs: 2 }, Constraint { variables: array![106, 108, 121, 136, 137, 138], rhs: 4 }, Constraint { variables: array![108, 109], rhs: 2 }, Constraint { variables: array![108, 109, 110], rhs: 3 }, Constraint { variables: array![108, 109, 110, 138], rhs: 4 }, Constraint { variables: array![108, 109, 137, 138], rhs: 4 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 126], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![110, 126], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![132], rhs: 1 }, Constraint { variables: array![132, 133], rhs: 1 }, Constraint { variables: array![132, 147], rhs: 1 }, Constraint { variables: array![132, 147, 162], rhs: 1 }, Constraint { variables: array![136, 137, 138, 151, 153, 166, 167, 168], rhs: 5 }, Constraint { variables: array![138, 153], rhs: 2 }, Constraint { variables: array![138, 153, 168, 169], rhs: 4 }, Constraint { variables: array![147, 162, 176, 177], rhs: 1 }, Constraint { variables: array![169], rhs: 1 }, Constraint { variables: array![169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![176], rhs: 1 }, Constraint { variables: array![176, 189, 190, 191], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 2 }, Constraint { variables: array![187, 188, 189], rhs: 1 }, Constraint { variables: array![188, 189, 190], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 68, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 390904800, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 817968294, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 72317388, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00347g0f03_s003 c8');
}
#[test]
fn sq15_exact_s2_f104() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 42];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }, Constraint { variables: array![24, 25, 26, 41], rhs: 2 }, Constraint { variables: array![41], rhs: 1 }, Constraint { variables: array![41, 42], rhs: 1 }];
    let sp_hint: Array<u32> = array![6, 42, 21, 22, 23, 24, 25, 26, 41];
    let sp_nbrs: Array<u32> = array![41, 42];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 57, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 92, 98, 99, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![83, 98, 99], rhs: 2 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 42, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 12192908, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 5775588, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 740460, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 24682, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s061 c8');
}
#[test]
fn sq15_exact_s2_f105() {
    let sp_vars: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 42, 43, 58, 73];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![21], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25], rhs: 1 }, Constraint { variables: array![24, 25, 26, 41], rhs: 2 }, Constraint { variables: array![41], rhs: 1 }, Constraint { variables: array![41, 42], rhs: 1 }, Constraint { variables: array![41, 42, 43, 58, 73], rhs: 3 }];
    let sp_hint: Array<u32> = array![6, 21, 22, 23, 24, 25, 26, 41, 42, 43, 58, 73];
    let sp_nbrs: Array<u32> = array![58, 73];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 72, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![0, 15, 30, 45, 46, 61, 76, 77, 83, 92, 98, 99, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![0, 15], rhs: 1 }, Constraint { variables: array![0, 15, 30], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46], rhs: 2 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 61], rhs: 1 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![83, 98, 99], rhs: 2 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 41, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 447720, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 269780, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 22960, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s062 c8');
}
#[test]
fn sq15_exact_s2_f106() {
    let sp_vars: Array<u32> = array![180, 181, 196];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![181], rhs: 1 }, Constraint { variables: array![181, 196], rhs: 1 }];
    let sp_hint: Array<u32> = array![180, 181, 196];
    let sp_nbrs: Array<u32> = array![181, 196];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 197, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![33, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 62], rhs: 2 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![39, 40, 51, 56, 57, 67, 68, 71, 72, 84, 86, 87, 98, 101, 102, 103, 104, 112, 116, 131, 138, 140, 142, 144, 146, 156, 157, 158, 159, 161, 170, 176, 185, 186, 187, 188, 189, 190, 191, 200];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 40], rhs: 2 }, Constraint { variables: array![39, 40, 56, 71], rhs: 2 }, Constraint { variables: array![39, 40, 68], rhs: 3 }, Constraint { variables: array![39, 67, 68], rhs: 3 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 56, 57], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 67], rhs: 2 }, Constraint { variables: array![51, 67, 68], rhs: 3 }, Constraint { variables: array![56, 57], rhs: 1 }, Constraint { variables: array![56, 71, 84, 86], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 72], rhs: 1 }, Constraint { variables: array![57, 72, 87], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 68, 84, 98], rhs: 4 }, Constraint { variables: array![67, 68, 98], rhs: 3 }, Constraint { variables: array![68, 84], rhs: 2 }, Constraint { variables: array![71, 84, 86, 101], rhs: 1 }, Constraint { variables: array![72, 87, 102, 103, 104], rhs: 1 }, Constraint { variables: array![84, 86, 101, 116], rhs: 2 }, Constraint { variables: array![84, 98], rhs: 2 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 112], rhs: 2 }, Constraint { variables: array![101, 116, 131], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![112], rhs: 1 }, Constraint { variables: array![112, 140, 142], rhs: 3 }, Constraint { variables: array![112, 142], rhs: 2 }, Constraint { variables: array![112, 142, 144], rhs: 3 }, Constraint { variables: array![116, 131, 144, 146], rhs: 2 }, Constraint { variables: array![131, 144, 146, 159, 161], rhs: 3 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 140], rhs: 2 }, Constraint { variables: array![138, 140, 170], rhs: 3 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 142, 156, 157], rhs: 4 }, Constraint { variables: array![140, 156, 170], rhs: 3 }, Constraint { variables: array![142, 144, 157, 158, 159], rhs: 5 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 146, 159, 161, 176], rhs: 3 }, Constraint { variables: array![156, 157, 158, 186, 187, 188], rhs: 3 }, Constraint { variables: array![156, 157, 170, 185, 186, 187], rhs: 4 }, Constraint { variables: array![157, 158, 159, 187, 188, 189], rhs: 3 }, Constraint { variables: array![158, 159, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![170, 185], rhs: 2 }, Constraint { variables: array![170, 185, 200], rhs: 3 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 40, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 153809370, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 111861360, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 23030280, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 1316016, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s004 c8');
}
#[test]
fn sq15_exact_s2_f107() {
    let sp_vars: Array<u32> = array![180, 181, 196, 211, 212, 213];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![181], rhs: 1 }, Constraint { variables: array![181, 196], rhs: 1 }, Constraint { variables: array![181, 196, 211, 212, 213], rhs: 2 }];
    let sp_hint: Array<u32> = array![180, 181, 196, 211, 212, 213];
    let sp_nbrs: Array<u32> = array![212, 213];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 198, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![33, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 62], rhs: 2 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![39, 40, 51, 56, 57, 67, 68, 71, 72, 84, 86, 87, 98, 101, 102, 103, 104, 112, 116, 131, 138, 140, 142, 144, 146, 156, 157, 158, 159, 161, 170, 176, 185, 186, 187, 188, 189, 190, 191, 200];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 40], rhs: 2 }, Constraint { variables: array![39, 40, 56, 71], rhs: 2 }, Constraint { variables: array![39, 40, 68], rhs: 3 }, Constraint { variables: array![39, 67, 68], rhs: 3 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 56, 57], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 67], rhs: 2 }, Constraint { variables: array![51, 67, 68], rhs: 3 }, Constraint { variables: array![56, 57], rhs: 1 }, Constraint { variables: array![56, 71, 84, 86], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 72], rhs: 1 }, Constraint { variables: array![57, 72, 87], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 68, 84, 98], rhs: 4 }, Constraint { variables: array![67, 68, 98], rhs: 3 }, Constraint { variables: array![68, 84], rhs: 2 }, Constraint { variables: array![71, 84, 86, 101], rhs: 1 }, Constraint { variables: array![72, 87, 102, 103, 104], rhs: 1 }, Constraint { variables: array![84, 86, 101, 116], rhs: 2 }, Constraint { variables: array![84, 98], rhs: 2 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 112], rhs: 2 }, Constraint { variables: array![101, 116, 131], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![112], rhs: 1 }, Constraint { variables: array![112, 140, 142], rhs: 3 }, Constraint { variables: array![112, 142], rhs: 2 }, Constraint { variables: array![112, 142, 144], rhs: 3 }, Constraint { variables: array![116, 131, 144, 146], rhs: 2 }, Constraint { variables: array![131, 144, 146, 159, 161], rhs: 3 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 140], rhs: 2 }, Constraint { variables: array![138, 140, 170], rhs: 3 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 142, 156, 157], rhs: 4 }, Constraint { variables: array![140, 156, 170], rhs: 3 }, Constraint { variables: array![142, 144, 157, 158, 159], rhs: 5 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 146, 159, 161, 176], rhs: 3 }, Constraint { variables: array![156, 157, 158, 186, 187, 188], rhs: 3 }, Constraint { variables: array![156, 157, 170, 185, 186, 187], rhs: 4 }, Constraint { variables: array![157, 158, 159, 187, 188, 189], rhs: 3 }, Constraint { variables: array![158, 159, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![170, 185], rhs: 2 }, Constraint { variables: array![170, 185, 200], rhs: 3 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 39, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 30761874, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 68048994, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 13050492, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s005 c8');
}
#[test]
fn sq15_exact_s2_f108() {
    let sp_vars: Array<u32> = array![180, 181];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![181], rhs: 1 }];
    let sp_hint: Array<u32> = array![180, 181];
    let sp_nbrs: Array<u32> = array![181];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 182, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![33, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 62], rhs: 2 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![39, 40, 51, 56, 57, 67, 68, 71, 72, 84, 86, 87, 98, 101, 102, 103, 104, 112, 116, 131, 138, 140, 142, 144, 146, 156, 157, 158, 159, 161, 170, 176, 185, 186, 187, 188, 189, 190, 191];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 40], rhs: 2 }, Constraint { variables: array![39, 40, 56, 71], rhs: 2 }, Constraint { variables: array![39, 40, 68], rhs: 3 }, Constraint { variables: array![39, 67, 68], rhs: 3 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 56, 57], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 67], rhs: 2 }, Constraint { variables: array![51, 67, 68], rhs: 3 }, Constraint { variables: array![56, 57], rhs: 1 }, Constraint { variables: array![56, 71, 84, 86], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 72], rhs: 1 }, Constraint { variables: array![57, 72, 87], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 68, 84, 98], rhs: 4 }, Constraint { variables: array![67, 68, 98], rhs: 3 }, Constraint { variables: array![68, 84], rhs: 2 }, Constraint { variables: array![71, 84, 86, 101], rhs: 1 }, Constraint { variables: array![72, 87, 102, 103, 104], rhs: 1 }, Constraint { variables: array![84, 86, 101, 116], rhs: 2 }, Constraint { variables: array![84, 98], rhs: 2 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 112], rhs: 2 }, Constraint { variables: array![101, 116, 131], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![112], rhs: 1 }, Constraint { variables: array![112, 140, 142], rhs: 3 }, Constraint { variables: array![112, 142], rhs: 2 }, Constraint { variables: array![112, 142, 144], rhs: 3 }, Constraint { variables: array![116, 131, 144, 146], rhs: 2 }, Constraint { variables: array![131, 144, 146, 159, 161], rhs: 3 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 140], rhs: 2 }, Constraint { variables: array![138, 140, 170], rhs: 3 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 142, 156, 157], rhs: 4 }, Constraint { variables: array![140, 156, 170], rhs: 3 }, Constraint { variables: array![142, 144, 157, 158, 159], rhs: 5 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 146, 159, 161, 176], rhs: 3 }, Constraint { variables: array![156, 157, 158, 186, 187, 188], rhs: 3 }, Constraint { variables: array![156, 157, 170, 185, 186, 187], rhs: 4 }, Constraint { variables: array![157, 158, 159, 187, 188, 189], rhs: 3 }, Constraint { variables: array![158, 159, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![170, 185], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 45, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1772326270, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 1293319170, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 272277720, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 16290120, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s001 c8');
}
#[test]
fn sq15_exact_s2_f109() {
    let sp_vars: Array<u32> = array![180, 181, 196, 197, 198];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![181], rhs: 1 }, Constraint { variables: array![181, 196, 197, 198], rhs: 1 }];
    let sp_hint: Array<u32> = array![180, 181, 196, 197, 198];
    let sp_nbrs: Array<u32> = array![197, 198];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 183, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![33, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 62], rhs: 2 }, Constraint { variables: array![62], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![39, 40, 51, 56, 57, 67, 68, 71, 72, 84, 86, 87, 98, 101, 102, 103, 104, 112, 116, 131, 138, 140, 142, 144, 146, 156, 157, 158, 159, 161, 170, 176, 185, 186, 187, 188, 189, 190, 191];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 40], rhs: 2 }, Constraint { variables: array![39, 40, 56, 71], rhs: 2 }, Constraint { variables: array![39, 40, 68], rhs: 3 }, Constraint { variables: array![39, 67, 68], rhs: 3 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 56, 57], rhs: 2 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 67], rhs: 2 }, Constraint { variables: array![51, 67, 68], rhs: 3 }, Constraint { variables: array![56, 57], rhs: 1 }, Constraint { variables: array![56, 71, 84, 86], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 72], rhs: 1 }, Constraint { variables: array![57, 72, 87], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 68, 84, 98], rhs: 4 }, Constraint { variables: array![67, 68, 98], rhs: 3 }, Constraint { variables: array![68, 84], rhs: 2 }, Constraint { variables: array![71, 84, 86, 101], rhs: 1 }, Constraint { variables: array![72, 87, 102, 103, 104], rhs: 1 }, Constraint { variables: array![84, 86, 101, 116], rhs: 2 }, Constraint { variables: array![84, 98], rhs: 2 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 112], rhs: 2 }, Constraint { variables: array![101, 116, 131], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![112], rhs: 1 }, Constraint { variables: array![112, 140, 142], rhs: 3 }, Constraint { variables: array![112, 142], rhs: 2 }, Constraint { variables: array![112, 142, 144], rhs: 3 }, Constraint { variables: array![116, 131, 144, 146], rhs: 2 }, Constraint { variables: array![131, 144, 146, 159, 161], rhs: 3 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 140], rhs: 2 }, Constraint { variables: array![138, 140, 170], rhs: 3 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 142, 156, 157], rhs: 4 }, Constraint { variables: array![140, 156, 170], rhs: 3 }, Constraint { variables: array![142, 144, 157, 158, 159], rhs: 5 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![144, 146, 159, 161, 176], rhs: 3 }, Constraint { variables: array![156, 157, 158, 186, 187, 188], rhs: 3 }, Constraint { variables: array![156, 157, 170, 185, 186, 187], rhs: 4 }, Constraint { variables: array![157, 158, 159, 187, 188, 189], rhs: 3 }, Constraint { variables: array![158, 159, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 161, 176, 189, 190, 191], rhs: 3 }, Constraint { variables: array![170, 185], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 44, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1417861016, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 354465254, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00380g0f01_s002 c8');
}
#[test]
fn sq15_exact_s2_f110() {
    let sp_vars: Array<u32> = array![10, 11, 26];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![10], rhs: 1 }, Constraint { variables: array![10, 11, 26], rhs: 2 }, Constraint { variables: array![11, 26], rhs: 1 }, Constraint { variables: array![26], rhs: 1 }];
    let sp_hint: Array<u32> = array![10, 11, 26];
    let sp_nbrs: Array<u32> = array![10];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 9, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![4, 5, 20, 37, 49, 67, 69, 71, 72, 74, 86, 116];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![4], rhs: 1 }, Constraint { variables: array![4, 5, 20], rhs: 2 }, Constraint { variables: array![5, 20], rhs: 1 }, Constraint { variables: array![5, 20, 37], rhs: 2 }, Constraint { variables: array![20, 37], rhs: 2 }, Constraint { variables: array![20, 49], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 67], rhs: 2 }, Constraint { variables: array![37, 67, 69], rhs: 3 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 71], rhs: 2 }, Constraint { variables: array![69, 71, 86], rhs: 3 }, Constraint { variables: array![71, 72], rhs: 2 }, Constraint { variables: array![71, 72, 86], rhs: 3 }, Constraint { variables: array![72, 74], rhs: 2 }, Constraint { variables: array![74], rhs: 1 }, Constraint { variables: array![86, 116], rhs: 2 }, Constraint { variables: array![116], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![60, 61];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![60, 61], rhs: 1 }, Constraint { variables: array![61], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![125, 126, 138, 152, 159, 165, 166, 175, 180, 181, 182, 186, 187, 193, 194, 195, 197, 198, 199, 207, 208, 210, 211, 212, 214, 222];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 126], rhs: 2 }, Constraint { variables: array![125, 138], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 152], rhs: 2 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 165, 166], rhs: 2 }, Constraint { variables: array![152, 166, 181, 182], rhs: 4 }, Constraint { variables: array![152, 182], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 175], rhs: 2 }, Constraint { variables: array![159, 187], rhs: 2 }, Constraint { variables: array![165, 166], rhs: 1 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 207], rhs: 2 }, Constraint { variables: array![180, 181, 182, 195, 197, 210, 211, 212], rhs: 4 }, Constraint { variables: array![182, 197, 198, 199], rhs: 4 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![186, 199], rhs: 2 }, Constraint { variables: array![186, 199, 214], rhs: 3 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![193, 207, 208], rhs: 3 }, Constraint { variables: array![198, 199], rhs: 2 }, Constraint { variables: array![199, 214], rhs: 2 }, Constraint { variables: array![207, 222], rhs: 2 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 4, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 20, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s003 c8');
}
#[test]
fn sq15_exact_s2_f111() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 5);
    let outcomes = extract_outcomes(@aggregate, 35, 81, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 141448640369400, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 121241691745200, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 37567848146400, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 5217756687000, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 321642535500, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 6954433200, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s028 c8');
}
#[test]
fn sq15_exact_s2_f112() {
    let sp_vars: Array<u32> = array![16, 17, 18, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }];
    let sp_hint: Array<u32> = array![16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![17, 18];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 33, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 80, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 62866062386400, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 51789660918320, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 6585968440480, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s029 c8');
}
#[test]
fn sq15_exact_s2_f113() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }];
    let sp_hint: Array<u32> = array![19, 16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![18, 19];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 34, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 79, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 54221978808270, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 8644083578130, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s030 c8');
}
#[test]
fn sq15_exact_s2_f114() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }];
    let sp_hint: Array<u32> = array![20, 19, 16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![19, 20];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 35, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 78, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 46672083024840, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 7549895783430, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s031 c8');
}
#[test]
fn sq15_exact_s2_f115() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 21, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }, Constraint { variables: array![19, 20, 21], rhs: 1 }];
    let sp_hint: Array<u32> = array![21, 20, 19, 16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![20, 21];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 36, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 77, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 6581960426580, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 967935356850, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s032 c8');
}
#[test]
fn sq15_exact_s2_f116() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 21, 22, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }];
    let sp_hint: Array<u32> = array![22, 21, 20, 19, 16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![21, 22];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 37, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 76, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 854800055400, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 113135301450, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s033 c8');
}
#[test]
fn sq15_exact_s2_f117() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 21, 22, 23, 31, 46];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }];
    let sp_hint: Array<u32> = array![23, 22, 21, 20, 19, 16, 17, 18, 31, 46];
    let sp_nbrs: Array<u32> = array![22, 23];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 38, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 73, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 582492128790, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 241958268882, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 29328275016, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 1021382712, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s034 c8');
}
#[test]
fn sq15_exact_s2_f118() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 21, 22, 23, 24, 31, 39, 46, 54];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24, 39, 54], rhs: 1 }];
    let sp_hint: Array<u32> = array![16, 31, 46, 17, 18, 19, 20, 21, 22, 23, 24, 39, 54];
    let sp_nbrs: Array<u32> = array![31, 46];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 47, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 72, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 170226010240, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 364390053170, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 47876065380, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s035 c8');
}
#[test]
fn sq15_exact_s2_f119() {
    let sp_vars: Array<u32> = array![16, 17, 18, 19, 20, 21, 22, 23, 24, 31, 39, 46, 54, 61];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 0 }, Constraint { variables: array![18, 19, 20], rhs: 0 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 2 }, Constraint { variables: array![22, 23, 24, 39, 54], rhs: 1 }, Constraint { variables: array![31, 46, 61], rhs: 1 }];
    let sp_hint: Array<u32> = array![61, 16, 31, 46, 17, 18, 19, 20, 21, 22, 23, 24, 39, 54];
    let sp_nbrs: Array<u32> = array![39, 54];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 53, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![77, 83, 92, 98, 99, 100, 101, 102, 103, 104, 107, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 92], rhs: 1 }, Constraint { variables: array![77, 92, 107, 108], rhs: 2 }, Constraint { variables: array![83], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 71, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 319173769200, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 45216283970, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s036 c8');
}
#[test]
fn sq15_exact_s2_f120() {
    let sp_vars: Array<u32> = array![20, 21, 22, 23, 24, 25, 40, 41];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 1 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25, 40], rhs: 1 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 41], rhs: 1 }];
    let sp_hint: Array<u32> = array![41, 20, 21, 22, 23, 24, 25, 40];
    let sp_nbrs: Array<u32> = array![20, 21];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 35, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 170, 171, 172, 173, 178, 179, 185, 193, 194, 200, 215];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101], rhs: 1 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![170, 171, 172, 185, 200], rhs: 2 }, Constraint { variables: array![171, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![185, 200, 215], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![200, 215], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 92, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 4998958125283668, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 2194664542807464, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 290859156275688, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 11542030010940, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s013 c8');
}
#[test]
fn sq15_exact_s2_f121() {
    let sp_vars: Array<u32> = array![19, 20, 21, 22, 23, 24, 25, 34, 40, 41, 49];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![19, 20, 21, 34, 49], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 1 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25, 40], rhs: 1 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 41], rhs: 1 }];
    let sp_hint: Array<u32> = array![41, 25, 40, 24, 23, 22, 19, 20, 21, 34, 49];
    let sp_nbrs: Array<u32> = array![34, 49];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 50, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 170, 171, 172, 173, 178, 179, 185, 193, 194, 200, 215];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101], rhs: 1 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![170, 171, 172, 185, 200], rhs: 2 }, Constraint { variables: array![171, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![185, 200, 215], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![200, 215], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 91, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4353931270408356, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 645026854875312, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s014 c8');
}
#[test]
fn sq15_exact_s2_f122() {
    let sp_vars: Array<u32> = array![19, 20, 21, 22, 23, 24, 25, 34, 40, 41, 49, 64];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![19, 20, 21, 34, 49], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22, 23], rhs: 1 }, Constraint { variables: array![22, 23, 24], rhs: 1 }, Constraint { variables: array![23, 24, 25, 40], rhs: 1 }, Constraint { variables: array![34, 49, 64], rhs: 0 }, Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 41], rhs: 1 }];
    let sp_hint: Array<u32> = array![41, 64, 25, 40, 24, 23, 22, 19, 20, 21, 34, 49];
    let sp_nbrs: Array<u32> = array![40, 41];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 56, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 101, 102, 103, 104, 109, 110, 111, 114, 119, 124, 127, 134, 139, 141, 149, 154, 155, 156, 157, 164, 170, 171, 172, 173, 178, 179, 185, 193, 194, 200, 215];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100, 101], rhs: 1 }, Constraint { variables: array![100, 101, 102], rhs: 2 }, Constraint { variables: array![100, 101, 114], rhs: 2 }, Constraint { variables: array![101, 102, 103], rhs: 1 }, Constraint { variables: array![102, 103, 104, 119, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![119, 134, 149], rhs: 1 }, Constraint { variables: array![124, 139, 141, 154, 155, 156], rhs: 3 }, Constraint { variables: array![127, 141, 156, 157], rhs: 2 }, Constraint { variables: array![127, 157], rhs: 1 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![149, 164, 178, 179], rhs: 2 }, Constraint { variables: array![157, 172, 173], rhs: 2 }, Constraint { variables: array![170, 171, 172, 185, 200], rhs: 2 }, Constraint { variables: array![171, 172, 173], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![185, 200, 215], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![200, 215], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 88, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2848534744200912, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 1314708343477344, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 183060655420896, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 7627527309204, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g0f01_s015 c8');
}
#[test]
fn sq15_exact_s2_f123() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![68, 83, 98, 99, 100, 101, 102, 103, 104, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![68, 83, 98], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 5);
    let outcomes = extract_outcomes(@aggregate, 35, 99, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 12372343949650608, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 9243705249738960, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 2521010522656080, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 311585570215920, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 17310309456440, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 342401725512, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s016 c8');
}
#[test]
fn sq15_exact_s2_f124() {
    let sp_vars: Array<u32> = array![47, 48, 49, 62, 77];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![47, 48, 49, 62, 77], rhs: 1 }];
    let sp_hint: Array<u32> = array![47, 48, 49, 62, 77];
    let sp_nbrs: Array<u32> = array![48, 49];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 64, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![68, 83, 98, 99, 100, 101, 102, 103, 104, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![68, 83, 98], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 98, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4873953677135088, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 3921571924131680, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 448179648472192, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s017 c8');
}
#[test]
fn sq15_exact_s2_f125() {
    let sp_vars: Array<u32> = array![47, 48, 49, 50, 62, 77];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![47, 48, 49, 62, 77], rhs: 1 }, Constraint { variables: array![48, 49, 50], rhs: 0 }];
    let sp_hint: Array<u32> = array![50, 47, 48, 49, 62, 77];
    let sp_nbrs: Array<u32> = array![49, 50];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 65, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![68, 83, 98, 99, 100, 101, 102, 103, 104, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![68, 83, 98], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 97, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4277143022792016, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 596810654343072, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s018 c8');
}
#[test]
fn sq15_exact_s2_f126() {
    let sp_vars: Array<u32> = array![47, 48, 49, 50, 51, 62, 77];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![47, 48, 49, 62, 77], rhs: 1 }, Constraint { variables: array![48, 49, 50], rhs: 0 }, Constraint { variables: array![49, 50, 51], rhs: 0 }];
    let sp_hint: Array<u32> = array![51, 50, 47, 48, 49, 62, 77];
    let sp_nbrs: Array<u32> = array![50, 51];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 66, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![68, 83, 98, 99, 100, 101, 102, 103, 104, 108, 114, 115, 123, 128, 133, 138, 148, 153, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![68, 83, 98], rhs: 1 }, Constraint { variables: array![83, 98], rhs: 1 }, Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![108], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 1 }, Constraint { variables: array![108, 123, 138], rhs: 1 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![123, 138, 153, 154, 155], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 96, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 3748011927188880, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 529131095603136, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s019 c8');
}
#[test]
fn sq15_exact_s2_f127() {
    let sp_vars: Array<u32> = array![40, 57];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let sp_hint: Array<u32> = array![40, 57];
    let sp_nbrs: Array<u32> = array![40];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 39, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![7, 21, 22, 36, 51];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![21, 22, 36, 51], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![66, 79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![66, 81, 96, 98], rhs: 3 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 71, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 7681642150728, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s009 c8');
}
#[test]
fn sq15_exact_s2_f128() {
    let sp_vars: Array<u32> = array![7, 22];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 22];
    let sp_nbrs: Array<u32> = array![22];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 37, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![66, 79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![66, 81, 96, 98], rhs: 3 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 71, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 7681642150728, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 11837284625712, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 4825907390304, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 702182292240, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 31917376920, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s007 c8');
}
#[test]
fn sq15_exact_s2_f129() {
    let sp_vars: Array<u32> = array![7, 21, 22, 36, 51];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![21, 22, 36, 51], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 21, 22, 36, 51];
    let sp_nbrs: Array<u32> = array![22];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 38, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![66, 79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![66, 81, 96, 98], rhs: 3 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 71, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 4155642474984, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 7681642150728, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s008 c8');
}
#[test]
fn sq15_exact_s2_f130() {
    let sp_vars: Array<u32> = array![7, 18, 19, 20, 21, 22];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![18, 19, 20], rhs: 2 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 18, 19, 20, 21, 22];
    let sp_nbrs: Array<u32> = array![18, 19];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 33, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![78, 79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![78, 79, 80], rhs: 1 }, Constraint { variables: array![79, 80, 81], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 55, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 6358402050, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 3652699050, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 608783175, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 28989675, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s021 c8');
}
#[test]
fn sq15_exact_s2_f131() {
    let sp_vars: Array<u32> = array![7, 17, 18, 19, 20, 21, 22, 32, 47];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![17, 18, 19, 32, 47], rhs: 1 }, Constraint { variables: array![18, 19, 20], rhs: 2 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 22, 21, 20, 17, 18, 19, 32, 47];
    let sp_nbrs: Array<u32> = array![32, 47];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 48, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![78, 79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![78, 79, 80], rhs: 1 }, Constraint { variables: array![79, 80, 81], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 54, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 5317936260, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1040465790, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s022 c8');
}
#[test]
fn sq15_exact_s2_f132() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![16, 18, 35, 48, 49, 50, 63, 65, 77, 78, 79, 80, 95, 110, 111, 112, 113, 128, 143, 158, 165, 166, 167, 168, 169, 173, 184, 185, 186, 187, 188];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![16], rhs: 1 }, Constraint { variables: array![16, 18], rhs: 2 }, Constraint { variables: array![16, 18, 48], rhs: 3 }, Constraint { variables: array![18], rhs: 1 }, Constraint { variables: array![18, 35], rhs: 2 }, Constraint { variables: array![18, 35, 48, 49, 50], rhs: 4 }, Constraint { variables: array![18, 48, 49], rhs: 3 }, Constraint { variables: array![48, 49, 50, 63, 65, 78, 79, 80], rhs: 4 }, Constraint { variables: array![48, 63], rhs: 2 }, Constraint { variables: array![48, 63, 77, 78], rhs: 4 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 78], rhs: 2 }, Constraint { variables: array![77, 78, 79], rhs: 2 }, Constraint { variables: array![78, 79, 80, 95, 110], rhs: 2 }, Constraint { variables: array![95, 110], rhs: 1 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![110, 111], rhs: 1 }, Constraint { variables: array![110, 111, 112], rhs: 2 }, Constraint { variables: array![111, 112, 113, 128, 143], rhs: 1 }, Constraint { variables: array![128, 143, 158], rhs: 1 }, Constraint { variables: array![143, 158, 173], rhs: 1 }, Constraint { variables: array![158, 173, 186, 187, 188], rhs: 2 }, Constraint { variables: array![165, 166], rhs: 1 }, Constraint { variables: array![165, 166, 167], rhs: 1 }, Constraint { variables: array![166, 167, 168], rhs: 1 }, Constraint { variables: array![167, 168, 169], rhs: 1 }, Constraint { variables: array![168, 169], rhs: 1 }, Constraint { variables: array![169], rhs: 1 }, Constraint { variables: array![169, 184, 185, 186], rhs: 1 }, Constraint { variables: array![185, 186, 187], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 129, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 735034003429178703685600, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 283224111413078032612800, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 25747646492098002964800, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00430g1f01_s001 c8');
}
#[test]
fn sq15_exact_s2_f133() {
    let sp_vars: Array<u32> = array![7, 21, 22];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 21, 22];
    let sp_nbrs: Array<u32> = array![21, 22];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 36, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 68, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 4599174077472, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 2616771457872, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 443520586080, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 22176029304, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s012 c8');
}
#[test]
fn sq15_exact_s2_f134() {
    let sp_vars: Array<u32> = array![7, 20, 21, 22, 35, 50];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![20, 21, 22, 35, 50], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 20, 21, 22, 35, 50];
    let sp_nbrs: Array<u32> = array![35, 50];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 51, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 67, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 743984041944, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1616241194568, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 256546221360, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s013 c8');
}
#[test]
fn sq15_exact_s2_f135() {
    let sp_vars: Array<u32> = array![7, 20, 21, 22];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 20, 21, 22];
    let sp_nbrs: Array<u32> = array![20, 21];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 35, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 64, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 151473214816, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 82621753536, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 13278496104, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 621216192, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s015 c8');
}
