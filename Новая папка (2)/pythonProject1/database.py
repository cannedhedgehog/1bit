# database.py
import sqlite3

class Database:
    def __init__(self, db_name):
        self.connection = sqlite3.connect(db_name)
        self.cursor = self.connection.cursor()

    def execute_query(self, query, parameters=()):
        self.cursor.execute(query, parameters)
        self.connection.commit()

    def fetch_all(self, query, parameters=()):
        self.cursor.execute(query, parameters)
        return self.cursor.fetchall()

    def close(self):
        self.connection.close()
