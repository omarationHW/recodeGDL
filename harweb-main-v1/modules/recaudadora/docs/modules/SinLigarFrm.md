# Documentación Técnica: Migración Formulario SinLigarFrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el listado de pagos de transmisiones patrimoniales sin ligar a cuenta predial, permitiendo la consulta por rango de fechas. La solución está compuesta por:
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedure en PostgreSQL para la lógica de consulta.

## 2. Arquitectura
- **API Unificada**: Todas las operaciones se ejecutan vía POST `/api/execute` con un objeto `eRequest` que define la operación y parámetros. La respuesta se entrega en `eResponse`.
- **Stored Procedure**: Toda la lógica SQL reside en el SP `report_sinligar_pagos`.
- **Vue.js**: Página independiente, sin tabs, con navegación breadcrumb y tabla de resultados.

## 3. Flujo de Datos
1. El usuario accede a la página de "Pagos Transmisiones Sin Ligar".
2. Selecciona el rango de fechas y envía la consulta.
3. El frontend envía un POST a `/api/execute` con `operation: getSinLigarPagos` y los parámetros de fecha.
4. El backend ejecuta el SP `report_sinligar_pagos(fecha1, fecha2)` y retorna los resultados.
5. El frontend muestra los resultados en una tabla.

## 4. API eRequest/eResponse
- **Request**:
  ```json
  {
    "eRequest": {
      "operation": "getSinLigarPagos",
      "params": {
        "fecha1": "YYYY-MM-DD",
        "fecha2": "YYYY-MM-DD"
      }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## 5. Stored Procedure
- **Nombre**: `report_sinligar_pagos`
- **Parámetros**: `fecha1` (DATE), `fecha2` (DATE)
- **Retorna**: Todos los campos requeridos para el reporte.
- **Lógica**: Replica el query Delphi, usando JOIN y LEFT JOIN para obtener los datos de pagos, auditoria y pago_diversos.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej. JWT, Sanctum) en producción.
- Validar los parámetros de entrada en el controlador.

## 7. Consideraciones de Migración
- El frontend NO usa tabs ni componentes tabulares, cada formulario es una página independiente.
- El SP debe estar versionado y documentado en el repositorio de base de datos.
- El controlador Laravel es genérico y puede extenderse para otras operaciones.

## 8. Extensibilidad
- Para agregar nuevas operaciones, implementar el SP correspondiente y agregar el case en el controlador.
- El frontend puede extenderse para exportar a PDF/Excel si se requiere.

## 9. Dependencias
- Laravel >= 8.x
- PostgreSQL >= 12
- Vue.js >= 2.x o 3.x
- Bootstrap (opcional, para estilos)

## 10. Ejemplo de Uso
- Acceder a `/sinligar-pagos` en el frontend.
- Seleccionar fechas y consultar.
- Visualizar resultados en tabla.

---
