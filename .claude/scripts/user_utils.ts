#!/usr/bin/env ts-node
/**
 * User utility functions for authentication and data access.
 *
 * TypeScript implementation for consistency with Node.js/TypeScript ecosystem.
 * Uses standard npm packages: sqlite3 and bcrypt.
 */

import * as sqlite3 from 'sqlite3';
import * as bcrypt from 'bcrypt';
import * as path from 'path';

// Database path - resolved relative to script location for consistent execution
const DB_PATH = path.join(__dirname, 'users.db');

interface User {
    id: number;
    username: string;
    password_hash: string;
    email: string;
}

interface SafeUser {
    id: number;
    username: string;
    email: string;
}

/**
 * Fetch user from database by username.
 */
export async function getUserByName(username: string): Promise<User | null> {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database(DB_PATH);

        // Use parameterized query to prevent SQL injection
        // Explicitly select required columns for deterministic ordering
        db.get(
            "SELECT id, username, password_hash, email FROM users WHERE username = ?",
            [username],
            (err, row: User | undefined) => {
                db.close();
                if (err) {
                    reject(err);
                } else {
                    resolve(row || null);
                }
            }
        );
    });
}

/**
 * Authenticate a user with username and password.
 */
export async function authenticateUser(username: string, password: string): Promise<boolean> {
    try {
        const user = await getUserByName(username);

        if (user) {
            // Use bcrypt for secure password verification
            return await bcrypt.compare(password, user.password_hash);
        }

        return false;
    } catch (error) {
        console.error('Authentication error:', error);
        return false;
    }
}

/**
 * Update user's email address.
 */
export async function updateUserEmail(userId: number, newEmail: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database(DB_PATH);

        // Use parameterized query to prevent SQL injection
        db.run(
            "UPDATE users SET email = ? WHERE id = ?",
            [newEmail, userId],
            (err) => {
                db.close();
                if (err) {
                    reject(err);
                } else {
                    resolve(true);
                }
            }
        );
    });
}

/**
 * Delete a user from the database.
 */
export async function deleteUser(userId: number): Promise<void> {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database(DB_PATH);

        // Use parameterized query to prevent SQL injection
        db.run(
            "DELETE FROM users WHERE id = ?",
            [userId],
            (err) => {
                db.close();
                if (err) {
                    reject(err);
                } else {
                    resolve();
                }
            }
        );
    });
}

/**
 * Get all users from database.
 * SECURITY: Only returns safe fields (id, username, email) - password hashes are excluded.
 */
export async function getAllUsers(): Promise<SafeUser[]> {
    return new Promise((resolve, reject) => {
        const db = new sqlite3.Database(DB_PATH);

        // Security fix: Select only safe fields, excluding password_hash
        db.all(
            "SELECT id, username, email FROM users",
            [],
            (err, rows: SafeUser[]) => {
                db.close();
                if (err) {
                    reject(err);
                } else {
                    resolve(rows || []);
                }
            }
        );
    });
}

// CLI interface for direct script execution
if (require.main === module) {
    const command = process.argv[2];
    const args = process.argv.slice(3);

    (async () => {
        try {
            switch (command) {
                case 'list':
                    const users = await getAllUsers();
                    console.log('Users:', users);
                    break;
                case 'auth':
                    if (args.length < 2) {
                        console.error('Usage: ts-node user_utils.ts auth <username> <password>');
                        process.exit(1);
                    }
                    const isAuthenticated = await authenticateUser(args[0], args[1]);
                    console.log('Authenticated:', isAuthenticated);
                    break;
                case 'update-email':
                    if (args.length < 2) {
                        console.error('Usage: ts-node user_utils.ts update-email <user_id> <new_email>');
                        process.exit(1);
                    }
                    await updateUserEmail(parseInt(args[0]), args[1]);
                    console.log('Email updated successfully');
                    break;
                case 'delete':
                    if (args.length < 1) {
                        console.error('Usage: ts-node user_utils.ts delete <user_id>');
                        process.exit(1);
                    }
                    await deleteUser(parseInt(args[0]));
                    console.log('User deleted successfully');
                    break;
                default:
                    console.error('Unknown command:', command);
                    console.error('Available commands: list, auth, update-email, delete');
                    process.exit(1);
            }
        } catch (error) {
            console.error('Error:', error);
            process.exit(1);
        }
    })();
}
