# 🚀 Guía de Inicio Rápido - Evaluador de Instrumentos

Este repositorio es un monorepo que contiene el backend y el frontend para el sistema de evaluación del instrumento (Módulo 3).

## 📋 Estructura del Proyecto

* **[Backend](./Backend)**: API en Node.js, Express, TypeScript y GraphQL (Apollo Server) con persistencia en MongoDB.
* **[Frontend](./Frontend)**: Aplicación móvil/web desarrollada con Flutter siguiendo los principios de **Clean Architecture** (Feature-First).
* **[scripts](./scripts)**: Scripts de automatización y configuración de entorno (Docker Compose para MongoDB).

---

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener instalado en tu sistema:

1. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (Necesario para levantar la base de datos local con soporte de transacciones).
2. **[Node.js](https://nodejs.org/)** (Versión 18 o superior recomendada).
3. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Canal `stable`).
4. **PowerShell** (Si estás en Windows para ejecutar los scripts de automatización).

---

## 🚦 Pasos para Iniciar la Aplicación

Sigue este orden estricto para configurar y correr el proyecto:

### Paso 1: Configurar e Iniciar la Base de Datos (MongoDB con Replica Set)

El backend requiere un **Replica Set** de MongoDB para soportar transacciones. Hemos automatizado esto usando Docker Compose.

* **En Windows (Recomendado):**
  1. Asegúrate de tener **Docker Desktop** abierto y ejecutándose.
  2. Abre una terminal de PowerShell en la raíz del proyecto.
  3. Ejecuta el script de automatización:
     ```powershell
     .\scripts\run docker.ps1
     ```
  4. El script levantará el contenedor de Docker e inicializará el replica set automáticamente. Al finalizar, imprimirá el estado listo.

* **En macOS / Linux / Manual:**
  1. Ve a la carpeta `scripts/`:
     ```bash
     cd scripts
     ```
  2. Levanta el contenedor en segundo plano:
     ```bash
     docker compose up -d
     ```
  3. Ejecuta el comando en el contenedor para inicializar el replica set `rs0`:
     ```bash
     docker exec -it mongo-local-tx mongosh --eval "rs.initiate({_id:'rs0',members:[{_id:0,host:'localhost:27017'}]})"
     ```

---

### Paso 2: Configurar e Iniciar el Backend

1. Abre una terminal nueva y dirígete al directorio del backend:
   ```bash
   cd Backend
   ```
2. Crea el archivo de variables de entorno `.env` copiando el ejemplo provisto:
   ```bash
   cp .env.example .env
   ```
   *(En Windows puedes usar `copy .env.example .env` o hacerlo manualmente desde tu IDE).*
3. Abre el archivo `.env` y asegúrate de que `MONGODB_URI` apunte a la instancia con el replica set configurado:
   ```env
   MONGODB_URI=mongodb://localhost:27017/7mo_des_modulo3?replicaSet=rs0
   ```
4. Instala las dependencias de Node.js:
   ```bash
   npm install
   ```
5. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```
   * El servidor estará disponible en: `http://localhost:4000`
   * El explorador de GraphQL (Apollo Sandbox) estará en: `http://localhost:4000/graphql`
   * Puedes comprobar la salud de la API en: `http://localhost:4000/health`

---

### Paso 3: Configurar e Iniciar el Frontend (Flutter)

1. Abre una terminal nueva y dirígete al directorio del frontend:
   ```bash
   cd Frontend
   ```
2. Descarga todas las dependencias del proyecto de Flutter:
   ```bash
   flutter pub get
   ```
3. Ejecuta un diagnóstico rápido (opcional) para asegurarte de tener emuladores o navegadores listos:
   ```bash
   flutter doctor
   ```
4. Corre la aplicación:
   * **En modo de desarrollo básico (usando los mocks locales):**
     ```bash
     flutter run
     ```
     *(Elige tu emulador Android/iOS, navegador Web, o aplicación nativa de escritorio).*
   
   > ⚠️ **Nota de Integración:**
   > Actualmente, el frontend utiliza datos simulados (mocks) en su origen de datos `AuthRemoteDataSourceImpl` para pruebas rápidas de la UI. Cuando desees conectar el frontend directamente al backend local, asegúrate de actualizar la URL base en:
   > `Frontend/lib/core/network/api_client.dart` apuntando a `http://localhost:4000/api` o la IP de tu máquina en caso de usar emuladores móviles (ej. `http://10.0.2.2:4000/api` para Android Emulator).
