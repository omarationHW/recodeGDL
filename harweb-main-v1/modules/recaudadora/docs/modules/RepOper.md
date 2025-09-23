# Documentación Técnica: Migración Formulario RepOper (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de "Listado de Operaciones por Caja" (RepOper) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo consultar totales y desgloses de operaciones por fecha, recaudadora y caja.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getTotalesOperaciones", // o "getDesgloseOperaciones", "getCajasByFechaRecaud"
      "params": {
        "fecha": "2024-06-01",
        "recaud": "1",
        "caja": "A"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": { ... },
      "error": null
    }
  }
  ```

## 4. Stored Procedures
- **repoper_totales:** Devuelve los totales de operaciones (canceladas, cheques, doc cero, totales, puro efectivo, etc.)
- **repoper_desglose:** Devuelve el listado detallado de operaciones para la selección dada.

## 5. Flujo de la Interfaz
1. Usuario selecciona fecha y recaudadora.
2. El sistema carga las cajas disponibles para esa fecha y recaudadora.
3. Usuario selecciona caja y elige entre "Totales" o "Desglose".
4. El sistema consulta el API y muestra los resultados en tablas.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de consultas parametrizadas para evitar SQL Injection.

## 7. Consideraciones
- Los nombres de campos y lógica se mantienen fieles al sistema original.
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.
- El backend es extensible para otras operaciones bajo el mismo endpoint.

## 8. Extensión
- Se pueden agregar más operaciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.

## 9. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+

## 10. Pruebas
- Incluye casos de uso y escenarios de prueba para QA.
