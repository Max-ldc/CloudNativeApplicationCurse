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

# Seed the database only if it's empty
echo "Checking if database needs seeding..."
# Check if users table has any records using Prisma Client directly to avoid parsing issues
USER_COUNT=$(node -e 'const { PrismaClient } = require("@prisma/client"); const prisma = new PrismaClient(); prisma.user.count().then(console.log).catch(e => { console.error(e); console.log(0); }).finally(() => prisma.$disconnect())')

if [ -z "$USER_COUNT" ] || [ "$USER_COUNT" = "0" ]; then
  echo "Database is empty (users: $USER_COUNT). Seeding..."
  npm run seed
else
  echo "Database already has data (found $USER_COUNT users). Skipping seed."
fi

# Start the application
echo "Starting the application..."
exec "$@"
