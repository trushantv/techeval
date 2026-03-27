import os
from flask import Flask, request, redirect, render_template
from pymongo import MongoClient
from bson.objectid import ObjectId

app = Flask(__name__)

MONGO_URI = os.environ.get("MONGO_URI", "mongodb://localhost:27017/")
client = MongoClient(MONGO_URI)
db = client["tododb"]
todos = db["todos"]


@app.route("/")
def index():
    all_todos = list(todos.find())
    return render_template("index.html", todos=all_todos)


@app.route("/add", methods=["POST"])
def add():
    title = request.form.get("title", "").strip()
    if title:
        todos.insert_one({"title": title, "completed": False})
    return redirect("/")


@app.route("/complete/<id>")
def complete(id):
    todos.update_one({"_id": ObjectId(id)}, {"$set": {"completed": True}})
    return redirect("/")


@app.route("/delete/<id>")
def delete(id):
    todos.delete_one({"_id": ObjectId(id)})
    return redirect("/")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
