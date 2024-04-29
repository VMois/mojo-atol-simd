from benchmark import benchmark
from simd_atol import atol as simd_str_to_uint

alias file_name = "numbers.txt"
alias size = 10000000


fn main() raises:
    var numbers = List[String](capacity=size)
    var i = 0
    with open(file_name, "r") as f:
        var number: String = ""
        while True:
            var c = f.read(1)
            if c == "":
                break
            if c == "\n":
                numbers.append(number)
                i += 1
                
                number = ""
                continue
            number += c

    print("Finished loading numbers. Loaded", len(numbers))
    
    @parameter
    fn run_atol():
        for i in range(size):
            var number = numbers[i]
            try:
                _ = atol(number)
            except:
                print("atol failed")
    
    @parameter
    fn run_simd_atol():
        for i in range(size):
            var number = numbers[i]
            try:
                _ = simd_str_to_uint(number)
            except:
                print("simd atol failed")
    var report = benchmark.run[run_simd_atol]()
    report.print()
    _ = numbers
