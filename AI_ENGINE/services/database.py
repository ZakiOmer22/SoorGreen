import sys
import traceback
import pyodbc
from config.config import config

class DatabaseConnection:
    def __init__(self):
        self.conn = None
        self.cursor = None

    def connect(self):
        """Connect to SQL Server using pyodbc"""
        try:
            server = config.DB_SERVER
            database = config.DB_NAME
            user = config.DB_USER
            password = config.DB_PASSWORD

            print(f"Connecting to database: {server}/{database}")
            print(f"User: {user}")

            # SQL Authentication
            conn_str = (
                f"DRIVER={{ODBC Driver 18 for SQL Server}};"
                f"SERVER={server};"
                f"DATABASE={database};"
                f"UID={user};PWD={password};"
                f"TrustServerCertificate=yes"
            )

            self.conn = pyodbc.connect(conn_str, timeout=10)
            self.cursor = self.conn.cursor()
            print("✅ Database connected successfully!")
            return True

        except Exception as e:
            print(f"❌ SQL login failed: {e}")
            print("Trying Windows authentication fallback...")

            try:
                conn_str = (
                    f"DRIVER={{ODBC Driver 18 for SQL Server}};"
                    f"SERVER={server};"
                    f"DATABASE={database};"
                    f"Trusted_Connection=yes;"
                    f"TrustServerCertificate=yes"
                )
                self.conn = pyodbc.connect(conn_str, timeout=10)
                self.cursor = self.conn.cursor()
                print("✅ Database connected using Windows authentication!")
                return True
            except Exception as e2:
                print(f"❌ Windows auth failed: {e2}")
                return False

    def execute_query(self, query, params=None, fetch=True):
        try:
            if not self.conn:
                if not self.connect():
                    return None

            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)

            if fetch and query.strip().upper().startswith("SELECT"):
                rows = self.cursor.fetchall()
                formatted = []
                columns = [column[0] for column in self.cursor.description]
                for row in rows:
                    formatted.append(dict(zip(columns, row)))
                return formatted
            else:
                self.conn.commit()
                return self.cursor.rowcount

        except Exception as e:
            print(f"Query error: {e}\nQuery: {query[:100]}...")
            return None

    def get_pending_pickups(self, municipality_id=None):
        query = """
        SELECT TOP 20
            p.PickupId,
            w.ReportId,
            w.Address,
            ISNULL(w.Lat, 0.0) as Lat,
            ISNULL(w.Lng, 0.0) as Lng,
            ISNULL(w.EstimatedKg, 0.0) as EstimatedKg,
            w.PhotoUrl,
            u.FullName as CitizenName,
            u.Phone as CitizenPhone,
            wt.Name as WasteType,
            m.Name as Municipality
        FROM PickupRequests p
        INNER JOIN WasteReports w ON p.ReportId = w.ReportId
        INNER JOIN Users u ON w.UserId = u.UserId
        INNER JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
        LEFT JOIN Municipalities m ON w.MunicipalityId = m.MunicipalityId
        WHERE p.Status IN ('Requested', 'Assigned')
        """
        if municipality_id:
            query += f" AND w.MunicipalityId = '{municipality_id}'"
        query += " ORDER BY w.CreatedAt DESC"
        return self.execute_query(query)

    def get_waste_types(self):
        query = """
        SELECT WasteTypeId, Name, CreditPerKg, ColorCode
        FROM WasteTypes
        ORDER BY Name
        """
        return self.execute_query(query)

    def test_connection(self):
        try:
            result = self.execute_query("SELECT TOP 1 UserId, FullName FROM Users")
            if result:
                print(f"✅ Database test successful. Sample user: {result[0]}")
                return True
            return False
        except Exception as e:
            print(f"❌ Database test failed: {e}")
            return False

    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("Database connection closed")


# Global instance
db = DatabaseConnection()
