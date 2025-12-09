from flask import Flask
import mysql.connector

app = Flask(__name__)

@app.get("/hello")
def hello_world():
    return {"message": "Hello World"}
