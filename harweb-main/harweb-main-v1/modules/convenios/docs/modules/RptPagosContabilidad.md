# Documentación Técnica: Migración RptPagosContabilidad Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte "RptPagosContabilidad" originalmente en Delphi, migrado a una arquitectura moderna con Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El reporte muestra los pagos realizados agrupados por fondo, año de obra y cuenta de ingreso, con sumatoria de ingresos.

## 2. Arquitectura
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js SPA, página independiente para el formulario de consulta.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure `sp_rpt_pagos_contabilidad`.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getRptPagosContabilidad",
      "params": {
        "fecdesde": "YYYY-MM-DD",
        "fechasta": "YYYY-MM-DD"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        { "tipo": 15, "axo_obra": 2023, "cuenta_ingreso": 12345, "ingreso": 10000.00, "descripcion": "RAMO 33" },
        ...
      ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_rpt_pagos_contabilidad:** Devuelve el reporte agrupado y con descripción del fondo.
- **sp_catalog_tipos:** Devuelve el catálogo de tipos de fondo.

## 5. Laravel Controller
- Controlador único `RptPagosContabilidadController`.
- Método `execute(Request $request)` procesa el eRequest y retorna eResponse.
- Llama a los stored procedures vía DB::select.

## 6. Vue.js Component
- Página independiente `/rpt-pagos-contabilidad`.
- Formulario para seleccionar rango de fechas.
- Tabla de resultados con sumatoria general.
- Manejo de loading, error y validación.

## 7. Seguridad
- Validación de fechas en backend y frontend.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin afectar el frontend.

## 9. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.

## 10. Consideraciones de Migración
- El cálculo de la descripción del fondo se realiza vía JOIN con `ta_17_tipos`.
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página.
- El reporte es completamente funcional y exportable desde el frontend si se requiere.
