# Documentación Técnica - Migración Formulario RepDescImpto (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde al reporte de descuentos de impuesto predial (RepDescImpto), permitiendo consultar, filtrar y exportar los descuentos aplicados y reactivados, con filtros por fechas, recaudadora y tipo de descuento. La migración se realizó a una arquitectura Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y un endpoint API unificado.

## Arquitectura
- **Backend:** Laravel 10+, controlador único (`RepDescImptoController`) con endpoint `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente (`RepDescImpto.vue`).
- **Base de Datos:** PostgreSQL, lógica de reportes en stored procedures (`sp_rep_desc_impto_aplicados`, `sp_rep_desc_impto_reactivados`).
- **API Unificada:** Todas las acciones se ejecutan vía POST `/api/execute` usando el patrón eRequest/eResponse.

## API (Laravel)
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getDescuentos", // o 'getCatalogs', 'exportExcel', etc.
      "params": { ... } // parámetros según acción
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [...],
      "message": ""
    }
  }
  ```
- **Acciones soportadas:**
  - `getCatalogs`: Devuelve catálogos de recaudadoras y tipos de descuento.
  - `getDescuentos`: Devuelve los descuentos aplicados/reactivados según filtros.
  - `exportExcel`: (Frontend, no implementado en backend)

## Stored Procedures (PostgreSQL)
- **sp_rep_desc_impto_aplicados**: Devuelve descuentos aplicados, filtrando por fechas, recaudadora y tipo de descuento.
- **sp_rep_desc_impto_reactivados**: Devuelve descuentos reactivados, filtrando por fechas, recaudadora y tipo de descuento.

## Frontend (Vue.js)
- Página independiente, sin tabs, con formulario de filtros y tabla de resultados.
- Exportación a Excel se realiza en frontend (window.print o librería xlsx).
- Navegación y breadcrumbs opcionales.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel) si la aplicación lo exige.
- Validación de parámetros en backend y frontend.

## Consideraciones de Migración
- Todas las queries SQL del Delphi fueron convertidas a stored procedures PostgreSQL.
- El endpoint `/api/execute` centraliza todas las acciones, usando el patrón eRequest/eResponse.
- El frontend Vue.js es una página completa, sin tabs ni componentes tabulares.
- El reporte puede ser exportado a Excel desde el frontend.

## Estructura de la Base de Datos
- Tablas principales: `descpred`, `descpred_reactiva`, `convcta`, `c_descpred`, `c_instituciones`, `usuarios`, `deptos`, `detsaldos`, `uem3`.
- Los stored procedures usan JOINs y subconsultas para obtener los datos requeridos.

## Extensibilidad
- Se pueden agregar más filtros o acciones en el controlador y stored procedures.
- El frontend puede adaptarse a nuevos requerimientos de presentación.

## Integración
- El componente Vue.js se integra en el router principal de la SPA.
- El endpoint `/api/execute` puede ser consumido por cualquier cliente autorizado.

