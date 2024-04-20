
from testing import *
from simd_atol import atol, _is_uint


fn test_is_int() raises:
    assert_equal(True, _is_uint("375"), "375 should be a valid uint.")
    assert_equal(True, _is_uint("001"), "001 should be a valid uint.")
    assert_equal(False, _is_uint("9.03"), "9.03 is not a valid uint.")


fn test_atol() raises:
    assert_equal(375, atol(String("375")))
    assert_equal(1, atol(String("001")))
    assert_equal(-89, atol(String("-89")))

    # Negative cases
    try:
        _ = atol(String("9.03"))
        raise Error("Failed to raise when converting string to integer.")
    except e:
        assert_equal(str(e), "String is not convertible to integer.")

    try:
        _ = atol(String(""))
        raise Error("Failed to raise when converting empty string to integer.")
    except e:
        assert_equal(str(e), "Empty String cannot be converted to integer.")

    try:
        _ = atol(String("9223372036854775832"))
        raise Error(
            "Failed to raise when converting an integer too large to store in"
            " Int."
        )
    except e:
        assert_equal(
            str(e), "String expresses an integer too large to store in Int."
        )

fn main() raises:
    #test_atol()
    test_is_int()
