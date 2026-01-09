@echo off
echo Starting SoorGreen AI Engine Services...

REM Activate conda environment
call conda activate soorgreen-ai

REM Start FastAPI server
echo Starting FastAPI server on port 8000...
start "SoorGreen AI API" python api/main.py

REM Start Flask server (alternative)
REM echo Starting Flask server on port 5000...
REM start "SoorGreen Flask API" python api/flask_app.py

REM Start Jupyter Notebook for analytics
echo Starting Jupyter Notebook on port 8888...
start "SoorGreen Jupyter" jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser notebooks/

echo.
echo Services started:
echo - FastAPI: http://localhost:8000
echo - Jupyter: http://localhost:8888
echo.
echo Press any key to stop all services...
pause