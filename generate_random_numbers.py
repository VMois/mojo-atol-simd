import random


def generate_random_ints(num_ints, min_digits, max_digits):
    with open("numbers.txt", "w") as file:
        for _ in range(num_ints):
            num_digits = random.randint(min_digits, max_digits)
            max_value = 10 ** num_digits - 1
            value = random.randint(0, max_value)
            file.write(f"{str(value)}\n")

    print(f"Generated {num_ints} random integers and wrote them to numbers.txt")


generate_random_ints(10000000, 16, 16)
