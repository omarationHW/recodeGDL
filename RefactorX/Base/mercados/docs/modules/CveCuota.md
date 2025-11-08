# Documentación Técnica: Catálogo de Claves de Cuota (CveCuota)

## Descripción General
Este módulo permite la administración del catálogo de claves de cuota, incluyendo la consulta, alta, modificación y eliminación de claves. La solución está compuesta por:
- Un controlador Laravel que expone un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- Un componente Vue.js que implementa la interfaz de usuario como página independiente.
- Stored procedures en PostgreSQL para encapsular la lógica de negocio y acceso a datos.

## Arquitectura
- **Backend**: Laravel 10+, PostgreSQL 13+, API RESTful.
- **Frontend**: Vue.js 3+, SPA, rutas independientes por formulario.
- **Base de Datos**: Tabla `ta_11_cve_cuota` con campos `clave_cuota` (smallint, PK) y `descripcion` (varchar).

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "listCveCuota|createCveCuota|updateCveCuota|deleteCveCuota|getCveCuota",
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "Mensaje de resultado",
      "data": [ ... ]
    }
  }
  ```

## Stored Procedures
- Toda la lógica de acceso y manipulación de datos se realiza mediante stored procedures en PostgreSQL.
- Los procedimientos están versionados y documentados.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Uso de transacciones en operaciones de escritura.
- El frontend no expone directamente los procedimientos ni la estructura de la base de datos.

## Frontend
- El componente Vue.js es una página completa, no usa tabs ni subcomponentes tabulares.
- Incluye navegación breadcrumb.
- Permite agregar, editar y listar claves de cuota.
- Mensajes de error y éxito amigables.

## Backend
- El controlador Laravel recibe todas las peticiones por el endpoint `/api/execute`.
- Cada acción del frontend se traduce en una llamada a un stored procedure.
- El patrón eRequest/eResponse permite desacoplar la lógica de negocio del transporte HTTP.

## Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

# Tabla de Base de Datos
```sql
CREATE TABLE ta_11_cve_cuota (
  clave_cuota smallint PRIMARY KEY,
  descripcion varchar(50) NOT NULL
);
```

# Ejemplo de Request/Response
## Listar claves de cuota
**Request:**
```json
{
  "eRequest": { "action": "listCveCuota" }
}
```
**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "clave_cuota": 1, "descripcion": "MENSUAL" },
      { "clave_cuota": 2, "descripcion": "BIMESTRAL" }
    ]
  }
}
```

# Notas de Migración
- El formulario Delphi se ha migrado a una arquitectura web moderna.
- Todas las operaciones de negocio se encapsulan en stored procedures para facilitar el mantenimiento y la auditoría.
- El frontend es desacoplado y puede evolucionar independientemente del backend.
