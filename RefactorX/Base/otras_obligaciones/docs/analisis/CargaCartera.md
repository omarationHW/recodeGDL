# Documentación Técnica: Carga de Carteras

## Descripción General
El proceso de "Carga de Carteras" permite generar la cartera de obligaciones para una tabla y ejercicio fiscal específico. El usuario selecciona la tabla y el ejercicio, visualiza las unidades asociadas y puede ejecutar la generación de cartera, la cual se realiza mediante un procedimiento almacenado en PostgreSQL.

## Arquitectura
- **Frontend:** Vue.js (SPA, página independiente)
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (Stored Procedures)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  - **Request:**
    ```json
    {
      "eRequest": {
        "action": "nombreAccion",
        "params": { ... }
      }
    }
    ```
  - **Response:**
    ```json
    {
      "eResponse": {
        "success": true|false,
        "message": "Mensaje de resultado",
        "data": [ ... ]
      }
    }
    ```

### Acciones Soportadas
- `getTablas`: Listado de tablas disponibles para cargar cartera.
- `getEjercicios`: Ejercicios disponibles para una tabla.
- `getUnidades`: Unidades asociadas a una tabla y ejercicio.
- `cargaCartera`: Ejecuta la generación de cartera vía stored procedure.

## Stored Procedure Principal
- **Nombre:** `con34_cgacart_01`
- **Parámetros:**
  - `par_tabla` (TEXT): Clave de la tabla
  - `par_ejer` (INTEGER): Ejercicio fiscal
- **Retorno:**
  - `status` (INTEGER): 0=OK, >0=Error
  - `concepto_status` (TEXT): Mensaje descriptivo

## Flujo de la Página Vue.js
1. Al cargar la página, se solicita el listado de tablas (`getTablas`).
2. Al seleccionar una tabla, se solicitan los ejercicios disponibles (`getEjercicios`).
3. Al seleccionar un ejercicio, se muestran las unidades (`getUnidades`).
4. Si existen unidades, se habilita el botón "Aplicar".
5. Al presionar "Aplicar", se ejecuta el stored procedure (`cargaCartera`).
6. Se muestra el mensaje de éxito o error según el resultado.

## Validaciones
- No se permite ejecutar la carga si no hay unidades para la tabla/ejercicio.
- Se solicita confirmación antes de ejecutar la carga.
- Se muestra el mensaje devuelto por el stored procedure.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT, session, etc).
- Validar que el usuario tenga permisos para ejecutar la carga de cartera.

## Manejo de Errores
- Todos los errores del backend se devuelven en el campo `message` de la respuesta.
- El frontend muestra los mensajes de error en pantalla.

## Consideraciones
- El proceso es transaccional: si ocurre un error, no se realizan cambios parciales.
- El stored procedure puede ser extendido para registrar logs de auditoría.
