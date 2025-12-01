# microservice/Dockerfile
FROM node:20-alpine

# Create app directory
WORKDIR /app

# Copy only needed files
COPY package.json .
RUN npm install --only=production

# Copy source code
COPY app.js .

# Expose port
EXPOSE 3000

# Run the app
CMD ["npm", "start"]