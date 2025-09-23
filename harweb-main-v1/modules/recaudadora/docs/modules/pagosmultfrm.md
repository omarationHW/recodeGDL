# Documentación Técnica: Migración de Formulario pagosmultfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta de pagos de multas, filtrando por fecha, recaudadora, caja, folio, nombre del contribuyente o número de acta. Permite visualizar el detalle de cada multa, incluyendo información de descuentos, estatus y datos relacionados.

## 2. Arquitectura
- **Frontend:** Vue.js (Single Page Component, ruta independiente)
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Comunicación:** El frontend envía un objeto `eRequest` y `params` al endpoint `/api/execute`. El backend ejecuta el stored procedure correspondiente y retorna la respuesta en `eResponse`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "pagosmultfrm.searchPagosMultas",
    "params": {
      "fecha": "2024-06-01",
      "recaud": "1",
      "caja": "A",
      "folio": "123",
      "nombre": "JUAN",
      "num_acta": "456"
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
Toda la lógica de consulta y cálculo reside en funciones de PostgreSQL (ver sección `stored_procedures`).

## 5. Flujo de la Aplicación
1. El usuario ingresa criterios de búsqueda y presiona "Buscar".
2. El frontend envía la petición a `/api/execute` con `eRequest: pagosmultfrm.searchPagosMultas`.
3. El backend ejecuta el SP correspondiente y retorna los pagos encontrados.
4. El usuario puede seleccionar un pago para ver el detalle de la multa, que se obtiene mediante otro SP.
5. Los descuentos y datos relacionados se consultan con SPs adicionales.

## 6. Seguridad
- Validación de parámetros en el backend.
- Uso de funciones parametrizadas para evitar SQL Injection.

## 7. Consideraciones de Migración
- Los campos calculados (estatus, descuento) se calculan en el SP de detalle.
- Los combos y lookups de Delphi se resuelven mediante joins en los SPs.
- El frontend es completamente independiente y no usa tabs.

## 8. Extensibilidad
- Para agregar nuevos filtros o columnas, modificar el SP y el frontend.
- Para agregar nuevas operaciones, definir un nuevo `eRequest` y SP.

## 9. Dependencias
- Laravel >= 9.x
- Vue.js >= 3.x
- PostgreSQL >= 12

## 10. Ejemplo de Integración
Ver sección de casos de uso y pruebas.
