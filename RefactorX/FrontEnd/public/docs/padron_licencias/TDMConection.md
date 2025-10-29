# Documentación Técnica: Migración TDMConection Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de datos:** PostgreSQL 14+, toda la lógica SQL encapsulada en stored procedures/functions
- **Autenticación:** Token simple (puede migrarse a JWT), sesión en caché
- **Bitácora:** Uso de tabla `bitacora_lic_login` para registrar inicio y fin de sesión

## Flujo de Autenticación y Bitácora
1. **Login:**
   - El usuario ingresa usuario y contraseña.
   - Se valida contra la tabla `usuarios`.
   - Si es correcto, se ejecuta `fn_bitacora_lic_login` para registrar el inicio de sesión y se obtiene el `id_bitacora`.
   - Se genera un token de sesión y se guarda en caché junto con el id de bitácora.
2. **Logout:**
   - Se ejecuta `sp_bitacora_lic_logout` con el `id_bitacora` y la fecha/hora de fin.
   - Se elimina el token de la caché.

## API Unificada `/api/execute`
- Todas las acciones se envían como un JSON con los campos `action` y `params`.
- El controlador Laravel resuelve la acción y ejecuta la lógica correspondiente, llamando a los stored procedures si aplica.
- Ejemplo de request:
```json
{
  "action": "login",
  "params": {
    "username": "usuario",
    "password": "clave"
  }
}
```

## Vue.js
- Cada formulario es una página Vue independiente.
- El componente de conexión muestra login, información de usuario, bitácora y permite cerrar sesión.
- No se usan tabs ni componentes tabulares.
- Navegación por rutas (vue-router).

## Stored Procedures
- Toda la lógica de bitácora y usuario está en SPs/funciones PostgreSQL.
- Se recomienda encapsular toda lógica de negocio en SPs para facilitar mantenimiento y auditoría.

## Seguridad
- Contraseñas hasheadas (bcrypt o similar).
- Validación de parámetros en backend y frontend.
- Uso de tokens para sesión.

## Manejo de Errores
- Todas las respuestas siguen el patrón `{ success, message, data }`.
- Errores de validación y de base de datos se reportan en el campo `message`.

## Extensibilidad
- El endpoint `/api/execute` puede crecer para soportar más acciones (CRUD, reportes, procesos, etc).
- Los SPs pueden ampliarse para lógica de negocio adicional.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

