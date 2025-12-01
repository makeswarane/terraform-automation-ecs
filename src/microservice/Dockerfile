FROM node:18-alpine
WORKDIR /app
COPY package.json .
COPY server.js .
RUN npm install --production || true
EXPOSE 3000
CMD ["node","server.js"]
