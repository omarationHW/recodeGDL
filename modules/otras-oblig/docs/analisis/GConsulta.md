# Documentación Técnica: Migración de Formulario GConsulta (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel API RESTful con endpoint único `/api/execute`.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Patrón de Comunicación:** eRequest/eResponse (el frontend envía un objeto `eRequest` con operación y parámetros; el backend responde con `eResponse`).

## Flujo de Datos
1. **El usuario accede a la página de consulta** (Vue.js).
2. **El frontend solicita las etiquetas y la tabla** (para mostrar los campos y títulos correctos).
3. **El usuario ingresa el dato de búsqueda** (número de expediente o local).
4. **El frontend envía un eRequest** con la operación y parámetros al endpoint `/api/execute`.
5. **El backend ejecuta el stored procedure correspondiente** y retorna los datos en eResponse.
6. **El frontend muestra los datos generales, adeudos, totales y pagos realizados**.

## Endpoint API
- **POST /api/execute**
  - **Entrada:**
    ```json
    {
      "eRequest": {
        "operation": "getDatosGenerales",
        "params": { "par_tab": 3, "par_control": "123-1" }
      }
    }
    ```
  - **Salida:**
    ```json
    {
      "eResponse": {
        "success": true,
        "data": [ ... ],
        "message": ""
      }
    }
    ```

## Stored Procedures
- Todos los procedimientos almacenados reciben parámetros y retornan tablas (resultsets).
- Se utiliza el mismo nombre de operación en el frontend y backend para facilitar el mapeo.

## Seguridad
- Se recomienda agregar autenticación JWT o similar en producción.
- Validar y sanear todos los parámetros recibidos en el backend.

## Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo stored procedure y agregar el case correspondiente en el controlador Laravel.
- El frontend puede consumir cualquier operación agregando el nombre y parámetros en el eRequest.

## Manejo de Errores
- Todos los errores del backend se devuelven en el campo `message` de eResponse.
- El frontend muestra los errores en pantalla.

## Consideraciones de UI
- Cada formulario es una página independiente (no tabs).
- Breadcrumbs para navegación.
- Tablas responsivas y amigables.
- Mensajes claros de error y validación.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para pruebas de frontend.

