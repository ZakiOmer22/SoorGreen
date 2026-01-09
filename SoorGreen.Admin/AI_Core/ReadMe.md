# SoorGreen AI Engine

AI/ML services for the SoorGreen Waste Management System.

## Features
- Waste image classification using CNN/YOLO
- Route optimization for collection vehicles
- Waste volume forecasting
- Database integration
- REST API endpoints

## Setup

### 1. Prerequisites
- Anaconda/Miniconda installed
- Python 3.9
- SQL Server with SoorGreenDB

### 2. Installation

```bash
# Clone repository
cd AI_ENGINE

# Create and activate conda environment
conda create -n soorgreen-ai python=3.9 -y
conda activate soorgreen-ai

# Install packages
conda env update -f environment.yml
pip install -r requirements.txt








# 2. Activate environment
 conda activate soorgreen-ai

# 3. Install additional packages
pip install -r requirements.txt

# 4. Train initial models
python train_classifier.py --data-path ./data/waste_images --epochs 50
python train_forecaster.py --data-path ./data/historical_waste.csv

# 5. Start API server
python api_server.py &

# 6. Start background job processor
python job_processor.py &

# 7. Start Jupyter for analytics
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser &