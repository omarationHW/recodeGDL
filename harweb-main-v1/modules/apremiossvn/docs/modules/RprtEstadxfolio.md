# Documentación Técnica: Migración Formulario RprtEstadxfolio (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte estadístico de notificaciones por folio (RprtEstadxfolio) de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel API, con endpoint único `/api/execute` siguiendo el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "getEstadxFolioReport",
    "params": {
      "modu": 11,
      "rec": 1,
      "fol1": 1000,
      "fol2": 2000
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta y agrupación se realiza en funciones SQL (`rpt_estadxfolio`, `rpt_recaudadora_zona`).
- El backend Laravel invoca estos procedimientos vía DB::select.

## 5. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las peticiones.
- Cada tipo de consulta se identifica por el campo `eRequest`.
- Métodos privados ejecutan los stored procedures y retornan los datos.

## 6. Componente Vue.js
- Página independiente, sin tabs.
- Formulario para capturar parámetros (módulo, recaudadora, folio inicial/final).
- Consulta el API y muestra los resultados en tabla.
- Permite consultar información de la oficina (recaudadora/zona).
- Incluye navegación breadcrumb.

## 7. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o session según la política de la aplicación.

## 8. Validaciones
- El backend valida la presencia de parámetros requeridos.
- El frontend valida campos obligatorios antes de enviar la consulta.

## 9. Extensibilidad
- Para agregar nuevos reportes o procesos, basta con:
  - Crear el stored procedure correspondiente.
  - Agregar el case en el controlador Laravel.
  - Consumirlo desde el frontend usando el mismo endpoint.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

---
