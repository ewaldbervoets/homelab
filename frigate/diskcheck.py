from flask import Flask
import shutil

app = Flask(__name__)

@app.route("/")
def disk_usage():
    total, used, free = shutil.disk_usage("/media/frigate")
    percent_used = used / total * 100
    return f"{percent_used:.2f}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8085)
