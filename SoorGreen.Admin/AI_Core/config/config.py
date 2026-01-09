# config/config.py
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    # Database Configuration - Using Windows Authentication
    DB_SERVER = os.getenv('DB_SERVER', r'ZAKI\SQLEXPRESS')  # raw string for backslash
    DB_NAME = os.getenv('DB_NAME', 'SoorGreenDB')
    DB_USER = os.getenv('DB_USER', '')  # Empty for Windows Authentication
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')  # Empty for Windows Authentication
    DB_PORT = int(os.getenv('DB_PORT', 1433))
    
    # AI API Configuration
    AI_API_HOST = os.getenv('AI_API_HOST', '0.0.0.0')
    AI_API_PORT = int(os.getenv('AI_API_PORT', 5000))
    AI_DEBUG = os.getenv('AI_DEBUG', 'True').lower() == 'true'
    
    # File Upload Configuration
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)

    ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "bmp"}
    
    @property
    def USE_WINDOWS_AUTH(self):
        """Check if we should use Windows Authentication"""
        return not self.DB_USER or self.DB_USER.strip() == ''
    
    @property
    def DB_CONNECTION_STRING(self):
        """Connection string for pymssql"""
        if self.USE_WINDOWS_AUTH:
            # Windows Authentication
            return f"server={self.DB_SERVER};database={self.DB_NAME};trusted_connection=true"
        else:
            # SQL Authentication
            return f"server={self.DB_SERVER};database={self.DB_NAME};user={self.DB_USER};password={self.DB_PASSWORD}"

# Create global config instance
config = Config()