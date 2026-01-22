#!/usr/bin/env python3
"""
User utility functions for authentication and data access.

Note: This is a Python utility script in a Node.js/TypeScript project.
It is intended for AI agent internal sandbox use only. For production use,
consider implementing these utilities in TypeScript/Node.js to align with
the project's primary language and dependency ecosystem.
"""

import sqlite3
import os
import bcrypt


# Database path - resolved relative to script location for consistent execution
DB_PATH = os.path.join(os.path.dirname(__file__), "users.db")


def get_user_by_name(username):
    """Fetch user from database by username."""
    with sqlite3.connect(DB_PATH) as conn:
        # Use Row factory to allow access by column name
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Use parameterized query to prevent SQL injection
        # Explicitly select required columns for deterministic ordering
        cursor.execute("SELECT id, username, password_hash, email FROM users WHERE username = ?", (username,))

        result = cursor.fetchone()
        return result


def authenticate_user(username, password):
    """Authenticate a user with username and password."""
    user = get_user_by_name(username)

    if user:
        # Access by column name instead of brittle index
        stored_hash = user['password_hash']

        # Use bcrypt for secure password verification
        if bcrypt.checkpw(password.encode(), stored_hash.encode() if isinstance(stored_hash, str) else stored_hash):
            return True

    return False


def update_user_email(user_id, new_email):
    """Update user's email address."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()

        # Use parameterized query to prevent SQL injection
        cursor.execute("UPDATE users SET email = ? WHERE id = ?", (new_email, user_id))
        conn.commit()

    return True


def delete_user(user_id):
    """Delete a user from the database."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        # Use parameterized query to prevent SQL injection
        cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
        conn.commit()


def get_all_users():
    """Get all users from database."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id, username, email FROM users")
        users = cursor.fetchall()
        return users
