# Documentación Técnica: Migración Formulario constpat400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la consulta de pagos y transmisiones patrimoniales del sistema AS400, migrando la funcionalidad Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Base de datos).

## 2. Arquitectura
- **Backend:** Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "consultarPagosTransmisionesPatrimoniales", // o "consultarTransmisionesPatrimoniales"
    "params": {
      "fecha": 20240101,
      "recaud": 1,
      "operacion": 12345,
      "caja": "A"
    }
  }
  ```
- **Response:**
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
- **consultar_pagos_transmisiones_patrimoniales**: Consulta pagos en `pagotransm_400` con filtros.
- **consultar_transmisiones_patrimoniales**: Consulta transmisiones en `transm_400` con filtros.

## 5. Frontend (Vue.js)
- Página independiente con formulario de filtros (fecha, recaudadora, caja, operación).
- Botón Buscar ejecuta ambas consultas vía API.
- Resultados mostrados en dos tablas (pagos y transmisiones).
- Mensaje de advertencia si no hay resultados.
- Navegación breadcrumb incluida.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes `/api/execute`.
- Llama a los stored procedures según el valor de `eRequest`.
- Devuelve respuesta estructurada en `eResponse`.

## 7. Seguridad
- Validación básica de parámetros.
- Uso de parámetros preparados en consultas para evitar SQL Injection.

## 8. Consideraciones
- Los filtros son opcionales; si no se envía un filtro, no se aplica.
- El frontend muestra los resultados en tablas responsivas.
- El endpoint es extensible para otros formularios/futuros eRequests.

## 9. Requisitos de Infraestructura
- Laravel 9+
- Vue.js 2/3 (compatible con router)
- PostgreSQL 12+

## 10. Pruebas
- Casos de uso y escenarios de prueba incluidos para validación funcional y de integración.
