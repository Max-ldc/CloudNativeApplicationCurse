#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Wait for the database to be ready
echo "Waiting for database to be ready..."
# We use `db execute` with a simple query to check for DB connectivity without reading any tables.
until npx prisma db execute --stdin "SELECT 1;" > /dev/null 2>&1; do
  >&2 echo "Database is unavailable - sleeping"
  sleep 1
done
>&2 echo "Database is up - continuing"

# Apply database migrations
echo "Applying database migrations..."
npx prisma migrate deploy

# Seed the database
echo "Seeding the database..."
npm run seed

# Start the application
echo "Starting the application..."
exec "$@"
