# Documentación Técnica: Migración de Formulario RptPagosContratosDecsDev

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `RptPagosContratosDecsDev` a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Base de Datos). El objetivo es listar los contratos que han realizado pagos con descuento, filtrados por colonia.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute`.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "RptPagosContratosDecsDev",
    "params": {
      "colonia": <int>
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **Nombre:** `rpt_pagos_contratos_descs_dev`
- **Parámetro:** `p_colonia` (integer)
- **Retorna:** Tabla con los campos requeridos para el reporte.
- **Lógica:** Replica el query original Delphi, filtrando por colonia y pagos con descuento.

## 5. Frontend (Vue.js)
- Página independiente con formulario para ingresar la colonia.
- Al enviar, consulta la API y muestra los resultados en tabla.
- Incluye totales y formato de moneda.
- Breadcrumb para navegación.

## 6. Backend (Laravel)
- Controlador único (`ExecuteController`) que recibe el `eRequest` y parámetros.
- Llama al stored procedure correspondiente y retorna los datos en formato JSON.
- Manejo de errores y validaciones básicas.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede ser protegido con middleware de autenticación según necesidades del proyecto.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos formularios y reportes reutilizando el mismo endpoint.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12.x

---
