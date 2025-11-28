from flask import Flask
import mysql.connector

app = Flask(__name__)

@app.get("/db-test")
def db_test():
    conn = mysql.connector.connect(
        host="db",
        user="root",
        password="root",
        database="mydb"
    )
    cursor = conn.cursor()
    cursor.execute("SELECT NOW();")
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    return {"db_time": str(result[0])}
