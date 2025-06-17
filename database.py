import sqlite3

def init_user_db():
    conn = sqlite3.connect("user_data.db")
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users (
        telegram_id INTEGER PRIMARY KEY,
        email TEXT,
        api_key TEXT
    )''')
    conn.commit()
    conn.close()

def save_user_data(telegram_id, email, api_key):
    conn = sqlite3.connect("user_data.db")
    c = conn.cursor()
    c.execute("INSERT OR REPLACE INTO users (telegram_id, email, api_key) VALUES (?, ?, ?)", (telegram_id, email, api_key))
    conn.commit()
    conn.close()

def get_user_by_id(telegram_id):
    conn = sqlite3.connect("user_data.db")
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE telegram_id = ?", (telegram_id,))
    result = c.fetchone()
    conn.close()
    return result