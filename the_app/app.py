from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("home.html")

@app.route("/andreas")
def andreas():
    return "Hello, Andreas"

@app.route('/hello/<name>') 
def hello_name(name): 
    return 'Hello %s!' % name

@app.route("/about")
def about():
    return render_template("about.html")

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
