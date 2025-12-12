# Use an official Node.js runtime as a parent image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install openssl and curl
RUN apt-get update -y && apt-get install -y openssl curl

# Install any needed packages
RUN npm install

# Copy the rest of the application's source code from the host to the image's filesystem
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Copy entrypoint script and fix line endings
COPY entrypoint.sh .
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl -f http://localhost:3000/health || exit 1

# Run the entrypoint script with bash explicitly
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]

# Run the command to start the server
CMD [ "npm", "start" ]
