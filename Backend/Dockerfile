# --- Etapa 1: Construcción ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias e instalar
COPY package*.json ./
RUN npm install

# Copiar el resto del código fuente
COPY . .

# Construir el proyecto (asegúrate de que tu script de build incluya copyfiles)
RUN npm run build

# Copiar archivos .graphql manualmente para asegurar que estén en dist
RUN cp -r src/infrastructure/adapters/graphql/schemas/*.graphql dist/infrastructure/adapters/graphql/schemas/

# --- Etapa 2: Producción ---
FROM node:20-alpine

WORKDIR /app

# Instalar solo dependencias de producción
COPY package*.json ./
RUN npm install --omit=dev

# Copiar el código compilado desde la etapa builder
COPY --from=builder /app/dist ./dist

# Copiar la carpeta de scripts para poder ejecutar el seed en el contenedor
COPY --from=builder /app/scripts ./scripts

# Exponer el puerto
EXPOSE 4000

# Arrancar el servidor
CMD ["npm", "run", "start"]