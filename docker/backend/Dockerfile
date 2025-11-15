FROM node:latest
COPY backend/* .
RUN apt-get update 
RUN apt-get install -y default-mysql-client
RUN rm -rf /var/lib/apt/lists/*
RUN npm install cors mysql2 express

CMD ["node","index.js"]
