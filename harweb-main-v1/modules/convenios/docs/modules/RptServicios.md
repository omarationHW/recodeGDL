# Documentación Técnica: Migración de RptServicios (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario/reporte "RptServicios" del sistema Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de Datos). El objetivo es mantener la funcionalidad de consulta y reporte del catálogo de servicios/obra pública, permitiendo su visualización web y futura integración con otros sistemas.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` bajo patrón eRequest/eResponse.
- **Frontend:** Vue.js 2/3 SPA, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. Endpoints y Protocolo
- **Endpoint Único:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "eRequest": "RptServicios.getAll", // o "RptServicios.count"
    "params": {}
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [...], // o número
    "error": null
  }
  ```

## 4. Stored Procedures
- **rptservicios_get_all()**: Devuelve todos los servicios (campos: servicio, descripcion, serv_obra94).
- **rptservicios_count()**: Devuelve el total de servicios.

## 5. Controlador Laravel
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método:** `execute(Request $request)`
- **Lógica:**
  - Lee `eRequest` y ejecuta el stored procedure correspondiente.
  - Devuelve la respuesta bajo el patrón eResponse.

## 6. Componente Vue.js
- **Nombre:** `RptServiciosPage`
- **Ruta:** `/rpt-servicios` (ejemplo)
- **Funcionalidad:**
  - Consulta la API para obtener la lista y el total de servicios.
  - Muestra la información en una tabla con encabezados y pie de página.
  - Incluye breadcrumb y metadatos (fecha, página, nombre del reporte).

## 7. Seguridad
- El endpoint puede protegerse con middleware de autenticación (ej: Sanctum, JWT) según la política del sistema.

## 8. Consideraciones de Migración
- El reporte Delphi usaba QuickReport y una consulta directa a la tabla `ta_17_servicios`.
- En la migración, toda la lógica de consulta se encapsula en stored procedures para facilitar mantenibilidad y seguridad.
- El frontend es completamente independiente y no usa tabs ni componentes compartidos con otros formularios.

## 9. Requisitos para despliegue
- El logo debe estar disponible en `/src/assets/logo_guadalajara.png` o la ruta correspondiente.
- Las stored procedures deben estar creadas en la base de datos PostgreSQL destino.
- El endpoint `/api/execute` debe estar registrado en `routes/api.php`:
  ```php
  Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.
- Los stored procedures pueden evolucionar para incluir filtros, paginación, etc.

## 11. Manejo de Errores
- Todos los errores se devuelven en el campo `error` del eResponse.
- El frontend muestra mensajes de error amigables al usuario.

## 12. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
