def exec_time_decorator(func):
    import time
    def wrapper():
        start_time = time.time()
        func()
        end_time = time.time()
        print(f"Execution time: {end_time - start_time:.6f} seconds")
    return wrapper

@exec_time_decorator
def say_hello():
    print("Hello!")

say_hello()