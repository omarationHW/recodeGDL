# Documentación Técnica: Migración de Formulario psplash (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `psplash` es la pantalla de bienvenida (splash screen) de la aplicación. Su función principal es mostrar una imagen, el nombre de la aplicación, la versión y un mensaje de bienvenida mientras se carga el sistema.

Esta migración implementa la funcionalidad en una arquitectura moderna:
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js (SPA)
- **API:** Unificada bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse
- **Base de datos:** Toda la lógica SQL encapsulada en stored procedures

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan a través de `/api/execute` con un parámetro `eRequest` que define la acción y `params` para los parámetros.
- **Stored Procedures:** Toda la lógica de obtención de datos y procesos se realiza en PostgreSQL mediante funciones almacenadas.
- **Frontend:** Cada formulario es una página Vue.js independiente, sin tabs ni componentes tabulares.

## 3. Endpoints y eRequest
- `/api/execute` (POST)
  - `eRequest: 'psplash.getSplashInfo'` → Obtiene la información de la pantalla splash.
  - `eRequest: 'psplash.logSplashView'` → (Opcional) Registra la visualización del splash.

## 4. Stored Procedures
- `psplash_get_splash_info()`: Devuelve la URL de la imagen, la versión y el copyright.
- `psplash_log_splash_view(user_id, ip)`: Registra la visualización del splash (opcional, para auditoría).

## 5. Frontend (Vue.js)
- Página independiente `/psplash`.
- Muestra la imagen, mensaje de bienvenida y versión.
- Realiza la consulta a la API al cargar la página.
- No utiliza tabs ni componentes compartidos.

## 6. Backend (Laravel)
- Controlador `Api\ExecuteController` con método `execute`.
- Valida el parámetro `eRequest` y ejecuta el stored procedure correspondiente.
- Devuelve la respuesta en formato eResponse (success, message, data, errors).

## 7. Seguridad
- El endpoint puede requerir autenticación según la política de la aplicación.
- El stored procedure de log puede registrar el usuario y la IP para auditoría.

## 8. Extensibilidad
- Para agregar nuevos formularios, solo se requiere agregar nuevos casos en el switch del controlador y los stored procedures correspondientes.

## 9. Consideraciones de Imagen
- La imagen puede estar en `/public/assets/splash.jpg` o almacenada en base64 en la base de datos.
- El frontend espera una URL pública.

## 10. Pruebas
- Se recomienda probar la carga de la página, la visualización de la imagen y la correcta obtención de la versión.
- Verificar el registro de logs si se implementa la función de auditoría.
