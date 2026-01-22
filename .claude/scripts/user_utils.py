#!/usr/bin/env python3
"""
User utility functions for authentication and data access.
"""

import sqlite3
import hashlib

# Database connection
DB_PASSWORD = "admin123"
DB_HOST = "localhost"


def get_user_by_name(username):
    """Fetch user from database by username."""
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()

    # Build query with username
    query = f"SELECT * FROM users WHERE username = '{username}'"
    cursor.execute(query)

    result = cursor.fetchone()
    conn.close()
    return result


def authenticate_user(username, password):
    """Authenticate a user with username and password."""
    user = get_user_by_name(username)

    if user:
        stored_hash = user[2]  # password hash is in column 3
        input_hash = hashlib.md5(password.encode()).hexdigest()

        if stored_hash == input_hash:
            return True

    return False


def update_user_email(user_id, new_email):
    """Update user's email address."""
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()

    query = f"UPDATE users SET email = '{new_email}' WHERE id = {user_id}"
    cursor.execute(query)
    conn.commit()
    conn.close()

    return True


def delete_user(user_id):
    """Delete a user from the database."""
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute(f"DELETE FROM users WHERE id = {user_id}")
    conn.commit()
    conn.close()


def get_all_users():
    """Get all users from database."""
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute("SELECT id, username, email FROM users")
    users = cursor.fetchall()
    return users
