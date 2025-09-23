# Documentación Técnica: Migración de Formulario Modulo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. Endpoints API
- **POST /api/execute**
  - **Body:**
    - `action`: Nombre de la acción a ejecutar (string)
    - `params`: Parámetros requeridos por la acción (object)
  - **Acciones soportadas:**
    - `getCurrentTime`: Devuelve la hora actual del servidor.
    - `getUserByCredentials`: Valida usuario y clave, retorna datos del usuario si es válido.
    - `getUserDetails`: Devuelve detalles del usuario por nombre de usuario.
    - `checkNewVersion`: Verifica si hay una nueva versión para el proyecto.
    - `getVersionDetails`: Devuelve detalles de la versión de un proyecto.

## 3. Stored Procedures
- Toda la lógica de negocio y validación reside en procedimientos almacenados.
- Los procedimientos devuelven tablas (TABLE) para facilitar el consumo desde Laravel.

## 4. Seguridad
- Las credenciales de usuario se validan en el SP `sp_valida_usuario`.
- El endpoint `/api/execute` puede protegerse con middleware de autenticación si se requiere.

## 5. Frontend
- El componente Vue.js es una página completa, con navegación breadcrumb.
- Permite:
  - Validar usuario y clave.
  - Consultar la hora actual del servidor.
  - Verificar si hay una nueva versión de un proyecto.
- Cada sección es independiente y funcional.

## 6. Flujo de Datos
1. El usuario interactúa con la página Vue.js.
2. Vue.js envía una petición POST a `/api/execute` con la acción y parámetros.
3. Laravel recibe la petición, ejecuta el SP correspondiente y retorna el resultado en formato JSON.
4. Vue.js muestra el resultado al usuario.

## 7. Consideraciones de Migración
- El formulario Delphi usaba queries directas y lógica en el cliente; ahora todo reside en SPs y el frontend solo consume la API.
- El control de sesión y autenticación puede ampliarse según necesidades.
- Los nombres de tablas y campos deben coincidir con la estructura original.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad migrada.
