#!/bin/bash

while true; do
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    echo "CPU Usage: $CPU_USAGE%"

    if (( $(echo "$CPU_USAGE > 75" | bc -l) )); then
        echo "CPU usage exceeded 75%. Creating a new VM in GCP..."

        # Create a temporary startup script file
        cat <<EOF > startup-script.sh
#!/bin/bash
sudo apt update
sudo apt install -y python3 python3-pip
pip3 install flask
mkdir -p /home/anushka/prime-checker
cat <<EOPY > /home/anushka/prime-checker/app.py
from flask import Flask
import math
import multiprocessing
app = Flask(__name__)
def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True
def check_primes(start, end):
    primes = [n for n in range(start, end) if is_prime(n)]
    return primes
@app.route("/")
def home():
    return "GCP Instance Handling Prime Checking"
@app.route("/stress")
def stress():
    start = 10**10
    end = start + 10**5
    processes = []
    for _ in range(multiprocessing.cpu_count()):
        p = multiprocessing.Process(target=check_primes, args=(start, end))
        p.start()
        processes.append(p)
    for p in processes:
        p.join()
    return "Prime Calculation Completed!"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOPY
python3 /home/anushka/prime-checker/app.py &
EOF

        # Create a new VM with the script
        gcloud compute instances create "scaled-vm-$(date +%s)" \
            --zone=asia-south1-b \
            --machine-type=n1-standard-1 \
            --image-family=ubuntu-2204-lts \
            --image-project=ubuntu-os-cloud \
            --tags=http-server \
            --metadata-from-file=startup-script=startup-script.sh

        # Remove the temp script file
        rm startup-script.sh

        sleep 60  # Wait for VM to start
    fi

    sleep 5  # Check CPU usage every 5 seconds
done