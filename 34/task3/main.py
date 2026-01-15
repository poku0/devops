# app.py

from flask import Flask, render_template, request

app = Flask(__name__)

# Set a secret key for encrypting session data
app.secret_key = 'CA-devops-UA6'

# dictionary to store user and email
users = {
    'povilas': 'povilas@mail.com',
    'admin': 'admin@ua6.com'
}

@app.route('/')
def view_form():
    return render_template('login.html')

@app.route('/handle_get', methods=['GET'])
def handle_get():
    if request.method == 'GET':
        username = request.args['username']
        email = request.args['email']
        print(username, email)
        if username in users and users[username] == email:
            return f'<h1>Welcome {username}!!!</h1><p>Your email is: {email}</p>'
        else:
            return '<h1>invalid credentials!</h1>'
    else:
        return render_template('login.html')

@app.route('/handle_post', methods=['POST'])
def handle_post():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        print(username, email)
        if username in users and users[username] == email:
            return f'<h1>Welcome {username}!!!</h1><p>Your email is: {email}</p>'
        else:
            return '<h1>invalid credentials!</h1>'
    else:
        return render_template('login.html')

if __name__ == '__main__':
    app.run()