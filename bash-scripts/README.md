# PostgreSQL Management Scripts

A collection of bash scripts for managing PostgreSQL databases and users.

## Prerequisites

Ensure the `.env` file exists in the project root with the following variables:

```bash
POSTGRES_USER=your_admin_user
POSTGRES_PASSWORD=your_admin_password
POSTGRES_DB=your_default_db
PGHOST=localhost
```

## Available Scripts

### User Management

| Script                                     | Description                               |
| ------------------------------------------ | ----------------------------------------- |
| `create-user.sh [username]`                | Creates a new user with a random password |
| `delete-user.sh <username>`                | Deletes a user                            |
| `list-users.sh`                            | Lists all users/roles                     |
| `change-password.sh <username> [password]` | Changes a user's password                 |

### Database Management

| Script                                 | Description            |
| -------------------------------------- | ---------------------- |
| `create-database.sh [db_name] [owner]` | Creates a new database |
| `delete-database.sh <db_name>`         | Deletes a database     |
| `list-databases.sh`                    | Lists all databases    |

### Combined Operations

| Script                     | Description                                         |
| -------------------------- | --------------------------------------------------- |
| `create-db-user.sh [name]` | Creates both a database and user with the same name |
| `delete-db-user.sh <name>` | Deletes both a database and user with the same name |

### Privileges

| Script                                   | Description                                        |
| ---------------------------------------- | -------------------------------------------------- |
| `grant-privileges.sh <db> <user> [type]` | Grants privileges (`all`, `readonly`, `readwrite`) |

### Utilities

| Script                      | Description                       |
| --------------------------- | --------------------------------- |
| `psql-connect.sh [db_name]` | Opens an interactive psql session |

## Examples

```bash
# Create a new database and user named "myapp"
./create-db-user.sh myapp

# Create just a user
./create-user.sh api_user

# Create a database owned by an existing user
./create-database.sh api_db api_user

# Grant read-only access to a user
./grant-privileges.sh myapp readonly_user readonly

# Connect to a database interactively
./psql-connect.sh myapp

# List all databases
./list-databases.sh
```
