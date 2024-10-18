# Import necessary libraries and modules
from flask import Flask, request, jsonify, render_template, redirect, url_for, flash, session
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_sqlalchemy import SQLAlchemy
from celery import Celery
from redis import Redis
from openai import OpenAI
import anthropic
import os
import logging
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from cryptography.fernet import Fernet
import re

# Flask app setup
app = Flask(__name__)
app.config.update(
    SECRET_KEY=os.environ.get('SECRET_KEY', 'your_default_secret_key'),
    SQLALCHEMY_DATABASE_URI='postgresql://woostdb:Eut1ssg)nywc!fr3:!z[FGFb@localhost:5432/woostdb',
    SQLALCHEMY_TRACK_MODIFICATIONS=False,
    CELERY_BROKER_URL=os.environ.get('CELERY_BROKER_URL', 'redis://localhost:6379'),
    CELERY_RESULT_BACKEND=os.environ.get('CELERY_RESULT_BACKEND', 'redis://localhost:6379')
)

# Celery setup for asynchronous task processing
celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])
celery.conf.update(app.config)

# Database setup using SQLAlchemy
db = SQLAlchemy(app)

# Redis client setup for caching and message queuing
redis_client = Redis(host='localhost', port=6379, db=0)

# User management setup using Flask-Login
login_manager = LoginManager(app)
login_manager.login_view = 'login'

ENCRYPTION_KEY = 'eJBtXG1JWXXjUVh9EWbYt_l2B5fspf7Rf8enapzGakg='

# Logging setup
os.makedirs('logs', exist_ok=True)
logging.basicConfig(filename='logs/app.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s: %(message)s')

# User model definition
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)
    openai_api_key_encrypted = db.Column(db.Text, nullable=True)
    anthropic_api_key_encrypted = db.Column(db.Text, nullable=True)

    def set_api_keys(self, openai_key, anthropic_key):
        cipher_suite = Fernet(ENCRYPTION_KEY)
        if openai_key:
            self.openai_api_key_encrypted = cipher_suite.encrypt(openai_key.encode()).decode()
        if anthropic_key:
            self.anthropic_api_key_encrypted = cipher_suite.encrypt(anthropic_key.encode()).decode()

    def get_api_key(self, key_type):
        cipher_suite = Fernet(ENCRYPTION_KEY)
        encrypted_key = getattr(self, f"{key_type}_key_encrypted", None)
        if encrypted_key:
            return cipher_suite.decrypt(encrypted_key.encode()).decode()
        return None

