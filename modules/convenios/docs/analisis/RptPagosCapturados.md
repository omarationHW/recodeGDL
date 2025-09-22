# Documentación Técnica: Migración de RptPagosCapturados (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de pagos capturados para la regularización de predios (RptPagosCapturados). Permite consultar, filtrar y visualizar los pagos realizados por subtipo de regularización, agrupados por manzana y lote, mostrando detalles como usuario, fecha, importes y claves asociadas.

## 2. Arquitectura
- **Backend:** Laravel (PHP) con un único endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Vue.js (SPA), cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL se implementa en stored procedures (SPs).
- **Comunicación:** API unificada, patrón eRequest/eResponse.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getPagosCapturados",
      "params": { "subtipo": 1 }
    }
  }
  ```
- **Salida:**
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
- **sp_rpt_pagos_capturados(subtipo)**: Devuelve el listado detallado de pagos capturados para el subtipo indicado.
- **sp_rpt_pagos_capturados_resumen(subtipo)**: Devuelve el resumen agrupado por manzana y lote.

## 5. Laravel Controller
- **Ruta:** `/api/execute` (Api\RptPagosCapturadosController@execute)
- **Métodos:**
  - `getPagosCapturados`: Llama al SP principal y retorna los datos.
  - `getPagosCapturadosResumen`: Llama al SP resumen.
- **Patrón:** eRequest/eResponse.

## 6. Vue.js Component
- **Ruta:** `/rpt-pagos-capturados`
- **Funcionalidad:**
  - Selección de subtipo (catálogo).
  - Consulta y despliegue de resultados en tabla.
  - Filtros y validaciones.
  - Breadcrumb de navegación.

## 7. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en eResponse.

## 8. Consideraciones
- El frontend espera los datos en el formato exacto retornado por el SP.
- El backend puede ser extendido para soportar exportación a Excel/PDF si se requiere.
- El SP puede ser optimizado para paginación si el volumen de datos lo requiere.

## 9. Migración de lógica Delphi
- Los campos calculados (letracomp, parcialidad) se implementan directamente en el SP.
- El reporte visual (QuickReport) se reemplaza por la tabla Vue.js y puede ser exportado desde el frontend si se requiere.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.
