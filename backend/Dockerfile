#Etapa 1: Construir el backend
FROM node:20-alpine 

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . . 

CMD ["npm","run", "start:dev"] #Esto sobreescribe en docker-compose si es necesario