# ChatSession model definition
class ChatSession(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    session_name = db.Column(db.String(50), nullable=False)
    agent_type = db.Column(db.String(50))
    model_used = db.Column(db.String(255))
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    lastupdated = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    chats = db.relationship('Chat', backref='session', lazy=True)

# Chat model definition
class Chat(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    session_id = db.Column(db.Integer, db.ForeignKey('chat_session.id'), nullable=False)
    prompt = db.Column(db.Text, nullable=False)
    response = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

# User loader for Flask-Login
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Routes
# Index route
@app.route('/')
def index():
    return redirect(url_for('dashboard' if current_user.is_authenticated else 'login'))

# User registration route
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        openai_api_key = request.form.get('openai_api_key')
        anthropic_api_key = request.form.get('anthropic_api_key')

        if User.query.filter_by(username=username).first():
            flash('Username already exists. Please choose a different username.', 'warning')
            return redirect(url_for('register'))
        
        user = User(username=username, password=generate_password_hash(password))
        user.set_api_keys(openai_api_key, anthropic_api_key)
        db.session.add(user)
        db.session.commit()
        logging.info(f"User registered: {username}")
        flash('Account created successfully. Please log in.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

# User settings route
@app.route('/settings', methods=['GET', 'POST'])
@login_required
def settings():
    if request.method == 'POST':
        current_user.set_api_keys(request.form.get('openai_api_key'), request.form.get('anthropic_api_key'))
        db.session.commit()
        flash('API keys updated successfully.', 'success')
        return redirect(url_for('dashboard'))
    return render_template('settings.html')

# User login route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        user = User.query.filter_by(username=request.form.get('username')).first()
        if user and check_password_hash(user.password, request.form.get('password')):
            login_user(user)
            logging.info(f"User logged in: {user.username}")
            flash('Login successful', 'success')
            return redirect(url_for('dashboard'))
        logging.warning(f"Failed login attempt for user: {request.form.get('username')}")
        flash('Login unsuccessful. Check username and password', 'danger')
    return render_template('login.html')

# User logout route
@app.route('/logout')
@login_required
def logout():
    logging.info(f"User logged out: {current_user.username}")
    logout_user()
    return redirect(url_for('login'))

# Dashboard route
@app.route('/dashboard')
@login_required
def dashboard():
    sessions = ChatSession.query.filter_by(user_id=current_user.id).order_by(ChatSession.timestamp.desc()).all()
    return render_template('dashboard_sessions.html', current_user=current_user, sessions=sessions)

@app.route('/check_response/<int:chat_id>')
def check_response(chat_id):
    chat = Chat.query.get(chat_id)
    if chat and chat.response:
        return jsonify({
            'response': chat.response,
        })
    return jsonify({'response': None })


@app.route('/new_chat_session', methods=['POST'])
@login_required
def new_chat_session():
    try:
# Route to create a new chat session
        new_session = ChatSession(
            session_name=f"Session {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            user_id=current_user.id,
            agent_type=request.form.get('agent_type'),
            model_used=request.form.get('model_used')
        )
        db.session.add(new_session)
        db.session.commit()

        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({
                'session_id': new_session.id,
                'session_name': new_session.session_name,
                'agent_type': new_session.agent_type,
                'model_used': new_session.model_used
            }), 200
        return redirect(url_for('dashboard'))
    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error creating new session: {e}")
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({'error': 'Failed to create a new session.'}), 500
        return redirect(url_for('dashboard'))

# Function to clean JSON strings
def clean_json_string(json_string):
    return re.sub(r'```[\w+\-]*\s*\n?(.*?)\n?```', r'\1', json_string, flags=re.DOTALL).strip()

@app.route('/summon_agent', methods=['POST'])
@login_required
# Route to summon an AI agent
def summon_agent():
    logging.info(f"Form data received: {request.form}")
    
    agent_type = request.form.get('agent_type')
    prompt = request.form.get('prompt')
    model_used = request.form.get('model_used')
    session_id = request.form.get('session_id')
    role_type = request.form.get('role_type')

    if not all([agent_type, prompt, session_id]) or (agent_type == 'openai' and not model_used):
        logging.error("Missing required fields: agent_type, prompt, or session_id.")
        return jsonify({'error': 'Please provide agent type, session, model, and prompt.'}), 400

    chat_session = ChatSession.query.get(session_id)
    if not chat_session:
        logging.error(f"Chat session with ID {session_id} not found.")
        return jsonify({'error': 'Invalid session ID.'}), 400

    chat_session.agent_type = agent_type
    chat_session.model_used = model_used

    new_chat = Chat(user_id=current_user.id, session_id=session_id, prompt=prompt)
    db.session.add(new_chat)
    db.session.commit()

    try:
        api_key = current_user.get_api_key(f"{agent_type}_api")
        if not api_key:
            return jsonify({'error': f'{agent_type.capitalize()} API key is not configured for this user.'}), 400

        if agent_type == 'openai':
            response = call_openai_service(api_key, model_used, prompt, role_type)
        elif agent_type == 'anthropic':
            response = call_anthropic_service(api_key, prompt, model_used, role_type)
        else:
            return jsonify({'error': 'Unsupported agent type provided.'}), 400
          
        new_chat.response = clean_json_string(response)
        db.session.commit()

        logging.info(f"New chat created in session {session_id} using model {model_used} and agent {agent_type}")
        
        return jsonify({
            'chat_id': new_chat.id,
            'prompt': new_chat.prompt,
            'response': new_chat.response,
            'timestamp': new_chat.timestamp.strftime('%Y-%m-%d %I:%M %p')
        }), 200
    except Exception as e:
        logging.error(f"Error during API call: {str(e)}")
        return jsonify({'error': 'An error occurred while processing your request.'}), 500

# Function to call OpenAI service
def call_openai_service(api_key, model, prompt, role_type):
    client = OpenAI(api_key=api_key)
    messages = [{"role": "user", "content": prompt}]
    if role_type and model not in ["o1-preview", "o1-mini"]:
        messages.insert(0, {"role": "system", "content": role_type})

    completion = client.chat.completions.create(model=model, messages=messages)
    return completion.choices[0].message.content

# Function to call Anthropic service
def call_anthropic_service(api_key, prompt, model, role):
    try:
        client = anthropic.Anthropic(api_key=api_key)
        response = client.messages.create(
            model=model,
            max_tokens=1000,
            system=role,
            messages=[{"role": "user", "content": prompt}]
        )
        ai_response = response.content[0].text
        logging.info(f"Anthropic AI response: {ai_response}")
        return ai_response
    except anthropic.AnthropicError as ae:
        logging.error(f"Anthropic API error: {ae}")
        return f"Anthropic API error: {ae}"
    except Exception as e:
        logging.error(f"Unexpected error in Anthropic service: {e}")
        return f"An unexpected error occurred: {e}"

# Main execution
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=50005)
