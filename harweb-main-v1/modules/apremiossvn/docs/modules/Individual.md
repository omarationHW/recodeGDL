# Documentación Técnica: Migración Formulario Individual (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (toda la lógica SQL encapsulada en stored procedures)
- **Patrón API:** eRequest/eResponse (el frontend envía un objeto `eRequest` con acción y parámetros; el backend responde con `eResponse`)

## Flujo de Consulta Individual
1. **El usuario accede a la página de consulta individual**
2. Ingresa el folio, aplicación (módulo) y recaudadora (rec)
3. El frontend envía un `eRequest` con acción `getFolio` y el folio
4. El backend ejecuta el SP `get_individual_folio` y retorna los datos principales
5. El frontend solicita historia (`getFolioHistory`), periodos (`getFolioPeriods`) y detalle de módulo (`getModuleDetails`)
6. El usuario visualiza toda la información en una sola página

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getFolio",
      "params": { "folio": 12345 }
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
- Toda la lógica de consulta y composición de datos está en SPs de PostgreSQL
- Los SPs devuelven tablas o JSON según el caso
- El backend sólo orquesta la llamada y retorna el resultado

## Seguridad
- El endpoint requiere autenticación JWT (no incluido aquí, pero recomendado)
- Validación de parámetros en el controlador

## Frontend
- El componente Vue es una página completa, no usa tabs
- Cada sección (datos generales, historia, periodos, detalle de aplicación) se muestra en tablas separadas
- Navegación breadcrumb incluida
- Manejo de errores y loading

## Extensibilidad
- Para agregar nuevas acciones, basta con crear un nuevo SP y mapearlo en el controlador
- El frontend puede consumir cualquier acción usando el mismo endpoint

## Ejemplo de eRequest/eResponse
- **Consulta de folio:**
  ```json
  {
    "eRequest": {
      "action": "getFolio",
      "params": { "folio": 12345 }
    }
  }
  ```
- **Consulta de historia:**
  ```json
  {
    "eRequest": {
      "action": "getFolioHistory",
      "params": { "id_control": 123 }
    }
  }
  ```

## Consideraciones de Migración
- Los campos calculados y joins de Delphi se implementan como subconsultas en los SPs
- El frontend no conoce la estructura interna de la base de datos, sólo consume el API
- El backend es desacoplado y sólo expone lo necesario

# Despliegue
- Los SPs deben crearse en la base de datos PostgreSQL
- El controlador debe registrarse en `routes/api.php`:
  ```php
  Route::post('/execute', [IndividualController::class, 'execute']);
  ```
- El frontend debe tener configurado Axios para consumir `/api/execute`

# Pruebas y QA
- Se recomienda usar Postman para probar el endpoint con diferentes acciones
- El frontend puede ser probado con datos reales y mockeados

# Mantenimiento
- Para agregar nuevos módulos, sólo se requiere agregar lógica en el SP `get_module_details`
- Para nuevos reportes, crear nuevos SPs y mapearlos en el controlador
