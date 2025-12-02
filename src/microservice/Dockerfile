# microservice/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./ 
RUN npm install --production || npm install --production --legacy-peer-deps

# Copy source
COPY server.js .

ENV PORT=3000
EXPOSE 3000

CMD ["npm", "start"]
