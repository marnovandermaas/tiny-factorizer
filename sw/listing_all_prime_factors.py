for n in range(1, 256):
    print(str(n) + ": ", end="")
    for k in range(2, n):
        if n % k == 0:
            print(str(k) + ", ", end="")
    print("")
