# Documentación Técnica - Migración Formulario Acceso Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada/salida JSON).

## Flujo de Autenticación
1. El usuario accede a la página de acceso (`/acceso`).
2. Ingresa usuario y contraseña.
3. El formulario Vue envía POST a `/api/execute` con:
   ```json
   {
     "eRequest": {
       "action": "login",
       "params": {
         "username": "usuario",
         "password": "contraseña"
       }
     }
   }
   ```
4. Laravel recibe la petición, ejecuta el SP `sp_login`.
5. Si es exitoso, retorna datos del usuario y redirige al menú principal.
6. Si falla, muestra mensaje de error.

## Endpoint Unificado `/api/execute`
- Todas las operaciones del sistema se realizan a través de este endpoint.
- El campo `action` determina la operación (login, getUserInfo, getFoliosReport, registerFolio, getCatalog, etc).
- Los parámetros se envían en `params`.
- El backend despacha la acción y ejecuta el SP correspondiente.

## Seguridad
- Las contraseñas se almacenan con hash seguro (usar `crypt` de PostgreSQL o bcrypt en Laravel).
- El endpoint debe protegerse con CSRF y/o JWT según el contexto.
- El usuario bloqueado o con estado distinto de 'A' no puede acceder.

## Manejo de Sesión
- El frontend almacena el usuario en localStorage para autocompletar.
- El backend puede emitir un token JWT para sesiones (opcional, según requerimiento).

## Manejo de Errores
- Todos los errores se devuelven en el campo `error` de la respuesta JSON.
- El frontend muestra los errores de forma amigable.

## Stored Procedures
- Toda la lógica de negocio y validación reside en SPs de PostgreSQL.
- Los SPs devuelven tablas o registros con campos de éxito/error.
- Los catálogos se obtienen por SP genérico `sp_get_catalog`.

## Componentes Vue.js
- Cada formulario es una página independiente (ejemplo: AccesoFormulario.vue).
- No se usan tabs ni componentes tabulares.
- Se incluye navegación breadcrumb.
- El formulario Acceso es completamente funcional y desacoplado.

## Ejemplo de eRequest/eResponse
### Request
```json
{
  "eRequest": {
    "action": "login",
    "params": {
      "username": "admin",
      "password": "1234"
    }
  }
}
```
### Response
```json
{
  "eResponse": {
    "success": true,
    "user": {
      "user_id": 1,
      "username": "admin",
      "nombre": "Administrador",
      "nivel": 1
    }
  }
}
```

## Consideraciones de Migración
- Los nombres de tablas y campos pueden adaptarse a la convención Laravel/PostgreSQL.
- Los SPs deben manejar transacciones y errores de forma robusta.
- El frontend debe ser desacoplado y consumir solo el endpoint unificado.

## Pruebas y QA
- Se recomienda usar Postman para pruebas de API.
- El frontend puede ser probado con Cypress o Jest.
- Los casos de uso y prueba deben cubrir escenarios de éxito y error.
