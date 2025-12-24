# Documentación: ConsTPat400

## Análisis Técnico

# Documentación Técnica: Migración de Formulario ConsTPat400 a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la consulta de pagos de transmisiones patrimoniales (TPat400) originalmente en Delphi, migrado a una arquitectura moderna con Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos). Toda la lógica de consulta se encapsula en stored procedures y se expone mediante un endpoint API unificado siguiendo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint único `/api/execute`.
- **Base de Datos**: PostgreSQL, lógica de consulta en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "consultarPagosTPat400", // o 'consultarDetalleTPat400'
    "params": {
      "fecha": 20240101,
      "recaud": 1,
      "caja": "A",
      "operacion": 123
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- `sp_consultar_pagos_tpat400`: Consulta pagos en `pagotransm_400` según filtros.
- `sp_consultar_detalle_tpat400`: Consulta detalle en `transm_400` según filtros.

## 5. Flujo de la Aplicación
1. El usuario ingresa filtros (fecha, recaudadora, caja, operación) y presiona Buscar.
2. El frontend envía la petición a `/api/execute` con `eRequest: consultarPagosTPat400`.
3. El backend ejecuta el stored procedure y retorna los resultados.
4. El usuario puede ver el detalle de cada pago, lo que dispara otra petición con `eRequest: consultarDetalleTPat400`.

## 6. Validaciones
- La fecha es obligatoria.
- Los demás filtros son opcionales.
- Si no hay resultados, se muestra mensaje informativo.

## 7. Seguridad
- El endpoint debe protegerse con autenticación (no incluida aquí).
- Los parámetros se validan y se usan en stored procedures para evitar SQL Injection.

## 8. Consideraciones
- El frontend es completamente independiente y funcional como página.
- El backend puede extenderse para otros formularios usando el mismo patrón.

## 9. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12

## 10. Extensibilidad
- Se pueden agregar más eRequest en el mismo endpoint para otros formularios.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

