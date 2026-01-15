from flask import Flask, render_template
app = Flask(__name__)

@app.route('/hello/<name>')
def hello(name):
    names = {'povilas', 'jonas', 'petras'}
    return render_template('hello.html', name=name, names=names)

@app.route('/bye/<name>')
def bye(name):
    names = {'povilas', 'jonas', 'petras'}
    return render_template('bye.html', name=name, names=names)
