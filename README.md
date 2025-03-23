# 🚀 Auto-Scaling Flask Microservice: Local VM to GCP  

## 📌 Project Overview  
This project demonstrates **auto-scaling** of a **Flask-based microservice** from a local Virtual Machine (VM) to **Google Cloud Platform (GCP)**.  
The system **monitors CPU usage**, and when it exceeds **75%**, it automatically **deploys a new GCP VM** running the same application.  

## 🏗 Architecture  
- A **Flask microservice** running on a **local VM**.
- The **monitoring script** checks CPU usage every 10 seconds.
- When CPU usage **exceeds 75%**, a **new GCP VM is created**.
- The new VM is **automatically configured** and starts handling requests.

### 📜 Architecture Diagram  
![Auto-Scaling Diagram](diagrams/autoscaling.png)  

## 📂 Project Structure  
```
local-vm-autoscaling/
│── 📄 README.md            # Project documentation
│── 📁 src/                 # Source code folder
│   ├── 📄 app.py           # Flask microservice
│   ├── 📄 requirements.txt # Dependencies
│── 📁 scripts/             # Automation scripts
│   ├── 📄 monitor_resources.sh  # CPU monitoring and scaling script
│── 📁 diagrams/            # Architecture diagrams
│   ├── 🖼 autoscaling.png   # architecture diagram
```

## ⚙️ Installation & Setup  
### **1️⃣ Clone the Repository**  
```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/AutoScaling-VM-to-GCP.git
cd AutoScaling-VM-to-GCP
```

### **2️⃣ Install Dependencies**  
```bash
pip install -r src/requirements.txt
```

### **3️⃣ Run the Flask Application**  
```bash
python src/app.py
```
Open **http://localhost:5000** in a browser.  

## 📜 Auto-Scaling Mechanism  
### **1️⃣ Monitor CPU Usage**
- The `monitor_resources.sh` script checks CPU usage **every 10 seconds**.
- If CPU usage **exceeds 75%**, it triggers **GCP auto-scaling**.

### **2️⃣ Create New VM on GCP**
The script executes:
```bash
gcloud compute instances create scaled-vm-$(date +%s)     --zone=us-central1-b     --machine-type=n1-standard-1     --image-family=ubuntu-2204-lts     --image-project=ubuntu-os-cloud     --metadata=startup-script='#! /bin/bash
    sudo apt update
    sudo apt install -y python3 python3-pip
    pip3 install flask
    mkdir /home/anushka/cpu-stress-app
    echo "from flask import Flask
    import math
    import multiprocessing
    app = Flask(__name__)
    def cpu_intensive_task():
        result = 0
        for _ in range(10**7):
            result += math.sqrt(123456789)
        return result
    @app.route("/")
    def home():
        return "CPU Stress Microservice Running!"
    @app.route("/stress")
    def stress():
        processes = []
        for _ in range(multiprocessing.cpu_count()):
            p = multiprocessing.Process(target=cpu_intensive_task)
            p.start()
            processes.append(p)
        for p in processes:
            p.join()
        return "CPU Intensive Task Completed!"
    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=5000)" > /home/anushka/cpu-stress-app/app.py
    python3 /home/anushka/cpu-stress-app/app.py &'
```
This **deploys the same Flask microservice** on a **new VM**.

### **3️⃣ Redirect Traffic to GCP VM**
- Once the new VM is created, users can **access it via the external IP**.
- The **service remains available**, even under heavy load.

## Testing the Auto-Scaling Mechanism  
### **1️⃣ Simulate High CPU Load**
Run:
```bash
while true; do curl http://localhost:5000; done
```
This will keep sending requests, increasing CPU usage.  

### **2️⃣ Check if a New VM is Created**
```bash
gcloud compute instances list
```
A new instance (e.g., `scaled-vm-123456789`) should appear.

### **3️⃣ Verify Flask Running on GCP VM**
```bash
gcloud compute ssh scaled-vm-XXXXX --zone=asia-south1-b
sudo ss -tulnp | grep LISTEN
```

