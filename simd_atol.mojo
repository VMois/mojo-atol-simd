from memory import bitcast

alias char = Int8
alias simd_width = simdwidthof[char]()


@always_inline
fn _is_uint(s: String) raises -> Bool:
    """
    Check if string up to 16 characters is an unsigned int.
    """
    if len(s) == 0 or len(s) > 16:
        raise Error("Support only strings with 1 to 16 chars")
        
    var ptr = s.unsafe_ptr()
    alias lower_boundry = SIMD[DType.uint8, simd_width](48)
    alias upper_boundry = SIMD[DType.uint8, simd_width](57)
    alias zeros = SIMD[DType.uint8, simd_width](0)
    
    @parameter
    for i in range(simd_width):
        if simd_width - len(s) == i:
            var value = SIMD[size=simd_width].load(ptr, 0).shift_right[i]()
            var z = value != zeros
            var up = (value > upper_boundry) & z
            var down = (value < lower_boundry) & z

            if up.reduce_or() or down.reduce_or():
                return False

    return True 


@always_inline
fn _combine_chunks[new_dtype: DType, old_dtype: DType, old_len: Int](value: SIMD[old_dtype, old_len]) raises -> SIMD[new_dtype, old_len // 2]:
    var left_selected: SIMD[old_dtype, old_len]
    var right_selected: SIMD[old_dtype, old_len]
    var right_multiplied: SIMD[old_dtype, old_len]
    @parameter
    if old_len == 16:
        alias even_mask = SIMD[old_dtype, old_len](0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f)
        alias odd_mask = SIMD[old_dtype, old_len](0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0, 0x0f, 0)
        left_selected = value & even_mask
        right_selected = value & odd_mask
        var left_shifted = left_selected.shift_left[1]()
        alias multiplier = SIMD[old_dtype, old_len](10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0)
        right_multiplied = right_selected * multiplier

        #print("16 size, left selected", left_selected)
        #print("16 size, right selected", right_selected)
        #print("16 size, right multipled", right_multiplied)
        #print("16 size, left shifted", left_shifted)
        return bitcast[new_dtype, old_len // 2](left_shifted + right_multiplied)
    elif old_len == 8:
        alias even_mask = SIMD[old_dtype, old_len](0, 0x00ff, 0, 0x00ff, 0, 0x00ff, 0, 0x00ff)
        alias odd_mask = SIMD[old_dtype, old_len](0x00ff, 0, 0x00ff, 0, 0x00ff, 0, 0x00ff, 0)
        left_selected = value & even_mask
        right_selected = value & odd_mask
        var left_shifted = left_selected.shift_left[1]()
        alias multiplier = SIMD[old_dtype, old_len](100, 0, 100, 0, 100, 0, 100, 0)
        right_multiplied = right_selected * multiplier
        #print("8 size, left selected", left_selected)
        #print("8 size, right selected", right_selected)
        #print("8 size, right multipled", right_multiplied)
        #print("8 size, left shifted", left_shifted)
        return bitcast[new_dtype, old_len // 2](left_shifted + right_multiplied)
    elif old_len == 4:
        alias even_mask = SIMD[old_dtype, old_len](0, 0xffff, 0, 0xffff)
        alias odd_mask = SIMD[old_dtype, old_len](0xffff, 0, 0xffff, 0)
        left_selected = value & even_mask
        right_selected = value & odd_mask
        var left_shifted = left_selected.shift_left[1]()
        alias multiplier = SIMD[old_dtype, old_len](10000, 0, 10000, 0)
        right_multiplied = right_selected * multiplier
        #print("4 size, left selected", left_selected)
        #print("4 size, right selected", right_selected)
        #print("4 size, right multipled", right_multiplied)
        #print("4 size, left shifted", left_shifted)
        return bitcast[new_dtype, old_len // 2](left_shifted + right_multiplied)
    elif old_len == 2:
        #print("2 size", value)
        return (value[0] * 100000000 + value[1]).cast[new_dtype]()
    else:
        raise Error("Unsupported length")


fn atol[validation: Bool = True](s: String) raises -> Int:
    """
    Convert String that consists of 16 or less characters into integer.
    """
    @parameter
    if validation:
        if len(s) == 0 or len(s) > 16:
            raise Error("Only 16 or less Strings are supported.")

        if not _is_uint(s):
            raise Error("String is not convertible to integer.")

    #print("Original:", s)
    alias zeros = SIMD[DType.uint8, simd_width](48)
    var ptr = s.unsafe_ptr()
    
    var adjusted_value = SIMD[size=simd_width].load(ptr, 0) - zeros
    #print("Adjusted value", adjusted_value)
    var chunk16 = _combine_chunks[DType.uint16](adjusted_value)
    #print(chunk16)
    
    var chunk32 = _combine_chunks[DType.uint32](chunk16)
    #print(chunk32)
    
    var chunk32_2 = _combine_chunks[DType.uint64](chunk32)
    #print(chunk32_2)
    
    var chunk32_3 = _combine_chunks[DType.uint64](chunk32_2)
    #print(chunk32_3)

    return int(chunk32_3) // (10 ** (simd_width - len(s)))

