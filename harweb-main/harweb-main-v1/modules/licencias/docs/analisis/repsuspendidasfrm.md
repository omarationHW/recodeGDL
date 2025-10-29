# Documentación Técnica: Migración de Formulario repsuspendidasfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de licencias suspendidas, migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y filtrado se encapsula en un stored procedure, y la comunicación entre frontend y backend se realiza mediante un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** El endpoint recibe un JSON con los campos `eRequest` (nombre de la operación) y `params` (parámetros de entrada). El controlador despacha la petición según el valor de `eRequest`.
- **Reporte:** Para `eRequest: 'repsuspendidas_report'`, el controlador llama al stored procedure `report_licencias_suspendidas` pasando los parámetros recibidos.
- **Validación:** Si no se recibe año ni fechas, retorna error 422.
- **Respuesta:**
  - `eResponse: 'ok'` y los datos del reporte si hay resultados.
  - `eResponse: 'ok'` y mensaje si no hay resultados.
  - `eResponse: 'error'` y mensaje si hay error de validación o ejecución.

## 3. Frontend (Vue.js)
- **Componente:** Página independiente `RepSuspendidasPage.vue`.
- **Ruta:** Debe ser registrada como página completa (no tab).
- **Formulario:** Permite filtrar por año, rango de fechas y tipo de suspensión (botones tipo radio).
- **Validación:** No permite enviar si no hay año ni fechas.
- **Resultados:** Muestra tabla con los campos principales del reporte, incluyendo traducción del campo `bloqueado` a texto legible.
- **UX:** Incluye breadcrumbs, mensajes de error y éxito, y spinner de carga.

## 4. Stored Procedure (PostgreSQL)
- **Nombre:** `report_licencias_suspendidas`
- **Parámetros:**
  - `p_year` (INT): Año de búsqueda (opcional)
  - `p_date_from` (DATE): Fecha inicial (opcional)
  - `p_date_to` (DATE): Fecha final (opcional)
  - `p_tipo_suspension` (INT): Tipo de suspensión (0=Todas, 1=Bloqueo, ...)
- **Lógica:**
  - Si se indica año, filtra desde el 1 de enero de ese año.
  - Si se indica fecha inicial y no final, filtra por esa fecha exacta.
  - Si se indican ambas fechas, filtra entre ellas.
  - Si se indica tipo de suspensión > 0, filtra por ese valor en `bloqueado`.
  - Siempre filtra por `b.vigente = 'V'`.
  - Devuelve todos los campos de licencias más el campo calculado `propietarionvo`.

## 5. API Unificada
- **Entrada:**
  ```json
  {
    "eRequest": "repsuspendidas_report",
    "params": {
      "year": 2024,
      "date_from": "2024-01-01",
      "date_to": "2024-01-31",
      "tipo_suspension": 1
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": "ok",
    "data": [ ... ],
    "total": 5
  }
  ```

## 6. Seguridad
- El endpoint debe protegerse con autenticación (ej: Sanctum, JWT) según la política del sistema.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones
- El frontend asume que el backend retorna los campos con los mismos nombres que en la base de datos.
- El campo `bloqueado` se traduce a texto en el frontend.
- El reporte puede ser exportado a PDF/Excel agregando funcionalidad adicional.
