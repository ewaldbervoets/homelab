from flask import Flask, jsonify
import shutil

app = Flask(__name__)

@app.route("/")
def disk_usage():
    total, used, free = shutil.disk_usage("/media/frigate")
    percent_used = used / total * 100
    status = "ALERT" if percent_used >= 90 else "OK"
    return jsonify({
        "status": status,
        "percent_used": f"{percent_used:.2f}"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8085)
