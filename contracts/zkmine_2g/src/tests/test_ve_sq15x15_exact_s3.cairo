// AUTO-GENERATED — do not edit by hand
// Square 15x15/35 correctness shard 3

use zkmine_2g::ve::{count_joint_component_with_order, count_ordinary_component, Constraint, JointEntry};
use zkmine_2g::cell::{convolve_joint, convolve_ordinary, apply_unconstrained_local, extract_outcomes};
use zkmine_2g::bigint::u512_eq;
use core::integer::u512;

#[test]
fn sq15_exact_s3_f136() {
    let sp_vars: Array<u32> = array![7, 19, 20, 21, 22, 34, 49];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![19, 20, 21, 34, 49], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 22, 19, 20, 21, 34, 49];
    let sp_nbrs: Array<u32> = array![34, 49];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 50, @sp_nbrs, @sp_hint);
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
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 63, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 127805525001, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 23667689815, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s016 c8');
}
#[test]
fn sq15_exact_s3_f137() {
    let sp_vars: Array<u32> = array![7, 19, 20, 21, 22];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 19, 20, 21, 22];
    let sp_nbrs: Array<u32> = array![19, 20];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 34, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 60, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 75394027566, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 44349427980, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 7675862535, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 386206920, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s018 c8');
}
#[test]
fn sq15_exact_s3_f138() {
    let sp_vars: Array<u32> = array![7, 18, 19, 20, 21, 22, 33, 48];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![18, 19, 20, 33, 48], rhs: 2 }, Constraint { variables: array![19, 20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 22], rhs: 2 }, Constraint { variables: array![21, 22], rhs: 1 }, Constraint { variables: array![22], rhs: 1 }];
    let sp_hint: Array<u32> = array![7, 22, 21, 18, 19, 20, 33, 48];
    let sp_nbrs: Array<u32> = array![33, 48];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 49, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![40, 57];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![40], rhs: 1 }, Constraint { variables: array![40, 57], rhs: 2 }, Constraint { variables: array![57], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![79, 80, 81, 94, 96, 98, 100, 102, 109, 110, 111, 114, 124, 127, 134, 139, 141, 154, 169, 170, 172, 173, 184, 199, 214, 215];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![79, 80, 81], rhs: 2 }, Constraint { variables: array![79, 80, 81, 94, 96, 109, 110, 111], rhs: 5 }, Constraint { variables: array![80, 81], rhs: 2 }, Constraint { variables: array![81], rhs: 1 }, Constraint { variables: array![81, 96, 98], rhs: 3 }, Constraint { variables: array![81, 96, 98, 111], rhs: 4 }, Constraint { variables: array![96, 98, 111, 127], rhs: 4 }, Constraint { variables: array![98], rhs: 1 }, Constraint { variables: array![98, 100], rhs: 2 }, Constraint { variables: array![98, 100, 114], rhs: 3 }, Constraint { variables: array![98, 114, 127], rhs: 3 }, Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 102], rhs: 2 }, Constraint { variables: array![100, 114], rhs: 2 }, Constraint { variables: array![102], rhs: 1 }, Constraint { variables: array![102, 134], rhs: 2 }, Constraint { variables: array![109, 110, 111, 124, 139, 141], rhs: 4 }, Constraint { variables: array![110, 111, 127, 141], rhs: 4 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 127], rhs: 2 }, Constraint { variables: array![124, 139, 141, 154], rhs: 3 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![134], rhs: 1 }, Constraint { variables: array![139, 141, 154, 169, 170], rhs: 4 }, Constraint { variables: array![141, 170, 172], rhs: 3 }, Constraint { variables: array![141, 172, 173], rhs: 3 }, Constraint { variables: array![169, 170, 184, 199], rhs: 1 }, Constraint { variables: array![170, 172], rhs: 2 }, Constraint { variables: array![172, 173], rhs: 2 }, Constraint { variables: array![173], rhs: 1 }, Constraint { variables: array![184, 199, 214, 215], rhs: 1 }, Constraint { variables: array![215], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![178, 179, 193];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179], rhs: 2 }, Constraint { variables: array![178, 179, 193], rhs: 3 }, Constraint { variables: array![178, 193], rhs: 2 }, Constraint { variables: array![193], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 59, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 12565671261, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 27348813921, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 4434942798, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00453g2f02_s019 c8');
}
#[test]
fn sq15_exact_s3_f139() {
    let sp_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 60, 61, 62];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![60, 61, 62], rhs: 1 }, Constraint { variables: array![61, 62], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp_hint: Array<u32> = array![44, 60, 61, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 62];
    let sp_nbrs: Array<u32> = array![60, 61];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 75, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 120, 121, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![120, 121, 122], rhs: 1 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![121, 122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 44, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1370754, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s005 c8');
}
#[test]
fn sq15_exact_s3_f140() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![98, 99, 100, 101, 102, 103, 104, 114, 115, 128, 133, 148, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 5);
    let outcomes = extract_outcomes(@aggregate, 35, 116, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 5505580622973528672, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 4048221046304065200, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 1100487274723435200, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 137560909340429400, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 7860623390881680, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 163145013773016, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s005 c8');
}
#[test]
fn sq15_exact_s3_f141() {
    let sp_vars: Array<u32> = array![78, 79, 80, 93, 108];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![78, 79, 80, 93, 108], rhs: 1 }];
    let sp_hint: Array<u32> = array![78, 79, 80, 93, 108];
    let sp_nbrs: Array<u32> = array![79, 80];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 95, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![98, 99, 100, 101, 102, 103, 104, 114, 115, 128, 133, 148, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 115, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2135785586498351640, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1717004098949655240, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 195431360856058320, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s006 c8');
}
#[test]
fn sq15_exact_s3_f142() {
    let sp_vars: Array<u32> = array![78, 79, 80, 81, 93, 108];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![78, 79, 80, 93, 108], rhs: 1 }, Constraint { variables: array![79, 80, 81], rhs: 0 }];
    let sp_hint: Array<u32> = array![81, 78, 79, 80, 93, 108];
    let sp_nbrs: Array<u32> = array![80, 81];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 96, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![98, 99, 100, 101, 102, 103, 104, 114, 115, 128, 133, 148, 154, 155, 156, 157, 160, 170, 172, 178, 182, 183, 184, 185, 186, 187, 191, 197, 212];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![98, 99, 114, 128], rhs: 3 }, Constraint { variables: array![98, 128], rhs: 1 }, Constraint { variables: array![100, 101, 102, 115], rhs: 1 }, Constraint { variables: array![101, 102, 103, 133], rhs: 2 }, Constraint { variables: array![102, 103, 104, 133], rhs: 2 }, Constraint { variables: array![103, 104, 133], rhs: 2 }, Constraint { variables: array![114, 115], rhs: 2 }, Constraint { variables: array![114, 115, 128], rhs: 3 }, Constraint { variables: array![115], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 156, 157], rhs: 3 }, Constraint { variables: array![128, 157], rhs: 2 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![133, 148], rhs: 2 }, Constraint { variables: array![148, 178], rhs: 2 }, Constraint { variables: array![154, 155, 156], rhs: 2 }, Constraint { variables: array![155, 156, 157], rhs: 2 }, Constraint { variables: array![155, 156, 157, 170, 172, 185, 186, 187], rhs: 6 }, Constraint { variables: array![157, 172], rhs: 2 }, Constraint { variables: array![157, 172, 187], rhs: 3 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 2 }, Constraint { variables: array![172, 187], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 191], rhs: 2 }, Constraint { variables: array![182, 183, 184, 197, 212], rhs: 2 }, Constraint { variables: array![183, 184, 185], rhs: 1 }, Constraint { variables: array![184, 185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 187], rhs: 2 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![197, 212], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![224], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 114, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1875776906402900136, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 260008680095451504, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00376g2f01_s007 c8');
}
#[test]
fn sq15_exact_s3_f143() {
    let sp_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp_hint: Array<u32> = array![44, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 62];
    let sp_nbrs: Array<u32> = array![62];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 76, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 121, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![121, 122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 4);
    let outcomes = extract_outcomes(@aggregate, 35, 46, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1712304, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 778320, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 103776, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 4512, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 48, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s001 c8');
}
#[test]
fn sq15_exact_s3_f144() {
    let sp_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 60, 61, 62, 75, 90];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![60, 61, 62, 75, 90], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp_hint: Array<u32> = array![44, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 60, 61, 62, 75, 90];
    let sp_nbrs: Array<u32> = array![61, 62];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 77, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 121, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![121, 122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 46, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1712304, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s002 c8');
}
#[test]
fn sq15_exact_s3_f145() {
    let sp_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 60, 61, 62, 75, 90];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![60, 61, 62, 75, 90], rhs: 1 }, Constraint { variables: array![61, 62], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp_hint: Array<u32> = array![44, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 60, 61, 62, 75, 90];
    let sp_nbrs: Array<u32> = array![75, 90];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 91, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 121, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![121, 122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 45, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1533939, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 178365, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s003 c8');
}
#[test]
fn sq15_exact_s3_f146() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![81, 82, 83, 84, 85, 86, 87, 88, 89, 96, 100, 111, 113, 114, 115, 117, 126, 131, 141, 142, 146, 156, 162, 171, 173, 174, 203, 219, 221];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![81, 82, 83, 96, 111, 113], rhs: 1 }, Constraint { variables: array![82, 83, 84, 113, 114], rhs: 2 }, Constraint { variables: array![83, 84, 85, 100, 113, 114, 115], rhs: 4 }, Constraint { variables: array![85, 86, 87, 100, 115, 117], rhs: 5 }, Constraint { variables: array![86, 87, 88, 117], rhs: 3 }, Constraint { variables: array![87, 88, 89, 117], rhs: 3 }, Constraint { variables: array![88, 89], rhs: 1 }, Constraint { variables: array![96, 111, 113, 126], rhs: 1 }, Constraint { variables: array![100, 115, 117, 131], rhs: 4 }, Constraint { variables: array![111, 113, 126, 141, 142], rhs: 2 }, Constraint { variables: array![113, 114, 115], rhs: 3 }, Constraint { variables: array![113, 114, 142], rhs: 3 }, Constraint { variables: array![114, 115, 131, 146], rhs: 4 }, Constraint { variables: array![117], rhs: 1 }, Constraint { variables: array![117, 131, 146], rhs: 3 }, Constraint { variables: array![131, 146], rhs: 2 }, Constraint { variables: array![131, 146, 162], rhs: 3 }, Constraint { variables: array![141, 142, 156, 171, 173], rhs: 2 }, Constraint { variables: array![142], rhs: 1 }, Constraint { variables: array![142, 173, 174], rhs: 3 }, Constraint { variables: array![146, 162], rhs: 2 }, Constraint { variables: array![146, 174], rhs: 2 }, Constraint { variables: array![156, 171, 173], rhs: 1 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![171, 173, 203], rhs: 2 }, Constraint { variables: array![173, 174], rhs: 2 }, Constraint { variables: array![173, 174, 203], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![203], rhs: 1 }, Constraint { variables: array![203, 219], rhs: 2 }, Constraint { variables: array![219, 221], rhs: 2 }, Constraint { variables: array![221], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 5);
    let outcomes = extract_outcomes(@aggregate, 35, 124, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2052267161195092892226, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1726206023435124862620, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 543435229599946716010, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 79770308932102270240, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 5438884699916063880, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 137197091529414224, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00186g2f02_s004 c8');
}
#[test]
fn sq15_exact_s3_f147() {
    let sp0_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let sp0_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp0_hint: Array<u32> = array![44, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 62];
    let sp0_nbrs: Array<u32> = array![47, 62];
    let sp0_entries: Array<JointEntry> = count_joint_component_with_order(@sp0_vars, @sp0_constr, 61, @sp0_nbrs, @sp0_hint);
    let sp1_vars: Array<u32> = array![45, 46];
    let sp1_constr: Array<Constraint> = array![Constraint { variables: array![45, 46], rhs: 0 }];
    let sp1_hint: Array<u32> = array![45, 46];
    let sp1_nbrs: Array<u32> = array![45, 46];
    let sp1_entries: Array<JointEntry> = count_joint_component_with_order(@sp1_vars, @sp1_constr, 61, @sp1_nbrs, @sp1_hint);
    let mut aggregate: Array<JointEntry> = convolve_joint(@sp0_entries, @sp1_entries);
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 42, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1086008, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s009 c8');
}
#[test]
fn sq15_exact_s3_f148() {
    let sp_vars: Array<u32> = array![4, 5, 9, 10, 11, 20, 26, 37, 49, 67, 69, 71, 72, 74, 86, 116];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![4], rhs: 1 }, Constraint { variables: array![4, 5, 20], rhs: 2 }, Constraint { variables: array![5, 20, 37], rhs: 2 }, Constraint { variables: array![9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 2 }, Constraint { variables: array![9, 37], rhs: 1 }, Constraint { variables: array![11, 26], rhs: 1 }, Constraint { variables: array![20, 37], rhs: 2 }, Constraint { variables: array![20, 49], rhs: 2 }, Constraint { variables: array![26], rhs: 1 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 67], rhs: 2 }, Constraint { variables: array![37, 67, 69], rhs: 3 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 71], rhs: 2 }, Constraint { variables: array![69, 71, 86], rhs: 3 }, Constraint { variables: array![71, 72], rhs: 2 }, Constraint { variables: array![71, 72, 86], rhs: 3 }, Constraint { variables: array![72, 74], rhs: 2 }, Constraint { variables: array![74], rhs: 1 }, Constraint { variables: array![86, 116], rhs: 2 }, Constraint { variables: array![116], rhs: 1 }];
    let sp_hint: Array<u32> = array![49, 74, 116, 4, 5, 20, 67, 72, 71, 86, 69, 37, 9, 10, 11, 26];
    let sp_nbrs: Array<u32> = array![5, 20];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 6, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![60, 61];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![60, 61], rhs: 1 }, Constraint { variables: array![61], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![125, 126, 138, 152, 159, 165, 166, 175, 180, 181, 182, 186, 187, 193, 194, 195, 197, 198, 199, 207, 208, 210, 211, 212, 214, 222];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 126], rhs: 2 }, Constraint { variables: array![125, 138], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 152], rhs: 2 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 165, 166], rhs: 2 }, Constraint { variables: array![152, 166, 181, 182], rhs: 4 }, Constraint { variables: array![152, 182], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 175], rhs: 2 }, Constraint { variables: array![159, 187], rhs: 2 }, Constraint { variables: array![165, 166], rhs: 1 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 207], rhs: 2 }, Constraint { variables: array![180, 181, 182, 195, 197, 210, 211, 212], rhs: 4 }, Constraint { variables: array![182, 197, 198, 199], rhs: 4 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![186, 199], rhs: 2 }, Constraint { variables: array![186, 199, 214], rhs: 3 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![193, 207, 208], rhs: 3 }, Constraint { variables: array![198, 199], rhs: 2 }, Constraint { variables: array![199, 214], rhs: 2 }, Constraint { variables: array![207, 222], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 4, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 20, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s001 c8');
}
#[test]
fn sq15_exact_s3_f149() {
    let sp_vars: Array<u32> = array![4, 5, 9, 10, 11, 20, 26, 37, 49, 67, 69, 71, 72, 74, 86, 116];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![4], rhs: 1 }, Constraint { variables: array![4, 5, 20], rhs: 2 }, Constraint { variables: array![5, 20], rhs: 1 }, Constraint { variables: array![5, 20, 37], rhs: 2 }, Constraint { variables: array![9, 10], rhs: 1 }, Constraint { variables: array![9, 10, 11, 26], rhs: 2 }, Constraint { variables: array![9, 37], rhs: 1 }, Constraint { variables: array![11, 26], rhs: 1 }, Constraint { variables: array![20, 37], rhs: 2 }, Constraint { variables: array![20, 49], rhs: 2 }, Constraint { variables: array![26], rhs: 1 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 67], rhs: 2 }, Constraint { variables: array![37, 67, 69], rhs: 3 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![67], rhs: 1 }, Constraint { variables: array![67, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }, Constraint { variables: array![69, 71], rhs: 2 }, Constraint { variables: array![69, 71, 86], rhs: 3 }, Constraint { variables: array![71, 72], rhs: 2 }, Constraint { variables: array![71, 72, 86], rhs: 3 }, Constraint { variables: array![72, 74], rhs: 2 }, Constraint { variables: array![74], rhs: 1 }, Constraint { variables: array![86, 116], rhs: 2 }, Constraint { variables: array![116], rhs: 1 }];
    let sp_hint: Array<u32> = array![49, 74, 116, 4, 5, 20, 67, 72, 71, 86, 69, 37, 9, 10, 11, 26];
    let sp_nbrs: Array<u32> = array![9];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 8, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![60, 61];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![60, 61], rhs: 1 }, Constraint { variables: array![61], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![125, 126, 138, 152, 159, 165, 166, 175, 180, 181, 182, 186, 187, 193, 194, 195, 197, 198, 199, 207, 208, 210, 211, 212, 214, 222];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 126], rhs: 2 }, Constraint { variables: array![125, 138], rhs: 2 }, Constraint { variables: array![126], rhs: 1 }, Constraint { variables: array![138], rhs: 1 }, Constraint { variables: array![138, 152], rhs: 2 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 165, 166], rhs: 2 }, Constraint { variables: array![152, 166, 181, 182], rhs: 4 }, Constraint { variables: array![152, 182], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 175], rhs: 2 }, Constraint { variables: array![159, 187], rhs: 2 }, Constraint { variables: array![165, 166], rhs: 1 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 207], rhs: 2 }, Constraint { variables: array![180, 181, 182, 195, 197, 210, 211, 212], rhs: 4 }, Constraint { variables: array![182, 197, 198, 199], rhs: 4 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![186, 187], rhs: 2 }, Constraint { variables: array![186, 199], rhs: 2 }, Constraint { variables: array![186, 199, 214], rhs: 3 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![193], rhs: 1 }, Constraint { variables: array![193, 194], rhs: 1 }, Constraint { variables: array![193, 207, 208], rhs: 3 }, Constraint { variables: array![198, 199], rhs: 2 }, Constraint { variables: array![199, 214], rhs: 2 }, Constraint { variables: array![207, 222], rhs: 2 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 4, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 20, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00252g0f07_s002 c8');
}
#[test]
fn sq15_exact_s3_f150() {
    let sp0_vars: Array<u32> = array![30, 31];
    let sp0_constr: Array<Constraint> = array![Constraint { variables: array![30, 31], rhs: 0 }];
    let sp0_hint: Array<u32> = array![30, 31];
    let sp0_nbrs: Array<u32> = array![30, 31];
    let sp0_entries: Array<JointEntry> = count_joint_component_with_order(@sp0_vars, @sp0_constr, 46, @sp0_nbrs, @sp0_hint);
    let sp1_vars: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let sp1_constr: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
    let sp1_hint: Array<u32> = array![44, 36, 41, 42, 43, 56, 55, 54, 52, 53, 51, 35, 32, 33, 34, 47, 62];
    let sp1_nbrs: Array<u32> = array![32, 47, 62];
    let sp1_entries: Array<JointEntry> = count_joint_component_with_order(@sp1_vars, @sp1_constr, 46, @sp1_nbrs, @sp1_hint);
    let mut aggregate: Array<JointEntry> = convolve_joint(@sp0_entries, @sp1_entries);
    let ord0v: Array<u32> = array![99, 128, 159, 162, 174, 177, 191, 223, 224];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 128], rhs: 2 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 159], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![159, 174, 191], rhs: 3 }, Constraint { variables: array![162], rhs: 1 }, Constraint { variables: array![162, 177], rhs: 2 }, Constraint { variables: array![162, 177, 191], rhs: 3 }, Constraint { variables: array![174], rhs: 1 }, Constraint { variables: array![174, 191], rhs: 2 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 191], rhs: 2 }, Constraint { variables: array![191], rhs: 1 }, Constraint { variables: array![191, 223], rhs: 2 }, Constraint { variables: array![223], rhs: 1 }, Constraint { variables: array![223, 224], rhs: 2 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![104];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![104], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![109, 110, 122, 123, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![122, 123, 151, 152, 153], rhs: 4 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let outcomes = extract_outcomes(@aggregate, 35, 39, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 749398, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s013 c8');
}
#[test]
fn sq15_exact_s3_f151() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![102, 103, 104, 113, 114, 115, 116, 117, 128, 130, 140, 141, 142, 143, 144, 145, 147, 155, 164, 170, 178, 185, 200, 215];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![102, 103, 104, 117], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![113, 114, 115, 128, 130, 143, 144, 145], rhs: 3 }, Constraint { variables: array![115, 116, 117, 130, 145, 147], rhs: 3 }, Constraint { variables: array![116, 117, 147], rhs: 1 }, Constraint { variables: array![117, 147], rhs: 1 }, Constraint { variables: array![130, 145, 147], rhs: 3 }, Constraint { variables: array![140, 141, 142, 155, 170], rhs: 0 }, Constraint { variables: array![141, 142, 143], rhs: 0 }, Constraint { variables: array![142, 143, 144], rhs: 1 }, Constraint { variables: array![143, 144, 145], rhs: 2 }, Constraint { variables: array![144, 145], rhs: 2 }, Constraint { variables: array![145, 147], rhs: 2 }, Constraint { variables: array![147, 164], rhs: 2 }, Constraint { variables: array![147, 164, 178], rhs: 3 }, Constraint { variables: array![147, 178], rhs: 2 }, Constraint { variables: array![155, 170, 185], rhs: 0 }, Constraint { variables: array![164], rhs: 1 }, Constraint { variables: array![164, 178], rhs: 2 }, Constraint { variables: array![170, 185, 200], rhs: 0 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![185, 200, 215], rhs: 0 }, Constraint { variables: array![200, 215], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![190, 219, 222];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![190], rhs: 1 }, Constraint { variables: array![190, 219], rhs: 2 }, Constraint { variables: array![190, 222], rhs: 2 }, Constraint { variables: array![219], rhs: 1 }, Constraint { variables: array![222], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 148, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 27136637962161374032736837760, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s012 c8');
}
#[test]
fn sq15_exact_s3_f152() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![8, 20, 21, 23, 33, 38, 46, 48, 50, 51, 53, 68, 76, 81, 82, 83, 96, 98, 107, 108, 109, 110, 111, 112, 113, 122];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![8, 21, 23], rhs: 1 }, Constraint { variables: array![8, 21, 23, 38], rhs: 1 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 2 }, Constraint { variables: array![20, 21, 50, 51], rhs: 4 }, Constraint { variables: array![20, 33], rhs: 2 }, Constraint { variables: array![20, 33, 48, 50], rhs: 4 }, Constraint { variables: array![21, 23, 38, 51, 53], rhs: 2 }, Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 46, 48], rhs: 3 }, Constraint { variables: array![33, 48, 50], rhs: 3 }, Constraint { variables: array![38, 51, 53, 68], rhs: 1 }, Constraint { variables: array![46], rhs: 1 }, Constraint { variables: array![46, 48, 76], rhs: 3 }, Constraint { variables: array![46, 76], rhs: 2 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![48, 50], rhs: 2 }, Constraint { variables: array![50, 51, 81], rhs: 3 }, Constraint { variables: array![50, 51, 81, 82], rhs: 4 }, Constraint { variables: array![51, 53, 68, 81, 82, 83], rhs: 3 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 107], rhs: 1 }, Constraint { variables: array![76, 107, 108], rhs: 2 }, Constraint { variables: array![81, 82, 83, 96, 98, 111, 112, 113], rhs: 4 }, Constraint { variables: array![81, 96], rhs: 2 }, Constraint { variables: array![81, 96, 109, 110, 111], rhs: 2 }, Constraint { variables: array![107, 108, 109], rhs: 1 }, Constraint { variables: array![107, 122], rhs: 0 }, Constraint { variables: array![108, 109, 110], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 148, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 287623351672678157950666944, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 99649035225179834250624768, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 8174334920815533278371563, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00108g1f02_s002 c8');
}
#[test]
fn sq15_exact_s3_f153() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 190], rhs: 1 }, Constraint { variables: array![160, 190, 191], rhs: 1 }, Constraint { variables: array![160, 190, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 201, 57, 58, 73, 88, 103, 118, 133, 141, 142, 190, 198, 199, 200, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![190];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 189, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 36, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 8347680, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1947792, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s001 c8');
}
#[test]
fn sq15_exact_s3_f154() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 205];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 190], rhs: 1 }, Constraint { variables: array![160, 190, 191], rhs: 1 }, Constraint { variables: array![160, 190, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![190, 205], rhs: 0 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }];
    let sp_hint: Array<u32> = array![205, 12, 27, 42, 195, 196, 197, 201, 57, 58, 73, 88, 103, 118, 133, 141, 142, 190, 198, 199, 200, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![201];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 202, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 33, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 4272048, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 3322704, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 712008, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 40920, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s002 c8');
}
#[test]
fn sq15_exact_s3_f155() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 205, 216, 217, 218];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 190], rhs: 1 }, Constraint { variables: array![160, 190, 191], rhs: 1 }, Constraint { variables: array![160, 190, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![190, 205], rhs: 0 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }];
    let sp_hint: Array<u32> = array![205, 12, 27, 42, 195, 196, 197, 57, 58, 73, 88, 103, 118, 133, 141, 142, 190, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![217, 218];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 203, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 32, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 402752, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 273296, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 35960, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s003 c8');
}
#[test]
fn sq15_exact_s3_f156() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 205, 216, 217, 218, 219];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 190], rhs: 1 }, Constraint { variables: array![160, 190, 191], rhs: 1 }, Constraint { variables: array![160, 190, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![190, 205], rhs: 0 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }];
    let sp_hint: Array<u32> = array![205, 12, 27, 42, 195, 196, 197, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 190, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![190, 205, 218, 219];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 204, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 31, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 169911, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 201376, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 31465, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s004 c8');
}
#[test]
fn sq15_exact_s3_f157() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 216, 217, 218, 219, 220];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 1 }, Constraint { variables: array![160, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 220, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![191];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 190, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 30, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 169911, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 31465, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s005 c8');
}
#[test]
fn sq15_exact_s3_f158() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 206, 216, 217, 218, 219, 220];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 191], rhs: 1 }, Constraint { variables: array![160, 191, 192], rhs: 1 }, Constraint { variables: array![163, 178, 191, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![191, 206], rhs: 0 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }];
    let sp_hint: Array<u32> = array![206, 12, 27, 42, 195, 196, 197, 220, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 193, 148, 131, 160, 163, 178, 191, 192];
    let sp_nbrs: Array<u32> = array![191, 206, 219, 220];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 205, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 29, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 118755, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 47502, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 3654, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s006 c8');
}
#[test]
fn sq15_exact_s3_f159() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 192, 193, 195, 196, 197, 198, 199, 200, 201, 216, 217, 218, 219, 220, 221];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 192], rhs: 1 }, Constraint { variables: array![163, 178, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220, 221], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 221, 220, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 193, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 160, 131, 148, 163, 178, 192];
    let sp_nbrs: Array<u32> = array![192];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 191, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 28, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 40950, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 6552, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s007 c8');
}
#[test]
fn sq15_exact_s3_f160() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 192, 193, 195, 196, 197, 198, 199, 200, 201, 207, 216, 217, 218, 219, 220, 221];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![160, 192], rhs: 1 }, Constraint { variables: array![163, 178, 192, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![192, 207], rhs: 0 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220, 221], rhs: 1 }];
    let sp_hint: Array<u32> = array![207, 12, 27, 42, 195, 196, 197, 221, 220, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 193, 198, 199, 200, 216, 217, 218, 201, 185, 157, 128, 160, 131, 148, 163, 178, 192];
    let sp_nbrs: Array<u32> = array![192, 207, 220, 221];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 206, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 27, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 35100, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 5850, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s008 c8');
}
#[test]
fn sq15_exact_s3_f161() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 193, 195, 196, 197, 198, 199, 200, 201, 216, 217, 218, 219, 220, 221, 222];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178, 193], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220, 221], rhs: 1 }, Constraint { variables: array![220, 221, 222], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 193, 178, 195, 196, 197, 222, 221, 220, 219, 57, 58, 73, 88, 103, 118, 133, 148, 163, 131, 160, 128, 141, 142, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![178, 193];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 192, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 26, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 29900, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 5200, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s009 c8');
}
#[test]
fn sq15_exact_s3_f162() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 193, 195, 196, 197, 198, 199, 200, 201, 208, 216, 217, 218, 219, 220, 221, 222];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178, 193], rhs: 2 }, Constraint { variables: array![178, 193, 208], rhs: 1 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220, 221], rhs: 1 }, Constraint { variables: array![220, 221, 222], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 208, 193, 178, 222, 221, 220, 219, 57, 58, 73, 88, 103, 118, 133, 148, 163, 131, 160, 128, 141, 142, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![193, 208, 221, 222];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 207, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 25, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 12650, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 14950, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 2300, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s010 c8');
}
#[test]
fn sq15_exact_s3_f163() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 185, 195, 196, 197, 198, 199, 200, 201, 216, 217, 218, 219, 220];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220], rhs: 1 }, Constraint { variables: array![220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 178, 195, 196, 197, 220, 219, 57, 58, 73, 88, 103, 118, 133, 148, 163, 131, 160, 128, 141, 142, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![178];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 193, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 22, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 7315, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 4620, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 693, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 22, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s011 c8');
}
#[test]
fn sq15_exact_s3_f164() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 179, 185, 194, 195, 196, 197, 198, 199, 200, 201, 209, 216, 217, 218, 219, 220];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179, 194, 209], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220], rhs: 1 }, Constraint { variables: array![220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 220, 219, 57, 58, 73, 88, 103, 118, 133, 141, 142, 179, 194, 209, 178, 148, 163, 131, 160, 128, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![194, 209];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 208, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 21, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1330, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2870, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 420, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s012 c8');
}
#[test]
fn sq15_exact_s3_f165() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 179, 185, 194, 195, 196, 197, 198, 199, 200, 201, 209, 216, 217, 218, 219, 220, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179, 194, 209], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![194, 209, 224], rhs: 1 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220], rhs: 1 }, Constraint { variables: array![220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 220, 219, 224, 57, 58, 73, 88, 103, 118, 133, 141, 142, 179, 194, 209, 178, 148, 163, 131, 160, 128, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![220];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 221, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 21, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2870, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s013 c8');
}
#[test]
fn sq15_exact_s3_f166() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 179, 185, 194, 195, 196, 197, 198, 199, 200, 201, 209, 216, 217, 218, 219, 220, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179, 194, 209], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![194, 209, 224], rhs: 1 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220], rhs: 1 }, Constraint { variables: array![220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 195, 196, 197, 220, 219, 224, 57, 58, 73, 88, 103, 118, 133, 141, 142, 179, 194, 209, 178, 148, 163, 131, 160, 128, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![209, 224];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 223, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 21, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1330, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1540, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s015 c8');
}
#[test]
fn sq15_exact_s3_f167() {
    let sp_vars: Array<u32> = array![12, 27, 42, 57, 58, 73, 88, 103, 118, 128, 131, 133, 141, 142, 148, 157, 160, 163, 178, 179, 185, 194, 195, 196, 197, 198, 199, 200, 201, 216, 217, 218, 219, 220];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12, 27], rhs: 1 }, Constraint { variables: array![12, 27, 42], rhs: 1 }, Constraint { variables: array![27, 42, 57], rhs: 1 }, Constraint { variables: array![42, 57], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 58, 73, 88], rhs: 1 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 1 }, Constraint { variables: array![103, 118, 131, 133], rhs: 2 }, Constraint { variables: array![118, 131, 133, 148], rhs: 1 }, Constraint { variables: array![128], rhs: 1 }, Constraint { variables: array![128, 141, 142], rhs: 3 }, Constraint { variables: array![128, 142, 157], rhs: 3 }, Constraint { variables: array![128, 160], rhs: 2 }, Constraint { variables: array![131], rhs: 1 }, Constraint { variables: array![131, 133, 148, 163], rhs: 2 }, Constraint { variables: array![131, 160], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![141, 142], rhs: 2 }, Constraint { variables: array![141, 142, 157], rhs: 3 }, Constraint { variables: array![142, 157], rhs: 2 }, Constraint { variables: array![148, 163, 178], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 185], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }, Constraint { variables: array![178, 179, 194], rhs: 2 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 198, 199, 200], rhs: 1 }, Constraint { variables: array![185, 200, 201], rhs: 2 }, Constraint { variables: array![194], rhs: 1 }, Constraint { variables: array![195, 196], rhs: 1 }, Constraint { variables: array![195, 196, 197], rhs: 2 }, Constraint { variables: array![196, 197, 198], rhs: 1 }, Constraint { variables: array![197, 198, 199], rhs: 1 }, Constraint { variables: array![201], rhs: 1 }, Constraint { variables: array![201, 216, 217, 218], rhs: 3 }, Constraint { variables: array![217, 218, 219], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220], rhs: 1 }, Constraint { variables: array![220], rhs: 1 }];
    let sp_hint: Array<u32> = array![12, 27, 42, 179, 194, 178, 195, 196, 197, 220, 219, 57, 58, 73, 88, 103, 118, 133, 148, 163, 131, 160, 128, 141, 142, 157, 198, 199, 185, 200, 201, 216, 217, 218];
    let sp_nbrs: Array<u32> = array![194];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 209, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![3, 4, 5, 6, 20, 21, 37, 69];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![3], rhs: 1 }, Constraint { variables: array![3, 4], rhs: 1 }, Constraint { variables: array![3, 4, 5, 20], rhs: 2 }, Constraint { variables: array![6, 21], rhs: 1 }, Constraint { variables: array![6, 21, 37], rhs: 2 }, Constraint { variables: array![20], rhs: 1 }, Constraint { variables: array![20, 21], rhs: 1 }, Constraint { variables: array![20, 21, 37], rhs: 2 }, Constraint { variables: array![37], rhs: 1 }, Constraint { variables: array![37, 69], rhs: 2 }, Constraint { variables: array![69], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![75, 90, 91, 92, 93, 94, 106, 108, 120, 121, 122, 123, 135];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }, Constraint { variables: array![75, 90, 91, 92], rhs: 2 }, Constraint { variables: array![91, 92, 93], rhs: 2 }, Constraint { variables: array![91, 92, 93, 106, 108, 121, 122, 123], rhs: 5 }, Constraint { variables: array![92, 93, 94], rhs: 3 }, Constraint { variables: array![93, 94], rhs: 2 }, Constraint { variables: array![93, 94, 108, 123], rhs: 4 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![108, 123], rhs: 2 }, Constraint { variables: array![120, 121, 122, 135], rhs: 2 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![123], rhs: 1 }, Constraint { variables: array![135], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 21, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1330, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00191g0f03_s016 c8');
}
#[test]
fn sq15_exact_s3_f168() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 4, 5, 9, 10, 11, 12, 15, 19, 25, 30, 36, 38, 39, 40, 45, 46, 47, 56, 60, 62, 65, 75, 77, 78, 90, 105, 106, 120];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 30], rhs: 1 }, Constraint { variables: array![1, 2, 3], rhs: 1 }, Constraint { variables: array![2, 3, 4, 19], rhs: 1 }, Constraint { variables: array![4, 5, 19, 36], rhs: 2 }, Constraint { variables: array![5, 36], rhs: 1 }, Constraint { variables: array![9, 10, 25, 38, 39, 40], rhs: 4 }, Constraint { variables: array![9, 38, 39], rhs: 2 }, Constraint { variables: array![10, 11, 12, 25, 40], rhs: 3 }, Constraint { variables: array![11, 12], rhs: 1 }, Constraint { variables: array![12], rhs: 1 }, Constraint { variables: array![15, 30, 45, 46, 47], rhs: 2 }, Constraint { variables: array![19], rhs: 1 }, Constraint { variables: array![19, 36], rhs: 2 }, Constraint { variables: array![19, 47], rhs: 2 }, Constraint { variables: array![25, 40, 56], rhs: 3 }, Constraint { variables: array![36, 38], rhs: 2 }, Constraint { variables: array![36, 65], rhs: 2 }, Constraint { variables: array![38, 39], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 3 }, Constraint { variables: array![39, 40, 56], rhs: 3 }, Constraint { variables: array![45, 46, 47, 60, 62, 75, 77], rhs: 5 }, Constraint { variables: array![46, 47], rhs: 2 }, Constraint { variables: array![47, 62], rhs: 2 }, Constraint { variables: array![47, 62, 77, 78], rhs: 4 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![60, 62, 75, 77, 90], rhs: 3 }, Constraint { variables: array![65], rhs: 1 }, Constraint { variables: array![65, 78], rhs: 2 }, Constraint { variables: array![75, 77, 90, 105, 106], rhs: 3 }, Constraint { variables: array![77, 78], rhs: 2 }, Constraint { variables: array![77, 78, 106], rhs: 3 }, Constraint { variables: array![78], rhs: 1 }, Constraint { variables: array![105, 106, 120], rhs: 2 }, Constraint { variables: array![106], rhs: 1 }, Constraint { variables: array![120], rhs: 1 }];
    let sp_hint: Array<u32> = array![120, 5, 56, 0, 11, 12, 105, 9, 10, 25, 39, 40, 38, 65, 36, 1, 4, 19, 106, 90, 2, 3, 15, 30, 45, 46, 47, 60, 62, 75, 77, 78];
    let sp_nbrs: Array<u32> = array![5];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 6, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![89];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![89], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![125, 129, 145, 153, 155, 157, 161, 162, 163, 164, 171, 179, 180, 181, 188, 192, 194, 195, 206, 209, 210, 211, 212, 221, 222, 223, 224];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 153, 155], rhs: 3 }, Constraint { variables: array![125, 155], rhs: 2 }, Constraint { variables: array![125, 155, 157], rhs: 3 }, Constraint { variables: array![129], rhs: 1 }, Constraint { variables: array![129, 145], rhs: 2 }, Constraint { variables: array![129, 157], rhs: 2 }, Constraint { variables: array![145], rhs: 1 }, Constraint { variables: array![145, 161], rhs: 2 }, Constraint { variables: array![145, 161, 162], rhs: 3 }, Constraint { variables: array![153], rhs: 1 }, Constraint { variables: array![153, 155], rhs: 2 }, Constraint { variables: array![153, 181], rhs: 2 }, Constraint { variables: array![155, 157, 171], rhs: 3 }, Constraint { variables: array![155, 171], rhs: 2 }, Constraint { variables: array![157], rhs: 1 }, Constraint { variables: array![157, 171, 188], rhs: 3 }, Constraint { variables: array![157, 188], rhs: 2 }, Constraint { variables: array![161], rhs: 1 }, Constraint { variables: array![161, 162, 163], rhs: 3 }, Constraint { variables: array![161, 162, 163, 192], rhs: 4 }, Constraint { variables: array![161, 162, 192], rhs: 3 }, Constraint { variables: array![162, 163, 164], rhs: 2 }, Constraint { variables: array![162, 163, 164, 179, 192, 194], rhs: 4 }, Constraint { variables: array![163, 164], rhs: 1 }, Constraint { variables: array![171], rhs: 1 }, Constraint { variables: array![171, 188], rhs: 2 }, Constraint { variables: array![179, 192, 194, 209], rhs: 2 }, Constraint { variables: array![180, 181], rhs: 1 }, Constraint { variables: array![180, 181, 195, 210, 211, 212], rhs: 2 }, Constraint { variables: array![181], rhs: 1 }, Constraint { variables: array![181, 211, 212], rhs: 2 }, Constraint { variables: array![188], rhs: 1 }, Constraint { variables: array![192, 194, 209, 222, 223, 224], rhs: 2 }, Constraint { variables: array![192, 206], rhs: 2 }, Constraint { variables: array![192, 206, 221, 222, 223], rhs: 2 }, Constraint { variables: array![206], rhs: 1 }, Constraint { variables: array![206, 221], rhs: 1 }, Constraint { variables: array![212], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let outcomes = extract_outcomes(@aggregate, 35, 0, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00125g0f05_s001 c8');
}
#[test]
fn sq15_exact_s3_f169() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![102, 103, 104, 113, 114, 115, 116, 117, 128, 130, 143, 144, 145, 147, 164, 178];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![102, 103, 104, 117], rhs: 1 }, Constraint { variables: array![103, 104], rhs: 1 }, Constraint { variables: array![113, 114, 115, 128, 130, 143, 144, 145], rhs: 3 }, Constraint { variables: array![115, 116, 117, 130, 145, 147], rhs: 3 }, Constraint { variables: array![116, 117, 147], rhs: 1 }, Constraint { variables: array![117, 147], rhs: 1 }, Constraint { variables: array![130, 145, 147], rhs: 3 }, Constraint { variables: array![143, 144, 145], rhs: 2 }, Constraint { variables: array![144, 145], rhs: 2 }, Constraint { variables: array![145, 147], rhs: 2 }, Constraint { variables: array![147, 164], rhs: 2 }, Constraint { variables: array![147, 164, 178], rhs: 3 }, Constraint { variables: array![147, 178], rhs: 2 }, Constraint { variables: array![164], rhs: 1 }, Constraint { variables: array![164, 178], rhs: 2 }, Constraint { variables: array![178], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![190, 219, 222];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![190], rhs: 1 }, Constraint { variables: array![190, 219], rhs: 2 }, Constraint { variables: array![190, 222], rhs: 2 }, Constraint { variables: array![219], rhs: 1 }, Constraint { variables: array![222], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 5);
    let outcomes = extract_outcomes(@aggregate, 35, 151, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 46893027458576709244435185312, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 46154554585213296500428332000, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 17307957969454986187660624500, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 3085914986802051800900731500, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 261115883498635152383908050, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 8371654280108913282537510, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00290g2f02_s005 c8');
}
#[test]
fn sq15_exact_s3_f170() {
    let sp_vars: Array<u32> = array![109, 110, 120, 121, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![120, 121, 122], rhs: 1 }, Constraint { variables: array![121, 122, 123], rhs: 2 }, Constraint { variables: array![121, 122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let sp_hint: Array<u32> = array![186, 120, 110, 109, 211, 196, 121, 136, 122, 123, 139, 198, 151, 152, 153, 166, 168, 170, 181, 183];
    let sp_nbrs: Array<u32> = array![120, 121];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 105, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 60, 61, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![60, 61], rhs: 0 }, Constraint { variables: array![60, 61, 62], rhs: 1 }, Constraint { variables: array![61, 62], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
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
    let outcomes = extract_outcomes(@aggregate, 35, 44, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 1370754, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s007 c8');
}
#[test]
fn sq15_exact_s3_f171() {
    let sp_vars: Array<u32> = array![109, 110, 122, 123, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let sp_hint: Array<u32> = array![186, 110, 109, 211, 136, 196, 122, 123, 139, 198, 151, 152, 153, 166, 168, 170, 181, 183];
    let sp_nbrs: Array<u32> = array![136];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 120, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 45, 46, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![45, 46], rhs: 0 }, Constraint { variables: array![45, 46, 47, 62], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
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
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 41, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 962598, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 123410, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s010 c8');
}
#[test]
fn sq15_exact_s3_f172() {
    let sp_vars: Array<u32> = array![109, 110, 122, 123, 135, 136, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 136, 151, 152, 153], rhs: 4 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![135, 136], rhs: 0 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let sp_hint: Array<u32> = array![135, 186, 110, 109, 211, 136, 196, 122, 123, 139, 198, 151, 152, 153, 166, 168, 170, 181, 183];
    let sp_nbrs: Array<u32> = array![122, 135, 136];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 121, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![32, 33, 34, 35, 36, 41, 42, 43, 44, 45, 46, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![45, 46], rhs: 0 }, Constraint { variables: array![45, 46, 47, 62], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
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
    let outcomes = extract_outcomes(@aggregate, 35, 41, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 962598, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s011 c8');
}
#[test]
fn sq15_exact_s3_f173() {
    let sp_vars: Array<u32> = array![109, 110, 122, 123, 139, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![122, 123, 151, 152, 153], rhs: 4 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let sp_hint: Array<u32> = array![186, 110, 109, 211, 196, 122, 123, 139, 198, 151, 152, 153, 166, 168, 170, 181, 183];
    let sp_nbrs: Array<u32> = array![151];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 135, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![30, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![30, 31], rhs: 0 }, Constraint { variables: array![30, 31, 32, 47, 62], rhs: 2 }, Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
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
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 38, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 658008, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 91390, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s014 c8');
}
#[test]
fn sq15_exact_s3_f174() {
    let sp_vars: Array<u32> = array![109, 110, 122, 123, 139, 150, 151, 152, 153, 166, 168, 170, 181, 183, 186, 196, 198, 211];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 110], rhs: 2 }, Constraint { variables: array![109, 110, 123, 139], rhs: 4 }, Constraint { variables: array![109, 110, 139], rhs: 3 }, Constraint { variables: array![109, 122, 123], rhs: 3 }, Constraint { variables: array![110], rhs: 1 }, Constraint { variables: array![122], rhs: 1 }, Constraint { variables: array![122, 123], rhs: 2 }, Constraint { variables: array![122, 123, 139, 152, 153], rhs: 5 }, Constraint { variables: array![122, 123, 151, 152, 153], rhs: 4 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 153, 168, 170], rhs: 4 }, Constraint { variables: array![139, 170], rhs: 2 }, Constraint { variables: array![150, 151], rhs: 0 }, Constraint { variables: array![151, 152, 153, 166, 168, 181, 183], rhs: 4 }, Constraint { variables: array![153, 168, 170, 183], rhs: 4 }, Constraint { variables: array![166, 168, 181, 183, 196, 198], rhs: 3 }, Constraint { variables: array![168, 170, 183, 198], rhs: 4 }, Constraint { variables: array![170], rhs: 1 }, Constraint { variables: array![170, 186], rhs: 2 }, Constraint { variables: array![181, 183, 196, 198, 211], rhs: 2 }, Constraint { variables: array![183, 198], rhs: 2 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![196, 198, 211], rhs: 1 }, Constraint { variables: array![198], rhs: 1 }];
    let sp_hint: Array<u32> = array![150, 186, 110, 109, 211, 196, 122, 123, 139, 198, 151, 152, 153, 166, 168, 170, 181, 183];
    let sp_nbrs: Array<u32> = array![122, 150, 151, 152];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 136, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![30, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 47, 51, 52, 53, 54, 55, 56, 62];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![30, 31], rhs: 0 }, Constraint { variables: array![30, 31, 32, 47, 62], rhs: 2 }, Constraint { variables: array![32, 33, 34, 47, 62], rhs: 3 }, Constraint { variables: array![33, 34, 35], rhs: 1 }, Constraint { variables: array![34, 35, 36, 51], rhs: 2 }, Constraint { variables: array![41, 42, 43, 56], rhs: 2 }, Constraint { variables: array![42, 43, 44], rhs: 1 }, Constraint { variables: array![43, 44], rhs: 1 }, Constraint { variables: array![47, 62], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 52], rhs: 2 }, Constraint { variables: array![51, 52, 53], rhs: 2 }, Constraint { variables: array![52, 53, 54], rhs: 1 }, Constraint { variables: array![53, 54, 55], rhs: 1 }, Constraint { variables: array![54, 55, 56], rhs: 2 }, Constraint { variables: array![55, 56], rhs: 2 }, Constraint { variables: array![56], rhs: 1 }, Constraint { variables: array![62], rhs: 1 }];
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
    let outcomes = extract_outcomes(@aggregate, 35, 38, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 658008, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00026g2f04_s015 c8');
}
#[test]
fn sq15_exact_s3_f175() {
    let sp_vars: Array<u32> = array![76, 105, 106];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 105, 106], rhs: 1 }, Constraint { variables: array![76, 106], rhs: 1 }];
    let sp_hint: Array<u32> = array![76, 105, 106];
    let sp_nbrs: Array<u32> = array![106];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 107, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![7, 22, 37, 52, 64, 65, 66, 67, 80, 82, 95, 96, 97, 110];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![7, 22, 37], rhs: 1 }, Constraint { variables: array![22, 37, 52], rhs: 1 }, Constraint { variables: array![37, 52, 65, 66, 67], rhs: 2 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 65], rhs: 2 }, Constraint { variables: array![64, 65, 66], rhs: 3 }, Constraint { variables: array![64, 65, 80, 95], rhs: 3 }, Constraint { variables: array![65, 66, 67, 80, 82, 95, 96, 97], rhs: 3 }, Constraint { variables: array![80, 95, 110], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![15, 16, 17, 19];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![15, 16], rhs: 2 }, Constraint { variables: array![15, 16, 17], rhs: 3 }, Constraint { variables: array![16, 17], rhs: 2 }, Constraint { variables: array![17, 19], rhs: 2 }, Constraint { variables: array![19], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 160, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 225949802822214958599039042752, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 124604670674015602168587707400, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 21828555446542879212015364800, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 1212697524807937734000853600, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s002 c8');
}
#[test]
fn sq15_exact_s3_f176() {
    let sp_vars: Array<u32> = array![76, 105, 106, 121, 122, 123];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 105, 106], rhs: 1 }, Constraint { variables: array![76, 106], rhs: 1 }, Constraint { variables: array![106, 121, 122, 123], rhs: 0 }];
    let sp_hint: Array<u32> = array![76, 105, 106, 121, 122, 123];
    let sp_nbrs: Array<u32> = array![122, 123];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 108, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![7, 22, 37, 52, 64, 65, 66, 67, 80, 82, 95, 96, 97, 110];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![7, 22], rhs: 1 }, Constraint { variables: array![7, 22, 37], rhs: 1 }, Constraint { variables: array![22, 37, 52], rhs: 1 }, Constraint { variables: array![37, 52, 65, 66, 67], rhs: 2 }, Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 65], rhs: 2 }, Constraint { variables: array![64, 65, 66], rhs: 3 }, Constraint { variables: array![64, 65, 80, 95], rhs: 3 }, Constraint { variables: array![65, 66, 67, 80, 82, 95, 96, 97], rhs: 3 }, Constraint { variables: array![80, 95, 110], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![15, 16, 17, 19];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![15, 16], rhs: 2 }, Constraint { variables: array![15, 16, 17], rhs: 3 }, Constraint { variables: array![16, 17], rhs: 2 }, Constraint { variables: array![17, 19], rhs: 2 }, Constraint { variables: array![19], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 159, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 190645146131243871317939192322, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 35304656690971087281099850430, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00341g1f01_s003 c8');
}
#[test]
fn sq15_exact_s3_f177() {
    let sp_vars: Array<u32> = array![12, 13, 28, 43, 55, 57, 58, 85, 99, 113, 114, 117, 125, 127, 128, 130, 131, 132, 143, 147, 150, 154, 159, 160, 162, 169, 177, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12], rhs: 1 }, Constraint { variables: array![12, 13, 28, 43], rhs: 1 }, Constraint { variables: array![28, 43, 57, 58], rhs: 1 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 57], rhs: 2 }, Constraint { variables: array![55, 57, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![57, 58], rhs: 1 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![85, 99, 114], rhs: 3 }, Constraint { variables: array![85, 117], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 113, 114], rhs: 3 }, Constraint { variables: array![99, 114, 130, 131], rhs: 4 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 114, 128, 130, 143], rhs: 5 }, Constraint { variables: array![113, 127, 128], rhs: 3 }, Constraint { variables: array![117, 130, 131, 132], rhs: 2 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 127], rhs: 2 }, Constraint { variables: array![125, 154], rhs: 2 }, Constraint { variables: array![127, 128, 143], rhs: 3 }, Constraint { variables: array![128, 130, 143, 159, 160], rhs: 5 }, Constraint { variables: array![130, 131, 132, 147, 160, 162], rhs: 3 }, Constraint { variables: array![130, 131, 159, 160], rhs: 4 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159], rhs: 2 }, Constraint { variables: array![147, 160, 162, 177], rhs: 1 }, Constraint { variables: array![150], rhs: 1 }, Constraint { variables: array![150, 180, 181], rhs: 1 }, Constraint { variables: array![150, 180, 181, 182], rhs: 1 }, Constraint { variables: array![154], rhs: 1 }, Constraint { variables: array![154, 169], rhs: 2 }, Constraint { variables: array![154, 169, 182, 183, 184], rhs: 3 }, Constraint { variables: array![154, 169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![159, 160, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 160, 189, 190, 191], rhs: 2 }, Constraint { variables: array![159, 187, 188, 189], rhs: 2 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 1 }, Constraint { variables: array![181, 182, 183], rhs: 1 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 1 }];
    let sp_hint: Array<u32> = array![55, 12, 13, 28, 43, 58, 57, 150, 180, 181, 182, 183, 169, 184, 192, 125, 185, 186, 85, 154, 187, 99, 117, 177, 188, 189, 114, 113, 128, 143, 190, 191, 127, 130, 131, 132, 147, 159, 160, 162];
    let sp_nbrs: Array<u32> = array![57, 58];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 73, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![1, 2];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![1], rhs: 1 }, Constraint { variables: array![1, 2], rhs: 2 }, Constraint { variables: array![2], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![9];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![9], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![64, 80];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 80], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![75];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 46, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1101716330, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 782798445, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 160574040, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 9366819, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s001 c8');
}
#[test]
fn sq15_exact_s3_f178() {
    let sp_vars: Array<u32> = array![12, 13, 28, 43, 55, 57, 58, 59, 74, 85, 89, 99, 113, 114, 117, 125, 127, 128, 130, 131, 132, 143, 147, 150, 154, 159, 160, 162, 169, 177, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12], rhs: 1 }, Constraint { variables: array![12, 13, 28, 43], rhs: 1 }, Constraint { variables: array![28, 43, 57, 58], rhs: 1 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 57], rhs: 2 }, Constraint { variables: array![55, 57, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![57, 58], rhs: 1 }, Constraint { variables: array![57, 58, 59, 74, 89], rhs: 1 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![85, 99, 114], rhs: 3 }, Constraint { variables: array![85, 117], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 113, 114], rhs: 3 }, Constraint { variables: array![99, 114, 130, 131], rhs: 4 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 114, 128, 130, 143], rhs: 5 }, Constraint { variables: array![113, 127, 128], rhs: 3 }, Constraint { variables: array![117, 130, 131, 132], rhs: 2 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 127], rhs: 2 }, Constraint { variables: array![125, 154], rhs: 2 }, Constraint { variables: array![127, 128, 143], rhs: 3 }, Constraint { variables: array![128, 130, 143, 159, 160], rhs: 5 }, Constraint { variables: array![130, 131, 132, 147, 160, 162], rhs: 3 }, Constraint { variables: array![130, 131, 159, 160], rhs: 4 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159], rhs: 2 }, Constraint { variables: array![147, 160, 162, 177], rhs: 1 }, Constraint { variables: array![150], rhs: 1 }, Constraint { variables: array![150, 180, 181], rhs: 1 }, Constraint { variables: array![150, 180, 181, 182], rhs: 1 }, Constraint { variables: array![154], rhs: 1 }, Constraint { variables: array![154, 169], rhs: 2 }, Constraint { variables: array![154, 169, 182, 183, 184], rhs: 3 }, Constraint { variables: array![154, 169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![159, 160, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 160, 189, 190, 191], rhs: 2 }, Constraint { variables: array![159, 187, 188, 189], rhs: 2 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 1 }, Constraint { variables: array![181, 182, 183], rhs: 1 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 1 }];
    let sp_hint: Array<u32> = array![55, 12, 13, 28, 43, 150, 180, 181, 58, 59, 74, 89, 57, 182, 183, 169, 184, 192, 125, 185, 186, 85, 154, 187, 99, 117, 177, 188, 189, 114, 113, 128, 143, 190, 191, 127, 130, 131, 132, 147, 159, 160, 162];
    let sp_nbrs: Array<u32> = array![74, 89];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 88, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![1, 2];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![1], rhs: 1 }, Constraint { variables: array![1, 2], rhs: 2 }, Constraint { variables: array![2], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![9];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![9], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![64, 80];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 80], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![75];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 45, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 886163135, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 215553195, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s002 c8');
}
#[test]
fn sq15_exact_s3_f179() {
    let sp_vars: Array<u32> = array![12, 13, 28, 43, 55, 57, 58, 59, 74, 85, 89, 99, 104, 113, 114, 117, 125, 127, 128, 130, 131, 132, 143, 147, 150, 154, 159, 160, 162, 169, 177, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12], rhs: 1 }, Constraint { variables: array![12, 13, 28, 43], rhs: 1 }, Constraint { variables: array![28, 43, 57, 58], rhs: 1 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 57], rhs: 2 }, Constraint { variables: array![55, 57, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![57, 58], rhs: 1 }, Constraint { variables: array![57, 58, 59, 74, 89], rhs: 1 }, Constraint { variables: array![74, 89, 104], rhs: 0 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![85, 99, 114], rhs: 3 }, Constraint { variables: array![85, 117], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 113, 114], rhs: 3 }, Constraint { variables: array![99, 114, 130, 131], rhs: 4 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 114, 128, 130, 143], rhs: 5 }, Constraint { variables: array![113, 127, 128], rhs: 3 }, Constraint { variables: array![117, 130, 131, 132], rhs: 2 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 127], rhs: 2 }, Constraint { variables: array![125, 154], rhs: 2 }, Constraint { variables: array![127, 128, 143], rhs: 3 }, Constraint { variables: array![128, 130, 143, 159, 160], rhs: 5 }, Constraint { variables: array![130, 131, 132, 147, 160, 162], rhs: 3 }, Constraint { variables: array![130, 131, 159, 160], rhs: 4 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159], rhs: 2 }, Constraint { variables: array![147, 160, 162, 177], rhs: 1 }, Constraint { variables: array![150], rhs: 1 }, Constraint { variables: array![150, 180, 181], rhs: 1 }, Constraint { variables: array![150, 180, 181, 182], rhs: 1 }, Constraint { variables: array![154], rhs: 1 }, Constraint { variables: array![154, 169], rhs: 2 }, Constraint { variables: array![154, 169, 182, 183, 184], rhs: 3 }, Constraint { variables: array![154, 169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![159, 160, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 160, 189, 190, 191], rhs: 2 }, Constraint { variables: array![159, 187, 188, 189], rhs: 2 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 1 }, Constraint { variables: array![181, 182, 183], rhs: 1 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 1 }];
    let sp_hint: Array<u32> = array![55, 104, 12, 13, 28, 43, 150, 180, 181, 58, 59, 74, 89, 57, 182, 183, 169, 184, 192, 125, 185, 186, 85, 154, 187, 99, 117, 177, 188, 189, 114, 113, 128, 143, 190, 191, 127, 130, 131, 132, 147, 159, 160, 162];
    let sp_nbrs: Array<u32> = array![117];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 102, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![1, 2];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![1], rhs: 1 }, Constraint { variables: array![1, 2], rhs: 2 }, Constraint { variables: array![2], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![9];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![9], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![64, 80];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 80], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![75];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 44, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 708930508, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 177232627, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s003 c8');
}
#[test]
fn sq15_exact_s3_f180() {
    let sp_vars: Array<u32> = array![12, 13, 28, 43, 55, 57, 58, 59, 74, 85, 89, 99, 104, 113, 114, 117, 118, 125, 127, 128, 130, 131, 132, 143, 147, 150, 154, 159, 160, 162, 169, 177, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![12], rhs: 1 }, Constraint { variables: array![12, 13, 28, 43], rhs: 1 }, Constraint { variables: array![28, 43, 57, 58], rhs: 1 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![55, 57], rhs: 2 }, Constraint { variables: array![55, 57, 85], rhs: 3 }, Constraint { variables: array![55, 85], rhs: 2 }, Constraint { variables: array![57, 58], rhs: 1 }, Constraint { variables: array![57, 58, 59, 74, 89], rhs: 1 }, Constraint { variables: array![74, 89, 104], rhs: 0 }, Constraint { variables: array![85], rhs: 1 }, Constraint { variables: array![85, 99], rhs: 2 }, Constraint { variables: array![85, 99, 114], rhs: 3 }, Constraint { variables: array![85, 117], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 113, 114], rhs: 3 }, Constraint { variables: array![99, 114, 130, 131], rhs: 4 }, Constraint { variables: array![113], rhs: 1 }, Constraint { variables: array![113, 114, 128, 130, 143], rhs: 5 }, Constraint { variables: array![113, 127, 128], rhs: 3 }, Constraint { variables: array![117, 118], rhs: 0 }, Constraint { variables: array![117, 130, 131, 132], rhs: 2 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 127], rhs: 2 }, Constraint { variables: array![125, 154], rhs: 2 }, Constraint { variables: array![127, 128, 143], rhs: 3 }, Constraint { variables: array![128, 130, 143, 159, 160], rhs: 5 }, Constraint { variables: array![130, 131, 132, 147, 160, 162], rhs: 3 }, Constraint { variables: array![130, 131, 159, 160], rhs: 4 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159], rhs: 2 }, Constraint { variables: array![147, 160, 162, 177], rhs: 1 }, Constraint { variables: array![150], rhs: 1 }, Constraint { variables: array![150, 180, 181], rhs: 1 }, Constraint { variables: array![150, 180, 181, 182], rhs: 1 }, Constraint { variables: array![154], rhs: 1 }, Constraint { variables: array![154, 169], rhs: 2 }, Constraint { variables: array![154, 169, 182, 183, 184], rhs: 3 }, Constraint { variables: array![154, 169, 184, 185, 186], rhs: 2 }, Constraint { variables: array![159, 160, 188, 189, 190], rhs: 2 }, Constraint { variables: array![159, 160, 189, 190, 191], rhs: 2 }, Constraint { variables: array![159, 187, 188, 189], rhs: 2 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 1 }, Constraint { variables: array![181, 182, 183], rhs: 1 }, Constraint { variables: array![185, 186, 187], rhs: 1 }, Constraint { variables: array![186, 187, 188], rhs: 1 }];
    let sp_hint: Array<u32> = array![118, 55, 104, 12, 13, 28, 43, 150, 180, 181, 58, 59, 74, 89, 57, 182, 183, 169, 184, 192, 125, 185, 186, 85, 154, 187, 99, 117, 177, 188, 189, 114, 113, 128, 143, 190, 191, 127, 130, 131, 132, 147, 159, 160, 162];
    let sp_nbrs: Array<u32> = array![89, 104, 117, 118];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 103, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![1, 2];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![1], rhs: 1 }, Constraint { variables: array![1, 2], rhs: 2 }, Constraint { variables: array![2], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let ord1v: Array<u32> = array![9];
    let ord1c: Array<Constraint> = array![Constraint { variables: array![9], rhs: 1 }];
    let ord1w = count_ordinary_component(@ord1v, @ord1c);
    aggregate = convolve_ordinary(@aggregate, @ord1w);
    let ord2v: Array<u32> = array![64, 80];
    let ord2c: Array<Constraint> = array![Constraint { variables: array![64], rhs: 1 }, Constraint { variables: array![64, 80], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }];
    let ord2w = count_ordinary_component(@ord2v, @ord2c);
    aggregate = convolve_ordinary(@aggregate, @ord2w);
    let ord3v: Array<u32> = array![75];
    let ord3c: Array<Constraint> = array![Constraint { variables: array![75], rhs: 1 }];
    let ord3w = count_ordinary_component(@ord3v, @ord3c);
    aggregate = convolve_ordinary(@aggregate, @ord3w);
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 43, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 563921995, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 145008513, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00416g1f02_s004 c8');
}
#[test]
fn sq15_exact_s3_f181() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 7, 9, 10, 11, 12, 13, 15, 17, 24, 28, 29, 30, 33, 36, 41, 44, 45, 48, 51, 53, 54, 57, 59, 60, 61, 74, 75, 80, 89, 90, 104, 105, 106, 107, 118, 119, 120, 133, 134, 135, 139, 149, 150, 152, 155, 163, 164, 165, 176, 178, 179, 180, 182, 190, 194, 195, 206, 209, 210, 216, 217, 218, 219, 220, 221, 222, 223, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 17, 30], rhs: 1 }, Constraint { variables: array![2, 3, 17, 33], rhs: 2 }, Constraint { variables: array![3, 33], rhs: 1 }, Constraint { variables: array![7], rhs: 1 }, Constraint { variables: array![7, 9, 24], rhs: 2 }, Constraint { variables: array![7, 36], rhs: 2 }, Constraint { variables: array![9, 10, 11, 24, 41], rhs: 2 }, Constraint { variables: array![10, 11, 12, 41], rhs: 1 }, Constraint { variables: array![11, 12, 13, 28, 41], rhs: 2 }, Constraint { variables: array![15, 17, 30, 45], rhs: 2 }, Constraint { variables: array![17, 33, 48], rhs: 3 }, Constraint { variables: array![24, 41, 54], rhs: 3 }, Constraint { variables: array![24, 53, 54], rhs: 3 }, Constraint { variables: array![28, 29, 44, 57, 59], rhs: 2 }, Constraint { variables: array![28, 41, 57], rhs: 3 }, Constraint { variables: array![30, 45, 60, 61], rhs: 2 }, Constraint { variables: array![33, 48], rhs: 2 }, Constraint { variables: array![33, 48, 61], rhs: 3 }, Constraint { variables: array![36], rhs: 1 }, Constraint { variables: array![36, 51], rhs: 2 }, Constraint { variables: array![36, 51, 53], rhs: 3 }, Constraint { variables: array![41, 54], rhs: 2 }, Constraint { variables: array![41, 57], rhs: 2 }, Constraint { variables: array![44, 57, 59, 74], rhs: 1 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![48, 61], rhs: 2 }, Constraint { variables: array![48, 80], rhs: 2 }, Constraint { variables: array![51, 53], rhs: 2 }, Constraint { variables: array![51, 80], rhs: 2 }, Constraint { variables: array![53, 54], rhs: 2 }, Constraint { variables: array![54], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 59, 74, 89], rhs: 1 }, Constraint { variables: array![60, 61, 75, 90], rhs: 1 }, Constraint { variables: array![61], rhs: 1 }, Constraint { variables: array![74, 89, 104], rhs: 1 }, Constraint { variables: array![75, 90, 105, 106, 107], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }, Constraint { variables: array![89, 104, 118, 119], rhs: 2 }, Constraint { variables: array![105, 106, 107, 120, 135], rhs: 2 }, Constraint { variables: array![106, 107], rhs: 2 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 139], rhs: 2 }, Constraint { variables: array![118], rhs: 1 }, Constraint { variables: array![118, 133], rhs: 2 }, Constraint { variables: array![120, 135, 150, 152], rhs: 1 }, Constraint { variables: array![133, 134, 149, 163, 164], rhs: 2 }, Constraint { variables: array![133, 163], rhs: 2 }, Constraint { variables: array![135, 150, 152, 165], rhs: 1 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 152], rhs: 2 }, Constraint { variables: array![139, 155], rhs: 2 }, Constraint { variables: array![150, 152, 165, 180, 182], rhs: 2 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 182], rhs: 2 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![163, 176, 178], rhs: 3 }, Constraint { variables: array![165, 180, 182, 195], rhs: 2 }, Constraint { variables: array![176], rhs: 1 }, Constraint { variables: array![176, 178, 206], rhs: 3 }, Constraint { variables: array![176, 190], rhs: 2 }, Constraint { variables: array![176, 190, 206], rhs: 3 }, Constraint { variables: array![178, 179, 194, 209], rhs: 1 }, Constraint { variables: array![180, 182, 195, 210], rhs: 2 }, Constraint { variables: array![182], rhs: 1 }, Constraint { variables: array![190], rhs: 1 }, Constraint { variables: array![190, 206, 219, 220, 221], rhs: 2 }, Constraint { variables: array![190, 218, 219, 220], rhs: 2 }, Constraint { variables: array![194, 209, 222, 223, 224], rhs: 1 }, Constraint { variables: array![195, 210], rhs: 1 }, Constraint { variables: array![206, 221, 222, 223], rhs: 2 }, Constraint { variables: array![216], rhs: 1 }, Constraint { variables: array![216, 217], rhs: 1 }, Constraint { variables: array![216, 217, 218], rhs: 2 }, Constraint { variables: array![217, 218, 219], rhs: 1 }];
    let sp_hint: Array<u32> = array![155, 216, 217, 3, 119, 179, 210, 195, 218, 13, 29, 134, 149, 164, 180, 182, 165, 150, 219, 220, 224, 0, 1, 80, 133, 139, 152, 120, 135, 105, 106, 107, 75, 90, 60, 54, 104, 190, 12, 15, 44, 59, 7, 51, 118, 2, 30, 45, 17, 33, 61, 48, 36, 53, 9, 24, 10, 11, 41, 28, 57, 74, 89, 163, 176, 194, 209, 178, 206, 221, 222, 223];
    let sp_nbrs: Array<u32> = array![3];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 4, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![100, 129];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 129], rhs: 2 }, Constraint { variables: array![129], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 1, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s001 c8');
}
#[test]
fn sq15_exact_s3_f182() {
    let sp_vars: Array<u32> = array![0, 1, 2, 7, 9, 10, 11, 12, 13, 15, 17, 24, 28, 29, 30, 33, 36, 41, 44, 45, 48, 51, 53, 54, 57, 59, 60, 61, 74, 75, 80, 89, 90, 104, 105, 106, 107, 118, 119, 120, 133, 134, 135, 139, 149, 150, 152, 155, 163, 164, 165, 176, 178, 179, 180, 182, 190, 194, 195, 206, 209, 210, 216, 217, 218, 219, 220, 221, 222, 223, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 17, 30], rhs: 1 }, Constraint { variables: array![2, 17, 33], rhs: 2 }, Constraint { variables: array![7], rhs: 1 }, Constraint { variables: array![7, 9, 24], rhs: 2 }, Constraint { variables: array![7, 36], rhs: 2 }, Constraint { variables: array![9, 10, 11, 24, 41], rhs: 2 }, Constraint { variables: array![10, 11, 12, 41], rhs: 1 }, Constraint { variables: array![11, 12, 13, 28, 41], rhs: 2 }, Constraint { variables: array![15, 17, 30, 45], rhs: 2 }, Constraint { variables: array![17, 33, 48], rhs: 3 }, Constraint { variables: array![24, 41, 54], rhs: 3 }, Constraint { variables: array![24, 53, 54], rhs: 3 }, Constraint { variables: array![28, 29, 44, 57, 59], rhs: 2 }, Constraint { variables: array![28, 41, 57], rhs: 3 }, Constraint { variables: array![30, 45, 60, 61], rhs: 2 }, Constraint { variables: array![33], rhs: 1 }, Constraint { variables: array![33, 48], rhs: 2 }, Constraint { variables: array![33, 48, 61], rhs: 3 }, Constraint { variables: array![36], rhs: 1 }, Constraint { variables: array![36, 51], rhs: 2 }, Constraint { variables: array![36, 51, 53], rhs: 3 }, Constraint { variables: array![41, 54], rhs: 2 }, Constraint { variables: array![41, 57], rhs: 2 }, Constraint { variables: array![44, 57, 59, 74], rhs: 1 }, Constraint { variables: array![48], rhs: 1 }, Constraint { variables: array![48, 61], rhs: 2 }, Constraint { variables: array![48, 80], rhs: 2 }, Constraint { variables: array![51, 53], rhs: 2 }, Constraint { variables: array![51, 80], rhs: 2 }, Constraint { variables: array![53, 54], rhs: 2 }, Constraint { variables: array![54], rhs: 1 }, Constraint { variables: array![57], rhs: 1 }, Constraint { variables: array![57, 59, 74, 89], rhs: 1 }, Constraint { variables: array![60, 61, 75, 90], rhs: 1 }, Constraint { variables: array![61], rhs: 1 }, Constraint { variables: array![74, 89, 104], rhs: 1 }, Constraint { variables: array![75, 90, 105, 106, 107], rhs: 2 }, Constraint { variables: array![80], rhs: 1 }, Constraint { variables: array![89, 104, 118, 119], rhs: 2 }, Constraint { variables: array![105, 106, 107, 120, 135], rhs: 2 }, Constraint { variables: array![106, 107], rhs: 2 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 139], rhs: 2 }, Constraint { variables: array![118], rhs: 1 }, Constraint { variables: array![118, 133], rhs: 2 }, Constraint { variables: array![120, 135, 150, 152], rhs: 1 }, Constraint { variables: array![133, 134, 149, 163, 164], rhs: 2 }, Constraint { variables: array![133, 163], rhs: 2 }, Constraint { variables: array![135, 150, 152, 165], rhs: 1 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![139, 152], rhs: 2 }, Constraint { variables: array![139, 155], rhs: 2 }, Constraint { variables: array![150, 152, 165, 180, 182], rhs: 2 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 182], rhs: 2 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![163, 176, 178], rhs: 3 }, Constraint { variables: array![165, 180, 182, 195], rhs: 2 }, Constraint { variables: array![176], rhs: 1 }, Constraint { variables: array![176, 178, 206], rhs: 3 }, Constraint { variables: array![176, 190], rhs: 2 }, Constraint { variables: array![176, 190, 206], rhs: 3 }, Constraint { variables: array![178, 179, 194, 209], rhs: 1 }, Constraint { variables: array![180, 182, 195, 210], rhs: 2 }, Constraint { variables: array![182], rhs: 1 }, Constraint { variables: array![190], rhs: 1 }, Constraint { variables: array![190, 206, 219, 220, 221], rhs: 2 }, Constraint { variables: array![190, 218, 219, 220], rhs: 2 }, Constraint { variables: array![194, 209, 222, 223, 224], rhs: 1 }, Constraint { variables: array![195, 210], rhs: 1 }, Constraint { variables: array![206, 221, 222, 223], rhs: 2 }, Constraint { variables: array![216], rhs: 1 }, Constraint { variables: array![216, 217], rhs: 1 }, Constraint { variables: array![216, 217, 218], rhs: 2 }, Constraint { variables: array![217, 218, 219], rhs: 1 }];
    let sp_hint: Array<u32> = array![155, 216, 217, 119, 179, 210, 195, 218, 13, 29, 134, 149, 164, 180, 182, 165, 150, 219, 220, 224, 0, 1, 80, 133, 139, 152, 120, 135, 105, 106, 107, 75, 90, 60, 54, 104, 190, 12, 15, 44, 59, 7, 51, 118, 2, 30, 45, 17, 33, 61, 48, 36, 53, 9, 24, 10, 11, 41, 28, 57, 74, 89, 163, 176, 194, 209, 178, 206, 221, 222, 223];
    let sp_nbrs: Array<u32> = array![2, 17];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 3, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![100, 129];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![100], rhs: 1 }, Constraint { variables: array![100, 129], rhs: 2 }, Constraint { variables: array![129], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 1, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 2, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00028g0f04_s002 c8');
}
#[test]
fn sq15_exact_s3_f183() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![2, 17];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![2, 17], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 217, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 151184295803629737571435946472381191016, limb1: 93, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 253074039524331258435272404554111178000, limb1: 35, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 102904350269097746316982277157532190862, limb1: 3, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00000g1f00_s002 c8');
}
#[test]
fn sq15_exact_s3_f184() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![2, 17];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![2, 17], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 217, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 151184295803629737571435946472381191016, limb1: 93, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 253074039524331258435272404554111178000, limb1: 35, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 102904350269097746316982277157532190862, limb1: 3, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00002g1f00_s002 c8');
}
#[test]
fn sq15_exact_s3_f185() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![2, 17];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![2, 17], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 217, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 151184295803629737571435946472381191016, limb1: 93, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 253074039524331258435272404554111178000, limb1: 35, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 102904350269097746316982277157532190862, limb1: 3, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00005g1f00_s002 c8');
}
#[test]
fn sq15_exact_s3_f186() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![2, 17];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![2, 17], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 217, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 151184295803629737571435946472381191016, limb1: 93, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 253074039524331258435272404554111178000, limb1: 35, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 102904350269097746316982277157532190862, limb1: 3, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00008g1f00_s002 c8');
}
#[test]
fn sq15_exact_s3_f187() {
    let mut aggregate: Array<JointEntry> = array![JointEntry { mines: 0, x_mine: 0, nbrs: 0, count: 1_u256 }];
    let ord0v: Array<u32> = array![2, 17];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![2, 17], rhs: 0 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 217, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 151184295803629737571435946472381191016, limb1: 93, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 253074039524331258435272404554111178000, limb1: 35, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 102904350269097746316982277157532190862, limb1: 3, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00010g1f00_s002 c8');
}
#[test]
fn sq15_exact_s3_f188() {
    let sp_vars: Array<u32> = array![5, 6, 10, 16, 17, 18, 19, 20, 25, 26, 27, 28, 31, 36, 41, 43, 46, 54, 56, 58, 61, 71, 73, 76, 77, 84, 88, 90, 91, 93, 99, 101, 103, 105, 115, 117, 118, 120, 130, 133, 135, 142, 148, 150, 151, 152, 160, 163, 164, 166, 171, 179, 181, 183, 185, 186, 187, 194, 196, 197, 198, 199, 200, 202, 209, 217, 218, 219, 220, 221, 222, 223, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![5, 6, 20, 36], rhs: 1 }, Constraint { variables: array![6], rhs: 0 }, Constraint { variables: array![6, 36], rhs: 1 }, Constraint { variables: array![10, 25], rhs: 0 }, Constraint { variables: array![16, 17, 18, 31, 46], rhs: 1 }, Constraint { variables: array![17, 18, 19], rhs: 1 }, Constraint { variables: array![18, 19, 20], rhs: 1 }, Constraint { variables: array![19, 20, 36], rhs: 1 }, Constraint { variables: array![25, 26, 41, 54, 56], rhs: 3 }, Constraint { variables: array![25, 54], rhs: 1 }, Constraint { variables: array![26, 27, 28, 41, 43, 56, 58], rhs: 3 }, Constraint { variables: array![31, 46, 61], rhs: 1 }, Constraint { variables: array![36], rhs: 1 }, Constraint { variables: array![41, 43, 56, 58, 71, 73], rhs: 3 }, Constraint { variables: array![41, 54, 56, 71], rhs: 4 }, Constraint { variables: array![46, 61, 76, 77], rhs: 2 }, Constraint { variables: array![54], rhs: 1 }, Constraint { variables: array![54, 56, 71, 84], rhs: 4 }, Constraint { variables: array![54, 84], rhs: 2 }, Constraint { variables: array![56, 58, 71, 73, 88], rhs: 2 }, Constraint { variables: array![71, 73, 88, 101, 103], rhs: 2 }, Constraint { variables: array![71, 84, 99, 101], rhs: 4 }, Constraint { variables: array![71, 101], rhs: 2 }, Constraint { variables: array![76, 77, 91, 93], rhs: 2 }, Constraint { variables: array![77], rhs: 1 }, Constraint { variables: array![77, 93], rhs: 2 }, Constraint { variables: array![84, 99], rhs: 2 }, Constraint { variables: array![84, 99, 101, 115], rhs: 4 }, Constraint { variables: array![88, 101, 103, 117, 118], rhs: 2 }, Constraint { variables: array![90, 91, 105, 120], rhs: 1 }, Constraint { variables: array![91, 93], rhs: 1 }, Constraint { variables: array![93], rhs: 1 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![99, 115, 130], rhs: 3 }, Constraint { variables: array![101, 115, 117, 130], rhs: 4 }, Constraint { variables: array![105, 120, 135], rhs: 1 }, Constraint { variables: array![115, 117, 130], rhs: 3 }, Constraint { variables: array![115, 130], rhs: 2 }, Constraint { variables: array![117, 118, 133, 148], rhs: 2 }, Constraint { variables: array![120, 135, 150, 151, 152], rhs: 3 }, Constraint { variables: array![130, 160], rhs: 2 }, Constraint { variables: array![133, 148, 163], rhs: 2 }, Constraint { variables: array![142], rhs: 1 }, Constraint { variables: array![142, 171], rhs: 2 }, Constraint { variables: array![148, 163], rhs: 1 }, Constraint { variables: array![151, 152], rhs: 2 }, Constraint { variables: array![151, 152, 166, 181, 183], rhs: 3 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 183], rhs: 2 }, Constraint { variables: array![160], rhs: 1 }, Constraint { variables: array![163], rhs: 1 }, Constraint { variables: array![163, 164, 179, 194], rhs: 2 }, Constraint { variables: array![166, 181, 183, 196, 197, 198], rhs: 2 }, Constraint { variables: array![171], rhs: 1 }, Constraint { variables: array![171, 185, 186], rhs: 3 }, Constraint { variables: array![171, 186, 187], rhs: 3 }, Constraint { variables: array![179, 194, 209], rhs: 1 }, Constraint { variables: array![183, 185], rhs: 2 }, Constraint { variables: array![183, 185, 198, 199, 200], rhs: 2 }, Constraint { variables: array![187], rhs: 1 }, Constraint { variables: array![187, 202], rhs: 1 }, Constraint { variables: array![187, 202, 217, 218, 219], rhs: 1 }, Constraint { variables: array![194, 209, 222, 223, 224], rhs: 1 }, Constraint { variables: array![218, 219, 220], rhs: 1 }, Constraint { variables: array![219, 220, 221], rhs: 2 }, Constraint { variables: array![220, 221, 222], rhs: 2 }, Constraint { variables: array![221, 222, 223], rhs: 1 }];
    let sp_hint: Array<u32> = array![10, 142, 160, 5, 6, 36, 20, 19, 90, 93, 164, 16, 17, 18, 31, 46, 61, 76, 77, 91, 105, 25, 120, 135, 150, 151, 152, 199, 200, 202, 217, 224, 166, 181, 196, 197, 183, 198, 185, 171, 186, 187, 218, 219, 220, 221, 222, 223, 209, 179, 194, 163, 133, 148, 118, 27, 28, 130, 115, 99, 103, 26, 41, 43, 58, 54, 56, 71, 73, 84, 88, 101, 117];
    let sp_nbrs: Array<u32> = array![10, 25];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 24, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let ord0v: Array<u32> = array![96];
    let ord0c: Array<Constraint> = array![Constraint { variables: array![96], rhs: 1 }];
    let ord0w = count_ordinary_component(@ord0v, @ord0c);
    aggregate = convolve_ordinary(@aggregate, @ord0w);
    let outcomes = extract_outcomes(@aggregate, 35, 34, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 2804, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00122g0f03_s004 c8');
}
#[test]
fn sq15_exact_s3_f189() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 107, 109, 111, 114, 116, 131, 141, 146, 155, 158, 161, 168, 169, 170, 171, 172, 173, 174, 175, 176];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 168, 169, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![168, 169, 41, 155, 170, 171, 172, 176, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![107];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 122, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 126, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 15899266005323518471500, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 8391279280587412526625, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 1385715844500673628250, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 71385361686398338425, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s001 c8');
}
#[test]
fn sq15_exact_s3_f190() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 155, 158, 161, 168, 169, 170, 171, 172, 173, 174, 175, 176];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 168, 169, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![106, 121, 136, 168, 169, 41, 155, 170, 171, 172, 176, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![121, 136];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 137, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 125, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 799169455294039288250, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 524225835353429441375, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 62320553853204898625, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s002 c8');
}
#[test]
fn sq15_exact_s3_f191() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 151, 155, 158, 161, 168, 169, 170, 171, 172, 173, 174, 175, 176];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 168, 169, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![151, 106, 121, 136, 168, 169, 41, 155, 170, 171, 172, 176, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![136, 151, 168];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 152, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 2);
    let outcomes = extract_outcomes(@aggregate, 35, 123, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 345241204687024972524, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 156018501401275024919, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 22001165850628206792, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 964963414501237140, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s003 c8');
}
#[test]
fn sq15_exact_s3_f192() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 151, 155, 158, 161, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![136, 151, 166, 167, 168], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 168, 169, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![106, 169, 41, 166, 167, 176, 33, 77, 92, 121, 136, 151, 168, 40, 56, 71, 161, 111, 116, 155, 170, 171, 172, 39, 114, 158, 173, 174, 175, 34, 38, 35, 131, 146, 109, 107, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![167, 168, 169];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 153, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let outcomes = extract_outcomes(@aggregate, 35, 123, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 345241204687024972524, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s004 c8');
}
#[test]
fn sq15_exact_s3_f193() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 151, 155, 158, 161, 166, 170, 171, 172, 173, 174, 175, 176];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![136, 151, 166], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![166, 151, 106, 121, 136, 41, 155, 170, 171, 172, 176, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![151, 166];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 167, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 3);
    let outcomes = extract_outcomes(@aggregate, 35, 120, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 189916591435396829640, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 124176232861605619380, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 28383138939795570144, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 2677654616961846240, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 87586833265107120, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s005 c8');
}
#[test]
fn sq15_exact_s3_f194() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 151, 155, 158, 161, 166, 170, 171, 172, 173, 174, 175, 176, 181, 182, 183];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![136, 151, 166], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![151, 166, 181, 182, 183], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }];
    let sp_hint: Array<u32> = array![106, 41, 155, 170, 171, 172, 176, 181, 182, 183, 166, 151, 121, 136, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![182, 183];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 168, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 119, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 53809700906695768398, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 62088116430802809690, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 8278415524107041292, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s006 c8');
}
#[test]
fn sq15_exact_s3_f195() {
    let sp_vars: Array<u32> = array![33, 34, 35, 36, 37, 38, 39, 40, 41, 48, 56, 63, 65, 66, 67, 71, 77, 78, 79, 82, 86, 92, 95, 101, 106, 107, 109, 111, 114, 116, 121, 131, 136, 141, 146, 151, 155, 158, 161, 166, 170, 171, 172, 173, 174, 175, 176, 181, 182, 183, 184];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![33, 34, 35, 48, 63, 65], rhs: 1 }, Constraint { variables: array![34, 35, 36, 65, 66], rhs: 2 }, Constraint { variables: array![35, 36, 37, 65, 66, 67], rhs: 3 }, Constraint { variables: array![36, 37, 38, 66, 67], rhs: 2 }, Constraint { variables: array![37, 38, 39, 67], rhs: 2 }, Constraint { variables: array![38, 39, 40], rhs: 1 }, Constraint { variables: array![39, 40, 41, 56, 71], rhs: 2 }, Constraint { variables: array![48, 63, 65, 78, 79], rhs: 3 }, Constraint { variables: array![56, 71, 86], rhs: 1 }, Constraint { variables: array![65, 66, 67, 82, 95], rhs: 5 }, Constraint { variables: array![65, 66, 79, 95], rhs: 4 }, Constraint { variables: array![67, 82], rhs: 2 }, Constraint { variables: array![71, 86, 101], rhs: 1 }, Constraint { variables: array![77, 78, 79, 92, 107, 109], rhs: 3 }, Constraint { variables: array![78, 79, 95, 109], rhs: 4 }, Constraint { variables: array![82, 95, 111], rhs: 3 }, Constraint { variables: array![82, 111], rhs: 2 }, Constraint { variables: array![82, 114], rhs: 2 }, Constraint { variables: array![86, 101, 114, 116], rhs: 1 }, Constraint { variables: array![92, 107, 109], rhs: 1 }, Constraint { variables: array![95, 109, 111], rhs: 3 }, Constraint { variables: array![101, 114, 116, 131], rhs: 1 }, Constraint { variables: array![106, 107, 121, 136], rhs: 2 }, Constraint { variables: array![107, 109], rhs: 1 }, Constraint { variables: array![109], rhs: 1 }, Constraint { variables: array![109, 111, 141], rhs: 3 }, Constraint { variables: array![111], rhs: 1 }, Constraint { variables: array![111, 141], rhs: 2 }, Constraint { variables: array![114], rhs: 1 }, Constraint { variables: array![114, 116, 131, 146], rhs: 2 }, Constraint { variables: array![121, 136, 151], rhs: 2 }, Constraint { variables: array![131, 146, 161], rhs: 1 }, Constraint { variables: array![136, 151, 166], rhs: 1 }, Constraint { variables: array![141, 155], rhs: 2 }, Constraint { variables: array![141, 155, 170, 171, 172], rhs: 2 }, Constraint { variables: array![141, 158], rhs: 2 }, Constraint { variables: array![141, 158, 171, 172, 173], rhs: 2 }, Constraint { variables: array![146, 161, 174, 175, 176], rhs: 1 }, Constraint { variables: array![151, 166, 181, 182, 183], rhs: 1 }, Constraint { variables: array![155], rhs: 1 }, Constraint { variables: array![155, 170], rhs: 1 }, Constraint { variables: array![158], rhs: 1 }, Constraint { variables: array![158, 173, 174, 175], rhs: 1 }, Constraint { variables: array![182, 183, 184], rhs: 1 }];
    let sp_hint: Array<u32> = array![184, 106, 41, 155, 170, 171, 172, 176, 181, 182, 183, 166, 151, 121, 136, 33, 77, 92, 107, 40, 56, 71, 158, 173, 161, 174, 175, 146, 131, 116, 111, 114, 39, 109, 34, 38, 35, 141, 82, 95, 36, 37, 48, 63, 65, 66, 67, 78, 79, 86, 101];
    let sp_nbrs: Array<u32> = array![155, 170, 183, 184];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 169, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 118, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 23287391568864135063, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 34139768222315382471, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 4660956639623292156, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00311g0f01_s007 c8');
}
#[test]
fn sq15_exact_s3_f196() {
    let sp0_vars: Array<u32> = array![1, 2, 3, 4, 16, 31];
    let sp0_constr: Array<Constraint> = array![Constraint { variables: array![1, 2, 3, 16, 31], rhs: 0 }, Constraint { variables: array![2, 3, 4], rhs: 0 }];
    let sp0_hint: Array<u32> = array![4, 1, 2, 3, 16, 31];
    let sp0_nbrs: Array<u32> = array![3, 4];
    let sp0_entries: Array<JointEntry> = count_joint_component_with_order(@sp0_vars, @sp0_constr, 19, @sp0_nbrs, @sp0_hint);
    let sp1_vars: Array<u32> = array![5, 6, 7, 8, 9, 20, 24, 25, 26, 39, 41, 42, 50, 57, 62, 64, 71, 72, 77, 80, 84, 87, 92, 95, 100, 102, 107, 116, 117, 122, 124, 130, 132, 137, 139, 143, 145, 146, 147, 152, 159, 160, 162, 167, 174, 177, 182, 188, 189, 190, 191, 192, 197, 198, 199, 200, 201, 202, 203];
    let sp1_constr: Array<Constraint> = array![Constraint { variables: array![5, 6, 7, 20], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9, 24, 39], rhs: 2 }, Constraint { variables: array![20, 50], rhs: 1 }, Constraint { variables: array![24, 25, 26, 39, 41], rhs: 1 }, Constraint { variables: array![24, 39], rhs: 1 }, Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 41, 71], rhs: 2 }, Constraint { variables: array![41, 42, 57, 71, 72], rhs: 1 }, Constraint { variables: array![50], rhs: 1 }, Constraint { variables: array![50, 64], rhs: 2 }, Constraint { variables: array![50, 64, 80], rhs: 3 }, Constraint { variables: array![50, 80], rhs: 2 }, Constraint { variables: array![62, 64], rhs: 1 }, Constraint { variables: array![62, 64, 77], rhs: 1 }, Constraint { variables: array![62, 64, 77, 92], rhs: 1 }, Constraint { variables: array![64, 80, 95], rhs: 3 }, Constraint { variables: array![71, 72, 87, 100, 102], rhs: 3 }, Constraint { variables: array![71, 84], rhs: 2 }, Constraint { variables: array![71, 84, 100], rhs: 3 }, Constraint { variables: array![77, 92, 107], rhs: 1 }, Constraint { variables: array![80, 95], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 100], rhs: 2 }, Constraint { variables: array![87, 100, 102, 116, 117], rhs: 3 }, Constraint { variables: array![92, 107, 122, 124], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![95, 124], rhs: 2 }, Constraint { variables: array![100, 116, 130], rhs: 3 }, Constraint { variables: array![100, 130], rhs: 2 }, Constraint { variables: array![107, 122, 124, 137, 139], rhs: 4 }, Constraint { variables: array![116, 117, 130, 132, 145, 146, 147], rhs: 4 }, Constraint { variables: array![122, 124, 137, 139, 152], rhs: 3 }, Constraint { variables: array![124, 139], rhs: 2 }, Constraint { variables: array![130, 143, 145], rhs: 3 }, Constraint { variables: array![130, 143, 145, 159, 160], rhs: 5 }, Constraint { variables: array![137, 139, 152, 167], rhs: 3 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159, 174], rhs: 3 }, Constraint { variables: array![145, 146, 147, 160, 162, 177], rhs: 3 }, Constraint { variables: array![152, 167, 182], rhs: 1 }, Constraint { variables: array![159, 160, 174, 189, 190, 191], rhs: 3 }, Constraint { variables: array![159, 174, 188, 189], rhs: 3 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 2 }, Constraint { variables: array![167, 182, 197, 198, 199], rhs: 2 }, Constraint { variables: array![188], rhs: 1 }, Constraint { variables: array![188, 201, 202, 203], rhs: 1 }, Constraint { variables: array![198, 199, 200], rhs: 1 }, Constraint { variables: array![199, 200, 201], rhs: 1 }, Constraint { variables: array![200, 201, 202], rhs: 1 }];
    let sp1_hint: Array<u32> = array![84, 5, 62, 203, 9, 25, 26, 42, 57, 197, 192, 132, 6, 77, 80, 202, 201, 200, 20, 95, 92, 7, 8, 24, 39, 41, 64, 182, 198, 199, 167, 107, 122, 124, 137, 139, 152, 50, 143, 71, 72, 87, 102, 100, 116, 117, 189, 130, 162, 177, 145, 146, 147, 159, 160, 174, 188, 190, 191];
    let sp1_nbrs: Array<u32> = array![5, 20];
    let sp1_entries: Array<JointEntry> = count_joint_component_with_order(@sp1_vars, @sp1_constr, 19, @sp1_nbrs, @sp1_hint);
    let mut aggregate: Array<JointEntry> = convolve_joint(@sp0_entries, @sp1_entries);
    let outcomes = extract_outcomes(@aggregate, 35, 76, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 168336583800, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 17489515200, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s003 c8');
}
#[test]
fn sq15_exact_s3_f197() {
    let sp_vars: Array<u32> = array![1, 2, 3, 4, 5, 6, 7, 8, 9, 16, 20, 24, 25, 26, 31, 39, 41, 42, 50, 57, 62, 64, 71, 72, 77, 80, 84, 87, 92, 95, 100, 102, 107, 116, 117, 122, 124, 130, 132, 137, 139, 143, 145, 146, 147, 152, 159, 160, 162, 167, 174, 177, 182, 188, 189, 190, 191, 192, 197, 198, 199, 200, 201, 202, 203];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![1, 2, 3, 16, 31], rhs: 0 }, Constraint { variables: array![2, 3, 4], rhs: 0 }, Constraint { variables: array![3, 4, 5, 20], rhs: 0 }, Constraint { variables: array![5, 6, 7, 20], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9, 24, 39], rhs: 2 }, Constraint { variables: array![20, 50], rhs: 1 }, Constraint { variables: array![24, 25, 26, 39, 41], rhs: 1 }, Constraint { variables: array![24, 39], rhs: 1 }, Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 41, 71], rhs: 2 }, Constraint { variables: array![41, 42, 57, 71, 72], rhs: 1 }, Constraint { variables: array![50], rhs: 1 }, Constraint { variables: array![50, 64], rhs: 2 }, Constraint { variables: array![50, 64, 80], rhs: 3 }, Constraint { variables: array![50, 80], rhs: 2 }, Constraint { variables: array![62, 64], rhs: 1 }, Constraint { variables: array![62, 64, 77], rhs: 1 }, Constraint { variables: array![62, 64, 77, 92], rhs: 1 }, Constraint { variables: array![64, 80, 95], rhs: 3 }, Constraint { variables: array![71, 72, 87, 100, 102], rhs: 3 }, Constraint { variables: array![71, 84], rhs: 2 }, Constraint { variables: array![71, 84, 100], rhs: 3 }, Constraint { variables: array![77, 92, 107], rhs: 1 }, Constraint { variables: array![80, 95], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 100], rhs: 2 }, Constraint { variables: array![87, 100, 102, 116, 117], rhs: 3 }, Constraint { variables: array![92, 107, 122, 124], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![95, 124], rhs: 2 }, Constraint { variables: array![100, 116, 130], rhs: 3 }, Constraint { variables: array![100, 130], rhs: 2 }, Constraint { variables: array![107, 122, 124, 137, 139], rhs: 4 }, Constraint { variables: array![116, 117, 130, 132, 145, 146, 147], rhs: 4 }, Constraint { variables: array![122, 124, 137, 139, 152], rhs: 3 }, Constraint { variables: array![124, 139], rhs: 2 }, Constraint { variables: array![130, 143, 145], rhs: 3 }, Constraint { variables: array![130, 143, 145, 159, 160], rhs: 5 }, Constraint { variables: array![137, 139, 152, 167], rhs: 3 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159, 174], rhs: 3 }, Constraint { variables: array![145, 146, 147, 160, 162, 177], rhs: 3 }, Constraint { variables: array![152, 167, 182], rhs: 1 }, Constraint { variables: array![159, 160, 174, 189, 190, 191], rhs: 3 }, Constraint { variables: array![159, 174, 188, 189], rhs: 3 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 2 }, Constraint { variables: array![167, 182, 197, 198, 199], rhs: 2 }, Constraint { variables: array![188], rhs: 1 }, Constraint { variables: array![188, 201, 202, 203], rhs: 1 }, Constraint { variables: array![198, 199, 200], rhs: 1 }, Constraint { variables: array![199, 200, 201], rhs: 1 }, Constraint { variables: array![200, 201, 202], rhs: 1 }];
    let sp_hint: Array<u32> = array![84, 62, 203, 1, 16, 31, 2, 3, 4, 5, 9, 25, 26, 42, 57, 197, 192, 132, 6, 77, 80, 202, 201, 200, 20, 95, 92, 7, 8, 24, 39, 41, 64, 182, 198, 199, 167, 107, 122, 124, 137, 139, 152, 50, 143, 71, 72, 87, 102, 100, 116, 117, 189, 130, 162, 177, 145, 146, 147, 159, 160, 174, 188, 190, 191];
    let sp_nbrs: Array<u32> = array![16, 31];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 32, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 75, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 150847068600, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 17489515200, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s004 c8');
}
#[test]
fn sq15_exact_s3_f198() {
    let sp_vars: Array<u32> = array![1, 2, 3, 4, 5, 6, 7, 8, 9, 16, 20, 24, 25, 26, 31, 39, 41, 42, 46, 50, 57, 62, 64, 71, 72, 77, 80, 84, 87, 92, 95, 100, 102, 107, 116, 117, 122, 124, 130, 132, 137, 139, 143, 145, 146, 147, 152, 159, 160, 162, 167, 174, 177, 182, 188, 189, 190, 191, 192, 197, 198, 199, 200, 201, 202, 203];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![1, 2, 3, 16, 31], rhs: 0 }, Constraint { variables: array![2, 3, 4], rhs: 0 }, Constraint { variables: array![3, 4, 5, 20], rhs: 0 }, Constraint { variables: array![5, 6, 7, 20], rhs: 1 }, Constraint { variables: array![6, 7, 8], rhs: 1 }, Constraint { variables: array![7, 8, 9, 24, 39], rhs: 2 }, Constraint { variables: array![16, 31, 46], rhs: 0 }, Constraint { variables: array![20, 50], rhs: 1 }, Constraint { variables: array![24, 25, 26, 39, 41], rhs: 1 }, Constraint { variables: array![24, 39], rhs: 1 }, Constraint { variables: array![39], rhs: 1 }, Constraint { variables: array![39, 41, 71], rhs: 2 }, Constraint { variables: array![41, 42, 57, 71, 72], rhs: 1 }, Constraint { variables: array![50], rhs: 1 }, Constraint { variables: array![50, 64], rhs: 2 }, Constraint { variables: array![50, 64, 80], rhs: 3 }, Constraint { variables: array![50, 80], rhs: 2 }, Constraint { variables: array![62, 64], rhs: 1 }, Constraint { variables: array![62, 64, 77], rhs: 1 }, Constraint { variables: array![62, 64, 77, 92], rhs: 1 }, Constraint { variables: array![64, 80, 95], rhs: 3 }, Constraint { variables: array![71, 72, 87, 100, 102], rhs: 3 }, Constraint { variables: array![71, 84], rhs: 2 }, Constraint { variables: array![71, 84, 100], rhs: 3 }, Constraint { variables: array![77, 92, 107], rhs: 1 }, Constraint { variables: array![80, 95], rhs: 2 }, Constraint { variables: array![84], rhs: 1 }, Constraint { variables: array![84, 100], rhs: 2 }, Constraint { variables: array![87, 100, 102, 116, 117], rhs: 3 }, Constraint { variables: array![92, 107, 122, 124], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![95, 124], rhs: 2 }, Constraint { variables: array![100, 116, 130], rhs: 3 }, Constraint { variables: array![100, 130], rhs: 2 }, Constraint { variables: array![107, 122, 124, 137, 139], rhs: 4 }, Constraint { variables: array![116, 117, 130, 132, 145, 146, 147], rhs: 4 }, Constraint { variables: array![122, 124, 137, 139, 152], rhs: 3 }, Constraint { variables: array![124, 139], rhs: 2 }, Constraint { variables: array![130, 143, 145], rhs: 3 }, Constraint { variables: array![130, 143, 145, 159, 160], rhs: 5 }, Constraint { variables: array![137, 139, 152, 167], rhs: 3 }, Constraint { variables: array![139], rhs: 1 }, Constraint { variables: array![143], rhs: 1 }, Constraint { variables: array![143, 159, 174], rhs: 3 }, Constraint { variables: array![145, 146, 147, 160, 162, 177], rhs: 3 }, Constraint { variables: array![152, 167, 182], rhs: 1 }, Constraint { variables: array![159, 160, 174, 189, 190, 191], rhs: 3 }, Constraint { variables: array![159, 174, 188, 189], rhs: 3 }, Constraint { variables: array![160, 162, 177, 190, 191, 192], rhs: 2 }, Constraint { variables: array![167, 182, 197, 198, 199], rhs: 2 }, Constraint { variables: array![188], rhs: 1 }, Constraint { variables: array![188, 201, 202, 203], rhs: 1 }, Constraint { variables: array![198, 199, 200], rhs: 1 }, Constraint { variables: array![199, 200, 201], rhs: 1 }, Constraint { variables: array![200, 201, 202], rhs: 1 }];
    let sp_hint: Array<u32> = array![46, 84, 62, 203, 1, 16, 31, 2, 3, 4, 5, 9, 25, 26, 42, 57, 197, 192, 132, 6, 77, 80, 202, 201, 200, 20, 95, 92, 7, 8, 24, 39, 41, 64, 182, 198, 199, 167, 107, 122, 124, 137, 139, 152, 50, 143, 71, 72, 87, 102, 100, 116, 117, 189, 130, 162, 177, 145, 146, 147, 159, 160, 174, 188, 190, 191];
    let sp_nbrs: Array<u32> = array![31, 46, 62];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 47, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 74, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 134968429800, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 15878638800, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00379g0f01_s005 c8');
}
#[test]
fn sq15_exact_s3_f199() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 4, 15, 19, 20, 21, 22, 23, 24, 25, 26, 27, 30, 34, 38, 42, 43, 45, 51, 54, 55, 58, 61, 63, 64, 73, 76, 88, 91, 95, 97, 98, 99, 103, 106, 107, 118, 119, 121, 125, 136, 137, 145, 151, 153, 156, 159, 166, 169, 174, 175, 179, 181, 182, 184, 186, 194, 197, 198, 199, 200, 201, 202, 203, 204, 205, 209, 220, 221, 222, 223, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 30], rhs: 0 }, Constraint { variables: array![1, 2, 3], rhs: 0 }, Constraint { variables: array![2, 3, 4, 19, 34], rhs: 1 }, Constraint { variables: array![15, 30, 45], rhs: 1 }, Constraint { variables: array![19, 20, 21, 34, 51], rhs: 2 }, Constraint { variables: array![19, 34], rhs: 1 }, Constraint { variables: array![20, 21, 22, 51], rhs: 2 }, Constraint { variables: array![21, 22, 23, 38, 51], rhs: 3 }, Constraint { variables: array![23, 24, 25, 38, 54, 55], rhs: 3 }, Constraint { variables: array![24, 25, 26, 54, 55], rhs: 2 }, Constraint { variables: array![25, 26, 27, 42, 55], rhs: 1 }, Constraint { variables: array![34, 51, 64], rhs: 3 }, Constraint { variables: array![34, 63, 64], rhs: 3 }, Constraint { variables: array![38, 51], rhs: 2 }, Constraint { variables: array![38, 54], rhs: 2 }, Constraint { variables: array![42, 43, 58, 73], rhs: 1 }, Constraint { variables: array![42, 55], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 64], rhs: 2 }, Constraint { variables: array![54], rhs: 1 }, Constraint { variables: array![54, 55], rhs: 2 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![58, 73, 88], rhs: 1 }, Constraint { variables: array![61, 63], rhs: 1 }, Constraint { variables: array![61, 63, 76], rhs: 1 }, Constraint { variables: array![61, 63, 76, 91], rhs: 1 }, Constraint { variables: array![63, 64], rhs: 2 }, Constraint { variables: array![63, 64, 95], rhs: 3 }, Constraint { variables: array![64, 95], rhs: 2 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![76, 91, 106, 107], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![95, 97], rhs: 2 }, Constraint { variables: array![95, 97, 125], rhs: 3 }, Constraint { variables: array![95, 125], rhs: 2 }, Constraint { variables: array![97, 98], rhs: 2 }, Constraint { variables: array![97, 98, 99], rhs: 3 }, Constraint { variables: array![98, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![103, 118], rhs: 2 }, Constraint { variables: array![106, 107, 121, 136, 137], rhs: 2 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 137], rhs: 2 }, Constraint { variables: array![118], rhs: 1 }, Constraint { variables: array![118, 119], rhs: 1 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 153], rhs: 2 }, Constraint { variables: array![125, 156], rhs: 2 }, Constraint { variables: array![136, 137, 151, 153, 166], rhs: 2 }, Constraint { variables: array![137, 153], rhs: 2 }, Constraint { variables: array![145], rhs: 1 }, Constraint { variables: array![145, 159], rhs: 2 }, Constraint { variables: array![145, 159, 174, 175], rhs: 4 }, Constraint { variables: array![145, 175], rhs: 2 }, Constraint { variables: array![151, 153, 166, 181, 182], rhs: 1 }, Constraint { variables: array![153, 169], rhs: 2 }, Constraint { variables: array![153, 169, 182, 184], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 169], rhs: 2 }, Constraint { variables: array![156, 169, 184, 186], rhs: 4 }, Constraint { variables: array![156, 186], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![169, 182, 184, 197, 198, 199], rhs: 2 }, Constraint { variables: array![169, 184, 186, 199, 200, 201], rhs: 3 }, Constraint { variables: array![174, 175, 203, 204, 205], rhs: 2 }, Constraint { variables: array![174, 175, 204, 205], rhs: 2 }, Constraint { variables: array![174, 202, 203, 204], rhs: 1 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 205], rhs: 1 }, Constraint { variables: array![179], rhs: 1 }, Constraint { variables: array![179, 194], rhs: 2 }, Constraint { variables: array![179, 194, 209], rhs: 2 }, Constraint { variables: array![186, 201, 202, 203], rhs: 1 }, Constraint { variables: array![194, 209, 222, 223, 224], rhs: 2 }, Constraint { variables: array![205, 220, 221, 222], rhs: 2 }, Constraint { variables: array![221, 222, 223], rhs: 1 }];
    let sp_hint: Array<u32> = array![119, 45, 98, 99, 97, 118, 103, 88, 179, 43, 58, 73, 61, 145, 159, 220, 0, 15, 30, 1, 2, 3, 4, 19, 27, 42, 26, 121, 175, 181, 194, 209, 224, 223, 221, 222, 205, 174, 204, 202, 203, 24, 25, 54, 55, 23, 38, 22, 20, 21, 51, 34, 64, 197, 198, 200, 201, 95, 186, 199, 169, 184, 156, 63, 76, 91, 106, 107, 125, 136, 137, 151, 153, 166, 182];
    let sp_nbrs: Array<u32> = array![30, 45, 61];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 46, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 37, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 8436, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 703, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s005 c8');
}
#[test]
fn sq15_exact_s3_f200() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 4, 15, 19, 20, 21, 22, 23, 24, 25, 26, 27, 30, 34, 38, 42, 43, 51, 54, 55, 58, 61, 63, 64, 73, 76, 88, 91, 95, 97, 98, 99, 103, 106, 107, 118, 119, 121, 125, 136, 137, 145, 151, 153, 156, 159, 166, 169, 174, 175, 179, 181, 182, 184, 186, 194, 197, 198, 199, 200, 201, 202, 203, 204, 205, 209, 220, 221, 222, 223, 224];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 30], rhs: 0 }, Constraint { variables: array![1, 2, 3], rhs: 0 }, Constraint { variables: array![2, 3, 4, 19, 34], rhs: 1 }, Constraint { variables: array![19, 20, 21, 34, 51], rhs: 2 }, Constraint { variables: array![19, 34], rhs: 1 }, Constraint { variables: array![20, 21, 22, 51], rhs: 2 }, Constraint { variables: array![21, 22, 23, 38, 51], rhs: 3 }, Constraint { variables: array![23, 24, 25, 38, 54, 55], rhs: 3 }, Constraint { variables: array![24, 25, 26, 54, 55], rhs: 2 }, Constraint { variables: array![25, 26, 27, 42, 55], rhs: 1 }, Constraint { variables: array![34, 51, 64], rhs: 3 }, Constraint { variables: array![34, 63, 64], rhs: 3 }, Constraint { variables: array![38, 51], rhs: 2 }, Constraint { variables: array![38, 54], rhs: 2 }, Constraint { variables: array![42, 43, 58, 73], rhs: 1 }, Constraint { variables: array![42, 55], rhs: 1 }, Constraint { variables: array![51], rhs: 1 }, Constraint { variables: array![51, 64], rhs: 2 }, Constraint { variables: array![54], rhs: 1 }, Constraint { variables: array![54, 55], rhs: 2 }, Constraint { variables: array![55], rhs: 1 }, Constraint { variables: array![58, 73, 88], rhs: 1 }, Constraint { variables: array![61, 63], rhs: 1 }, Constraint { variables: array![61, 63, 76], rhs: 1 }, Constraint { variables: array![61, 63, 76, 91], rhs: 1 }, Constraint { variables: array![63, 64], rhs: 2 }, Constraint { variables: array![63, 64, 95], rhs: 3 }, Constraint { variables: array![64, 95], rhs: 2 }, Constraint { variables: array![73, 88, 103], rhs: 1 }, Constraint { variables: array![76, 91, 106, 107], rhs: 1 }, Constraint { variables: array![88, 103, 118], rhs: 2 }, Constraint { variables: array![95], rhs: 1 }, Constraint { variables: array![95, 97], rhs: 2 }, Constraint { variables: array![95, 97, 125], rhs: 3 }, Constraint { variables: array![95, 125], rhs: 2 }, Constraint { variables: array![97, 98], rhs: 2 }, Constraint { variables: array![97, 98, 99], rhs: 3 }, Constraint { variables: array![98, 99], rhs: 2 }, Constraint { variables: array![99], rhs: 1 }, Constraint { variables: array![103, 118], rhs: 2 }, Constraint { variables: array![106, 107, 121, 136, 137], rhs: 2 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 137], rhs: 2 }, Constraint { variables: array![118], rhs: 1 }, Constraint { variables: array![118, 119], rhs: 1 }, Constraint { variables: array![125], rhs: 1 }, Constraint { variables: array![125, 153], rhs: 2 }, Constraint { variables: array![125, 156], rhs: 2 }, Constraint { variables: array![136, 137, 151, 153, 166], rhs: 2 }, Constraint { variables: array![137, 153], rhs: 2 }, Constraint { variables: array![145], rhs: 1 }, Constraint { variables: array![145, 159], rhs: 2 }, Constraint { variables: array![145, 159, 174, 175], rhs: 4 }, Constraint { variables: array![145, 175], rhs: 2 }, Constraint { variables: array![151, 153, 166, 181, 182], rhs: 1 }, Constraint { variables: array![153, 169], rhs: 2 }, Constraint { variables: array![153, 169, 182, 184], rhs: 3 }, Constraint { variables: array![156], rhs: 1 }, Constraint { variables: array![156, 169], rhs: 2 }, Constraint { variables: array![156, 169, 184, 186], rhs: 4 }, Constraint { variables: array![156, 186], rhs: 2 }, Constraint { variables: array![159], rhs: 1 }, Constraint { variables: array![159, 174], rhs: 2 }, Constraint { variables: array![169, 182, 184, 197, 198, 199], rhs: 2 }, Constraint { variables: array![169, 184, 186, 199, 200, 201], rhs: 3 }, Constraint { variables: array![174, 175, 203, 204, 205], rhs: 2 }, Constraint { variables: array![174, 175, 204, 205], rhs: 2 }, Constraint { variables: array![174, 202, 203, 204], rhs: 1 }, Constraint { variables: array![175], rhs: 1 }, Constraint { variables: array![175, 205], rhs: 1 }, Constraint { variables: array![179], rhs: 1 }, Constraint { variables: array![179, 194], rhs: 2 }, Constraint { variables: array![179, 194, 209], rhs: 2 }, Constraint { variables: array![186, 201, 202, 203], rhs: 1 }, Constraint { variables: array![194, 209, 222, 223, 224], rhs: 2 }, Constraint { variables: array![205, 220, 221, 222], rhs: 2 }, Constraint { variables: array![221, 222, 223], rhs: 1 }];
    let sp_hint: Array<u32> = array![119, 98, 99, 97, 118, 103, 88, 179, 43, 58, 73, 61, 145, 159, 220, 0, 15, 30, 1, 2, 3, 4, 19, 27, 42, 26, 121, 175, 181, 194, 209, 224, 223, 221, 222, 205, 174, 204, 202, 203, 24, 25, 54, 55, 23, 38, 22, 20, 21, 51, 34, 64, 197, 198, 200, 201, 95, 186, 199, 169, 184, 156, 63, 76, 91, 106, 107, 125, 136, 137, 151, 153, 166, 182];
    let sp_nbrs: Array<u32> = array![15, 30];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 31, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    aggregate = apply_unconstrained_local(@aggregate, false, 1);
    let outcomes = extract_outcomes(@aggregate, 35, 38, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 82251, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 9139, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00099g0f03_s004 c8');
}
#[test]
fn sq15_exact_s3_f201() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 4, 8, 9, 10, 11, 15, 19, 23, 25, 26, 30, 31, 45, 49, 55, 58, 59, 60, 70, 74, 75, 76, 89, 90, 91, 94, 103, 104, 105, 107, 109, 117, 119, 120, 127, 134, 135, 140, 141, 144, 149, 150, 152, 164, 165, 177, 179, 180, 181, 185, 186, 189, 194, 196, 206, 208, 209, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 30, 31], rhs: 1 }, Constraint { variables: array![1, 2, 3, 31], rhs: 1 }, Constraint { variables: array![2, 3, 4, 19], rhs: 1 }, Constraint { variables: array![4, 19], rhs: 1 }, Constraint { variables: array![8, 9, 10, 23, 25], rhs: 2 }, Constraint { variables: array![8, 23], rhs: 1 }, Constraint { variables: array![11, 26], rhs: 2 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 25, 55], rhs: 3 }, Constraint { variables: array![25, 26, 55], rhs: 3 }, Constraint { variables: array![26, 58], rhs: 2 }, Constraint { variables: array![30, 31, 45, 60], rhs: 1 }, Constraint { variables: array![31], rhs: 1 }, Constraint { variables: array![45, 60, 75, 76], rhs: 1 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![55, 70], rhs: 2 }, Constraint { variables: array![58], rhs: 1 }, Constraint { variables: array![58, 59], rhs: 1 }, Constraint { variables: array![58, 59, 74, 89], rhs: 1 }, Constraint { variables: array![70], rhs: 1 }, Constraint { variables: array![74, 89, 103, 104], rhs: 2 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 2 }, Constraint { variables: array![76, 91, 107], rhs: 3 }, Constraint { variables: array![90, 91, 105, 107, 120], rhs: 2 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![94, 107, 109], rhs: 3 }, Constraint { variables: array![94, 109], rhs: 2 }, Constraint { variables: array![103], rhs: 1 }, Constraint { variables: array![103, 104, 117, 119, 134], rhs: 3 }, Constraint { variables: array![103, 117], rhs: 2 }, Constraint { variables: array![105, 107, 120, 135], rhs: 1 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 109], rhs: 2 }, Constraint { variables: array![109, 140], rhs: 2 }, Constraint { variables: array![109, 140, 141], rhs: 3 }, Constraint { variables: array![117], rhs: 1 }, Constraint { variables: array![117, 119, 134, 149], rhs: 2 }, Constraint { variables: array![120, 135, 150, 152], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 140, 141], rhs: 3 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![127, 144], rhs: 2 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![135, 150, 152, 165], rhs: 2 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 141], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![149, 164, 177, 179], rhs: 2 }, Constraint { variables: array![150, 152, 165, 180, 181], rhs: 3 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 181], rhs: 2 }, Constraint { variables: array![164, 177, 179, 194], rhs: 1 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 179, 194, 208, 209], rhs: 2 }, Constraint { variables: array![177, 206], rhs: 2 }, Constraint { variables: array![177, 206, 208], rhs: 2 }, Constraint { variables: array![181, 196], rhs: 1 }, Constraint { variables: array![181, 196, 211, 212, 213], rhs: 3 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 214, 215, 216], rhs: 2 }, Constraint { variables: array![185, 186, 215, 216, 217], rhs: 3 }, Constraint { variables: array![185, 213, 214, 215], rhs: 1 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![186, 216, 217, 218], rhs: 2 }, Constraint { variables: array![189], rhs: 1 }, Constraint { variables: array![189, 206], rhs: 2 }, Constraint { variables: array![189, 206, 219, 220, 221], rhs: 2 }, Constraint { variables: array![189, 217, 218, 219], rhs: 2 }, Constraint { variables: array![189, 218, 219, 220], rhs: 1 }, Constraint { variables: array![206, 208, 221, 222, 223], rhs: 1 }, Constraint { variables: array![212, 213, 214], rhs: 1 }];
    let sp_hint: Array<u32> = array![11, 49, 70, 144, 94, 127, 140, 141, 109, 4, 19, 3, 59, 75, 8, 9, 10, 23, 25, 55, 26, 58, 74, 89, 90, 103, 104, 117, 119, 134, 149, 164, 179, 194, 209, 177, 180, 196, 211, 208, 222, 223, 206, 221, 220, 189, 219, 218, 217, 186, 216, 185, 215, 214, 212, 213, 181, 165, 150, 152, 135, 105, 120, 91, 107, 76, 45, 60, 0, 1, 2, 15, 30, 31];
    let sp_nbrs: Array<u32> = array![11, 26];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 12, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let outcomes = extract_outcomes(@aggregate, 35, 3, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s001 c8');
}
#[test]
fn sq15_exact_s3_f202() {
    let sp_vars: Array<u32> = array![0, 1, 2, 3, 4, 8, 9, 10, 11, 15, 19, 23, 25, 26, 30, 31, 45, 49, 55, 58, 59, 60, 70, 74, 75, 76, 89, 90, 91, 94, 103, 104, 105, 107, 109, 117, 119, 120, 127, 134, 135, 140, 141, 144, 149, 150, 152, 164, 165, 177, 179, 180, 181, 185, 186, 189, 194, 196, 206, 208, 209, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223];
    let sp_constr: Array<Constraint> = array![Constraint { variables: array![0, 1, 2, 15, 30, 31], rhs: 1 }, Constraint { variables: array![1, 2, 3, 31], rhs: 1 }, Constraint { variables: array![2, 3, 4, 19], rhs: 1 }, Constraint { variables: array![4, 19], rhs: 1 }, Constraint { variables: array![8, 9, 10, 23, 25], rhs: 2 }, Constraint { variables: array![8, 23], rhs: 1 }, Constraint { variables: array![11, 26], rhs: 2 }, Constraint { variables: array![19, 49], rhs: 2 }, Constraint { variables: array![23], rhs: 1 }, Constraint { variables: array![23, 25, 55], rhs: 3 }, Constraint { variables: array![25, 26, 55], rhs: 3 }, Constraint { variables: array![26, 58], rhs: 2 }, Constraint { variables: array![30, 31, 45, 60], rhs: 1 }, Constraint { variables: array![31], rhs: 1 }, Constraint { variables: array![45, 60, 75, 76], rhs: 1 }, Constraint { variables: array![49], rhs: 1 }, Constraint { variables: array![55, 70], rhs: 2 }, Constraint { variables: array![58], rhs: 1 }, Constraint { variables: array![58, 59], rhs: 1 }, Constraint { variables: array![58, 59, 74, 89], rhs: 1 }, Constraint { variables: array![70], rhs: 1 }, Constraint { variables: array![74, 89, 103, 104], rhs: 2 }, Constraint { variables: array![76], rhs: 1 }, Constraint { variables: array![76, 91], rhs: 2 }, Constraint { variables: array![76, 91, 107], rhs: 3 }, Constraint { variables: array![90, 91, 105, 107, 120], rhs: 2 }, Constraint { variables: array![94], rhs: 1 }, Constraint { variables: array![94, 107, 109], rhs: 3 }, Constraint { variables: array![94, 109], rhs: 2 }, Constraint { variables: array![103], rhs: 1 }, Constraint { variables: array![103, 104, 117, 119, 134], rhs: 3 }, Constraint { variables: array![103, 117], rhs: 2 }, Constraint { variables: array![105, 107, 120, 135], rhs: 1 }, Constraint { variables: array![107], rhs: 1 }, Constraint { variables: array![107, 109], rhs: 2 }, Constraint { variables: array![109, 140], rhs: 2 }, Constraint { variables: array![109, 140, 141], rhs: 3 }, Constraint { variables: array![117], rhs: 1 }, Constraint { variables: array![117, 119, 134, 149], rhs: 2 }, Constraint { variables: array![120, 135, 150, 152], rhs: 1 }, Constraint { variables: array![127], rhs: 1 }, Constraint { variables: array![127, 140, 141], rhs: 3 }, Constraint { variables: array![127, 141], rhs: 2 }, Constraint { variables: array![127, 144], rhs: 2 }, Constraint { variables: array![134, 149, 164], rhs: 1 }, Constraint { variables: array![135, 150, 152, 165], rhs: 2 }, Constraint { variables: array![140], rhs: 1 }, Constraint { variables: array![140, 141], rhs: 2 }, Constraint { variables: array![141], rhs: 1 }, Constraint { variables: array![144], rhs: 1 }, Constraint { variables: array![149, 164, 177, 179], rhs: 2 }, Constraint { variables: array![150, 152, 165, 180, 181], rhs: 3 }, Constraint { variables: array![152], rhs: 1 }, Constraint { variables: array![152, 181], rhs: 2 }, Constraint { variables: array![164, 177, 179, 194], rhs: 1 }, Constraint { variables: array![177], rhs: 1 }, Constraint { variables: array![177, 179, 194, 208, 209], rhs: 2 }, Constraint { variables: array![177, 206], rhs: 2 }, Constraint { variables: array![177, 206, 208], rhs: 2 }, Constraint { variables: array![181, 196], rhs: 1 }, Constraint { variables: array![181, 196, 211, 212, 213], rhs: 3 }, Constraint { variables: array![185], rhs: 1 }, Constraint { variables: array![185, 186], rhs: 2 }, Constraint { variables: array![185, 186, 214, 215, 216], rhs: 2 }, Constraint { variables: array![185, 186, 215, 216, 217], rhs: 3 }, Constraint { variables: array![185, 213, 214, 215], rhs: 1 }, Constraint { variables: array![186], rhs: 1 }, Constraint { variables: array![186, 216, 217, 218], rhs: 2 }, Constraint { variables: array![189], rhs: 1 }, Constraint { variables: array![189, 206], rhs: 2 }, Constraint { variables: array![189, 206, 219, 220, 221], rhs: 2 }, Constraint { variables: array![189, 217, 218, 219], rhs: 2 }, Constraint { variables: array![189, 218, 219, 220], rhs: 1 }, Constraint { variables: array![206, 208, 221, 222, 223], rhs: 1 }, Constraint { variables: array![212, 213, 214], rhs: 1 }];
    let sp_hint: Array<u32> = array![11, 49, 70, 144, 94, 127, 140, 141, 109, 4, 19, 3, 59, 75, 8, 9, 10, 23, 25, 55, 26, 58, 74, 89, 90, 103, 104, 117, 119, 134, 149, 164, 179, 194, 209, 177, 180, 196, 211, 208, 222, 223, 206, 221, 220, 189, 219, 218, 217, 186, 216, 185, 215, 214, 212, 213, 181, 165, 150, 152, 135, 105, 120, 91, 107, 76, 45, 60, 0, 1, 2, 15, 30, 31];
    let sp_nbrs: Array<u32> = array![58, 59];
    let sp_entries: Array<JointEntry> = count_joint_component_with_order(@sp_vars, @sp_constr, 44, @sp_nbrs, @sp_hint);
    let mut aggregate: Array<JointEntry> = sp_entries;
    let outcomes = extract_outcomes(@aggregate, 35, 3, 0);
    assert(u512_eq(*outcomes.at(0), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 mine');
    assert(u512_eq(*outcomes.at(1), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c0');
    assert(u512_eq(*outcomes.at(2), u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c1');
    assert(u512_eq(*outcomes.at(3), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c2');
    assert(u512_eq(*outcomes.at(4), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c3');
    assert(u512_eq(*outcomes.at(5), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c4');
    assert(u512_eq(*outcomes.at(6), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c5');
    assert(u512_eq(*outcomes.at(7), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c6');
    assert(u512_eq(*outcomes.at(8), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c7');
    assert(u512_eq(*outcomes.at(9), u512 { limb0: 0, limb1: 0, limb2: 0, limb3: 0 }), 's00177g0f03_s005 c8');
}
