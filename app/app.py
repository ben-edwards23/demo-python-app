from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html", message="Hello there! My name is Ben and this is a demo application. Something cool you should know is that this app is running in a container on Azure Web Apps!")

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
