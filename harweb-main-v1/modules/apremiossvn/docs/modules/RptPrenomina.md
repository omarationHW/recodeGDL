# Documentación Técnica: Migración de Formulario RptPrenomina (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte de prenómina de ejecutores, originalmente en Delphi, a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

El reporte permite consultar, filtrar y visualizar los pagos a ejecutores por periodo y recaudadora, mostrando totales y agrupaciones relevantes.

## 2. Arquitectura
- **Backend:** Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, página independiente para el formulario
- **Base de Datos:** PostgreSQL, lógica SQL migrada a stored procedures

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "eRequest": "RptPrenomina",
    "eParams": {
      "fec1": "YYYY-MM-DD",
      "fec2": "YYYY-MM-DD",
      "recaud": 1,
      "recaud1": 9
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": "OK",
    "eMessage": "Reporte generado",
    "eData": {
      "rows": [ ... ],
      "totals": { ... }
    }
  }
  ```

## 4. Stored Procedures
- **rpt_prenomina:** Devuelve el detalle del reporte (filas)
- **rpt_prenomina_totals:** Devuelve los totales generales y por tipo

## 5. Frontend (Vue.js)
- Página independiente `/rpt-prenomina`
- Formulario de filtros (fechas y recaudadoras)
- Tabla de resultados con totales
- Breadcrumb de navegación
- Manejo de estados (cargando, error, vacío)

## 6. Backend (Laravel)
- Controlador `ExecuteController` con método `execute`
- Lógica de ruteo por `eRequest`
- Llamada a stored procedures vía DB::select
- Validación de parámetros

## 7. Seguridad
- Validar y sanear todos los parámetros recibidos
- Se recomienda proteger el endpoint con autenticación (no incluido en este ejemplo)

## 8. Consideraciones
- El frontend asume que el backend retorna los campos esperados y calcula el 75% en el cliente para mostrarlo por fila
- Los totales se calculan en el stored procedure
- El formato de fechas y moneda se adapta a español (MX)

## 9. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros formularios/reportes usando el mismo patrón
- Los stored procedures pueden ser optimizados para performance según volumen de datos

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12

