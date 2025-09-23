# Documentación Técnica: Migración Formulario ListAna (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Listado Analítico del Ingreso Diario" (ListAna) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo seleccionar fecha, recaudadora y caja, y generar un reporte analítico de ingresos diarios.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getCajasByFechaRecaud", // o getTotImp, getMinFolio, getMaxFolio, getPagosDetalle
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
Toda la lógica de consulta se implementa como funciones en PostgreSQL:
- `sp_get_cajas_by_fecha_recaud(fecha, recaud)`
- `sp_get_tot_imp(fecha, caja, recaud)`
- `sp_get_min_folio(fecha, caja, recaud)`
- `sp_get_max_folio(fecha, caja, recaud)`
- `sp_get_pagos_detalle(fecha, caja, recaud)`

## 5. Flujo de la Página Vue.js
1. Al cargar la página, se selecciona la fecha actual y la primera recaudadora.
2. Al cambiar fecha o recaudadora, se consulta la lista de cajas disponibles.
3. Al seleccionar "Imprimir", se consultan los totales, folios y detalle de pagos.
4. El reporte se muestra en pantalla (no imprime físicamente, pero puede exportarse o imprimirse desde el navegador).

## 6. Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint `/api/execute` puede protegerse con middleware de autenticación según la política del sistema.

## 7. Consideraciones de Migración
- Los combos de recaudadora y caja se mantienen como en Delphi.
- El reporte se muestra en tabla HTML, no como reporte impreso.
- El frontend es completamente independiente y funcional por sí solo.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Dependencias
- Laravel 9+
- Vue.js 2/3 (compatible)
- PostgreSQL 12+

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba para ejemplos y validaciones.
