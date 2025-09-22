# Documentación Técnica: Migración de Formulario spubreports (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL 13+ (toda la lógica de reportes en stored procedures)
- **Patrón API**: eRequest/eResponse (payload JSON con operación y parámetros)

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "operation": "spubreports_list", // o el nombre del SP
      "params": { "opc": 1 }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## Stored Procedures
- Toda la lógica de reportes y resúmenes se implementa en funciones PostgreSQL (ver sección `stored_procedures`).
- Cada SP retorna un TABLE con los campos requeridos para el frontend.
- Los SPs están optimizados para consultas de solo lectura y pueden ser extendidos para filtros adicionales.

## Laravel Controller
- Controlador único (`ExecuteController`) que recibe el nombre de la operación y parámetros.
- Valida la operación y ejecuta el SP correspondiente usando DB::select.
- Devuelve la respuesta en formato eResponse.
- Maneja errores y validaciones de parámetros.

## Vue.js Component
- Página independiente para el formulario de reportes.
- Permite seleccionar el tipo de reporte (por categoría, sector, etc).
- Llama al endpoint `/api/execute` con la operación y parámetros.
- Muestra los datos en tablas responsivas.
- Incluye navegación breadcrumb.
- Maneja estados de carga y error.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: Sanctum, JWT) en producción.
- Validar y sanear todos los parámetros recibidos antes de ejecutar los SPs.

## Extensibilidad
- Para agregar nuevos reportes, crear un nuevo SP y agregar el case correspondiente en el controlador.
- El frontend puede extenderse para nuevas vistas/páginas sin modificar la arquitectura base.

## Migración de Datos
- Las tablas `pubmain`, `pubcategoria`, `pubadeudo`, `pubadeudo_histo` deben existir en PostgreSQL con la estructura adecuada.
- Los datos deben migrarse desde la base original (Firebird/Interbase) a PostgreSQL antes de operar.

## Pruebas y QA
- Se recomienda usar Postman o similar para pruebas de API.
- El frontend puede ser probado con datos reales o mockeados.
- Los casos de uso y prueba están detallados en las siguientes secciones.
