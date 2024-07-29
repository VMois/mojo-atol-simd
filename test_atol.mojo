from testing import *
from simd_atol import atol, _is_uint


fn test_is_int() raises:
    assert_equal(True, _is_uint("375"), "375 should be a valid uint.")
    assert_equal(True, _is_uint("001"), "001 should be a valid uint.")
    assert_equal(False, _is_uint(String("9.03")), "9.03 is not a valid uint.")
    assert_equal(False, _is_uint("/102"), "/102 is not a valid uint.")


fn test_simd_atol() raises:
    assert_equal(375, atol(String("375")))
    assert_equal(1, atol(String("001")))
    assert_equal(5852010871235579, atol(String("5852010871235579")))
    assert_equal(9999, atol(String("9999")))
    assert_equal(0, atol(String("0000")))
    assert_equal(0, atol(String("0")))

