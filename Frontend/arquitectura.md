# Arquitectura del Frontend

Este documento define la arquitectura y la estructura de carpetas de la aplicación Flutter en el frontend. **Cualquier Agente de IA que trabaje en este repositorio DEBE seguir estrictamente estas directrices.**

## 🏛️ Visión General de la Arquitectura

El proyecto está construido bajo los principios de **Clean Architecture** organizados por características (**Feature-First**). La aplicación cuenta con dos roles principales (Encuestado Regular y Administrador) cuyo flujo se bifurca desde la pantalla de inicio mediante la validación de la cédula.

### Reglas de Oro de Dependencias (Estrictas)
1. **Domain Layer:** Contiene código Dart puro. **PROHIBIDO** importar paquetes de Flutter, `material.dart`, librerías de terceros (como `dio`) o clases de la capa de Datos.
2. **Data Layer:** Depende exclusivamente de la capa de Dominio para implementar sus contratos/repositorios.
3. **Presentation Layer:** Depende de la capa de Dominio a través de casos de uso (Use Cases) y gestiona el estado (BLoC/Riverpod). No habla directamente con los Data Sources.

---

## 📂 Estructura de Carpetas y Archivos

```text
lib/
│
├── core/                               # Recursos globales, utilidades y configuración estática
│   ├── constants/                      # Colores, strings fijos, dimensiones
│   ├── errors/                         # Manejo de excepciones y fallos (Failures)
│   ├── network/                        # Cliente HTTP (Dio) e interceptores
│   │   └── api_client.dart
│   ├── router/                         # Configuración de GoRouter y Guards de seguridad
│   │   └── app_router.dart
│   └── theme/                          # Estilos visuales globales
│
├── features/                           # Módulos aislados de la aplicación (Features)
│   │
│   ├── auth/                           # MÓDULO 1: Validación de Cédula y Login Admin
│   │   ├── data/
│   │   │   ├── datasources/            # Peticiones HTTP remotas/locales
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/                 # Mapeo de JSON a objetos Dart
│   │   │   │   └── usuario_model.dart
│   │   │   └── repositories/           # Implementación del contrato de dominio
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/               # Objetos puros de negocio (Usuario con rol)
│   │   │   │   └── usuario.dart
│   │   │   ├── repositories/           # Interfaz/Contrato del repositorio
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/               # Lógica de negocio específica
│   │   │       ├── verificar_cedula.dart
│   │   │       └── login_administrador.dart
│   │   └── presentation/
│   │       ├── controller/             # Gestor de estado (Bloc / Cubit / Riverpod)
│   │       │   └── auth_controller.dart
│   │       ├── screens/                # Pantallas físicas
│   │       │   ├── ingreso_cedula_screen.dart
│   │       │   └── contrasena_admin_screen.dart
│   │       └── widgets/                # Widgets locales del módulo
│   │           └── aviso_rol_dialog.dart # Diálogo de selección para Administradores
│   │
│   ├── encuesta/                       # MÓDULO 2: Flujo de preguntas, respuestas y resultados
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── encuesta_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── pregunta_model.dart
│   │   │   │   └── respuesta_model.dart
│   │   │   └── repositories/
│   │   │       └── encuesta_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── pregunta.dart
│   │   │   │   └── dimension.dart
│   │   │   ├── repositories/
│   │   │   │   └── encuesta_repository.dart
│   │   │   └── usecases/
│   │   │       ├── obtener_encuesta_activa.dart
│   │   │       └── enviar_encuesta.dart
│   │   └── presentation/
│   │       ├── controller/
│   │       │   └── encuesta_controller.dart
│   │       ├── screens/
│   │       │   ├── responder_encuesta_screen.dart
│   │       │   └── resultados_screen.dart
│   │       └── widgets/
│   │           └── tarjeta_pregunta_widget.dart
│   │
│   └── admin_panel/                    # MÓDULO 3: Panel interno y CRUD de gestión
│       ├── data/
│       │   ├── datasources/
│       │   │   └── admin_remote_datasource.dart
│       │   └── repositories/
│       │       └── admin_repository_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── admin_repository.dart
│       │   └── usecases/
│       │       ├── gestionar_preguntas_usecase.dart
│       │       ├── gestionar_dimensiones_usecase.dart
│       │       ├── gestionar_admins_usecase.dart
│       │       └── cambiar_contrasena_usecase.dart
│       └── presentation/
│           ├── controller/
│           │   └── admin_panel_controller.dart
│           ├── screens/
│           │   ├── panel_principal_screen.dart
│           │   ├── gestion_preguntas_screen.dart
│           │   ├── gestion_dimensiones_screen.dart
│           │   └── gestion_usuarios_screen.dart
│           └── widgets/
│               └── tabla_datos_widget.dart
│
├── injection.dart                      # Registro de dependencias globales (GetIt / Injectable)
└── main.dart                           # Punto de entrada de la aplicación