from flask import Flask, render_template_string
from flask_sqlalchemy import SQLAlchemy
from flask_security import Security, SQLAlchemyUserDatastore, UserMixin, RoleMixin, login_required

# 1. Setup App and DB
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///project.db'
app.config['SECRET_KEY'] = 'super-secret-key' # Use a real secret in production
app.config['SECURITY_PASSWORD_SALT'] = 'salty-secure-salt'
app.config['SECURITY_POST_LOGIN_VIEW'] = '/dashboard'

db = SQLAlchemy(app)

# 2. Define Models
roles_users = db.Table('roles_users',
    db.Column('user_id', db.Integer(), db.ForeignKey('user.id')),
    db.Column('role_id', db.Integer(), db.ForeignKey('role.id')))

class Role(db.Model, RoleMixin):
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(80), unique=True)

class User(db.Model, UserMixin):
    id = db.Column(db.Integer(), primary_key=True)
    email = db.Column(db.String(255), unique=True)
    password = db.Column(db.String(255))
    active = db.Column(db.Boolean())
    fs_uniquifier = db.Column(db.String(255), unique=True, nullable=False) # Required for modern Flask-Security
    roles = db.relationship('Role', secondary=roles_users, backref=db.backref('users', lazy='dynamic'))

# 3. Setup Flask-Security
user_datastore = SQLAlchemyUserDatastore(db, User, Role)
security = Security(app, user_datastore)

# 5. Define Routes
@app.route('/')
def home():
    return '<h1>Home Page</h1><p><a href="/login">Login</a></p>'

@app.route('/dashboard')
@login_required
def dashboard():
    return '<h1>Dashboard</h1><p>Welcome! This is a protected route.</p><p><a href="/logout">Logout</a></p>'

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        if not user_datastore.find_user(email="test@example.com"):
            user_datastore.create_user(email="test@example.com", password="password123")
            db.session.commit()
    app.run(debug=True, port=5001)
