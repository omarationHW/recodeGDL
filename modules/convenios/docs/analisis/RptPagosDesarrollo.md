# Documentación Técnica: RptPagosDesarrollo (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo implementa la migración del formulario Delphi `RptPagosDesarrollo` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El reporte muestra los ingresos por fondo y año de obra pública en un rango de fechas.

---

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs
- **Base de Datos:** PostgreSQL, lógica de reporte en stored procedure `rpt_pagos_desarrollo`

---

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "action": "getReport",
      "params": {
        "fecdesde": "YYYY-MM-DD",
        "fechasta": "YYYY-MM-DD"
      }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        { "tipo": 15, "axo_obra": 2022, "ingreso": 12345.67, "descripcion": "RAMO 33" }, ... ]
    }
  }
  ```

---

## Stored Procedures
- **rpt_pagos_desarrollo(fecdesde, fechasta):** Devuelve el reporte agrupado por fondo y año de obra.
- **cat_fondos():** Devuelve catálogo de fondos para combos.

---

## Laravel Controller
- **Ruta:** `/api/execute` (registrar en `routes/api.php`)
- **Clase:** `RptPagosDesarrolloController`
- **Método principal:** `execute(Request $request)`
- **Acciones soportadas:**
  - `getReport`: Llama a `rpt_pagos_desarrollo(fecdesde, fechasta)`
  - `getFondos`: Llama a `cat_fondos()`

---

## Vue.js Component
- **Nombre:** `RptPagosDesarrolloPage.vue`
- **Características:**
  - Formulario de fechas (desde/hasta)
  - Tabla de resultados con totales
  - Manejo de loading, error, y mensajes vacíos
  - Navegación breadcrumb
  - Independiente, sin tabs

---

## Seguridad
- Validar que las fechas sean válidas y no nulas
- El endpoint puede protegerse con middleware de autenticación según la política del sistema

---

## Consideraciones de Migración
- El cálculo de la descripción del fondo se realiza vía JOIN a `ta_17_tipos`
- El frontend asume que el backend retorna los campos `tipo`, `axo_obra`, `ingreso`, `descripcion`
- El endpoint es genérico y puede extenderse para otros reportes

---

## Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba

---

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse
- Los stored procedures pueden ser reutilizados por otros módulos

---
