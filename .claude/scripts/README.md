# Claude Scripts

This directory contains utility scripts for Claude AI agent operations.

## User Utilities

The `user_utils.ts` module provides functions for user authentication and data access.

### Migration from Python to TypeScript

This utility was migrated from Python to TypeScript to align with the project's Node.js/TypeScript ecosystem and ensure all dependencies are managed through npm.

### Setup

To use these utilities, install the required dependencies:

```bash
cd .claude/scripts
npm install
```

### Usage

The utilities can be imported as a module or run directly from the command line:

#### As a Module

```typescript
import { getAllUsers, authenticateUser, updateUserEmail, deleteUser } from './user_utils';

// Get all users (safe - excludes password hashes)
const users = await getAllUsers();

// Authenticate a user
const isAuthenticated = await authenticateUser('username', 'password');

// Update user email
await updateUserEmail(userId, 'new@email.com');

// Delete a user
await deleteUser(userId);
```

#### Command Line

```bash
# List all users
npm run list

# Authenticate a user
ts-node user_utils.ts auth username password

# Update user email
ts-node user_utils.ts update-email user_id new@email.com

# Delete a user
ts-node user_utils.ts delete user_id
```

### Security Features

- **Parameterized queries**: All database queries use parameterized statements to prevent SQL injection
- **Password hashing**: Uses bcrypt for secure password verification
- **Limited data exposure**: The `getAllUsers()` function only returns safe fields (id, username, email) and explicitly excludes password hashes
- **Database files excluded**: The `.gitignore` is configured to exclude `*.db` files to prevent accidentally committing sensitive data

### Database

The utilities use SQLite with a local `users.db` file. This file is automatically excluded from version control via `.gitignore`.
