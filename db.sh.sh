#!/bin/bash

# Parse the connection string
DB_USER="woostdb"
DB_PASSWORD="Eut1ssg)nywc!fr3:!z[FGFb"
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="woostdb"

# Login to PostgreSQL as the superuser (assumes you have access)
sudo -u postgres psql <<EOF

-- Create the database
CREATE DATABASE ${DB_NAME};

-- Create the user with the specified password
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';

-- Grant all privileges to the user on the database
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};

-- Alter default privileges so that the user gets access to all future objects created in the database
ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};

EOF

echo "Database ${DB_NAME} and user ${DB_USER} have been created with full access."
]
