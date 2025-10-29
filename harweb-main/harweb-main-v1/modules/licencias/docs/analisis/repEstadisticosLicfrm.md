# Documentación Técnica: Migración de repEstadisticosLicfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)
- **Patrón de integración:** eRequest/eResponse (API unificada)

## Flujo de Trabajo
1. **El usuario accede a la página de reportes estadísticos de licencias** (componente Vue.js).
2. **Selecciona el tipo de reporte** y, si aplica, el rango de fechas y/o clasificación.
3. **Al presionar "Consultar"**, el frontend envía una petición POST a `/api/execute` con el objeto `eRequest`:
   ```json
   {
     "eRequest": {
       "action": "reporte_licencias_rango", // o el que corresponda
       "params": { "fecha1": "2024-01-01", "fecha2": "2024-06-30" }
     }
   }
   ```
4. **El controlador Laravel** recibe la petición, identifica la acción y llama al stored procedure correspondiente en PostgreSQL.
5. **El resultado** se retorna en el objeto `eResponse`:
   ```json
   {
     "eResponse": {
       "success": true,
       "data": [ ... ]
     }
   }
   ```
6. **El frontend muestra los resultados** en una tabla dinámica.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: object } }`
  - Salida: `{ eResponse: { success: bool, data: array, error?: string } }`

## Stored Procedures
- Toda la lógica de agrupación, conteo y filtrado se implementa en SPs de PostgreSQL.
- Los SPs devuelven tablas con los campos requeridos para los reportes.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Manejo de errores y logs.

## Frontend
- Cada formulario es una página Vue.js independiente.
- No se usan tabs ni componentes tabulares.
- Navegación y breadcrumbs opcionales.
- El formulario es reactivo y muestra errores de validación.
- Resultados en tabla dinámica con columnas automáticas.

## Extensibilidad
- Para agregar nuevos reportes, basta con:
  1. Crear el SP en PostgreSQL.
  2. Agregar el case en el controlador Laravel.
  3. Añadir la opción en el frontend.

## Pruebas
- Casos de uso y escenarios de prueba incluidos (ver más abajo).

# Notas de Migración
- Todas las queries SQL del Delphi original se migran a SPs.
- El frontend no replica el diseño visual de Delphi, sino la funcionalidad.
- El endpoint es único y desacoplado de la UI.

# Consideraciones
- Los reportes pueden ser exportados desde el frontend usando herramientas de Vue.js.
- El backend puede ser extendido para autenticación y autorización.
