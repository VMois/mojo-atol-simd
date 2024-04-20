from tensor import Tensor
from utils.loop import unroll

alias char = Int8
alias simd_width = simdwidthof[char]()


fn _is_uint(s: String) raises -> Bool:
    """
    Check if string up to 16 characters is an unsigned int.
    """
    if len(s) == 0 or len(s) > 16:
        raise Error("Support only strings with 1 to 16 chars")
        
    var ptr = rebind[DTypePointer[DType.uint8]](s._buffer.data)
    alias lower_boundry = SIMD[DType.uint8, simd_width](47)
    alias upper_boundry = SIMD[DType.uint8, simd_width](57)
    var is_int = True

    @parameter
    fn compare_smaller[i: Int]():
        if simd_width - len(s) == i:
            var adjusted_input = ptr.load[width=simd_width](0).shift_right[i]()
            #print(upper_boundry - adjusted_input)
            #print(lower_boundry - adjusted_input) 
            var max_char = (upper_boundry - adjusted_input).reduce_max[1]()
            var min_char = (lower_boundry - adjusted_input).reduce_min[1]()
            #print(max_char, min_char)
            if max_char > 57 or min_char < 47:
                is_int = False


    unroll[compare_smaller, simd_width]()
    return is_int 


fn atol(s: String) raises -> Int:
    return 42


fn main() raises:
    var s1: String = "2357"
    var s2: String = "-1257"
    var s3: String = "9.03"

    print(_is_uint(s3))

