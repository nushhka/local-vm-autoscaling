from flask import Flask
import math
import multiprocessing

app = Flask(__name__)

def cpu_intensive_task():
    """Function to consume high CPU"""
    result = 0
    for _ in range(10**7):  # Perform heavy calculations
        result += math.sqrt(123456789)
    return result

@app.route('/')
def home():
    return "CPU Stress Microservice Running!"

@app.route('/stress')
def stress():
    """Endpoint that triggers high CPU usage"""
    processes = []
    for _ in range(multiprocessing.cpu_count()):  # Use all CPU cores
        p = multiprocessing.Process(target=cpu_intensive_task)
        p.start()
        processes.append(p)

    for p in processes:
        p.join()

    return "CPU Intensive Task Completed!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
