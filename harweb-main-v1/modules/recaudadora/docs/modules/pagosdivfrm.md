# Documentación Técnica: Migración de Formulario pagosdivfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta de pagos diversos (cveconcepto=4) con filtros por fecha, recaudadora, caja, folio y nombre del contribuyente. Incluye la visualización de detalles del pago, aplicaciones (auditoría) y cancelaciones.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de búsqueda encapsulada en stored procedures.

## 3. Endpoints API
### POST /api/execute
- **Request:**
  - `action`: Acción a ejecutar (`buscar_pagos_diversos`, `detalle_pago_diverso`)
  - `params`: Parámetros de la acción
- **Response:**
  - `success`: true/false
  - `data`: Datos resultantes
  - `message`: Mensaje de error o información

#### Acciones soportadas
- `buscar_pagos_diversos`: Busca pagos diversos según filtros.
- `detalle_pago_diverso`: Devuelve detalles de un pago (diversos, auditoría, cancelación).

## 4. Stored Procedures
- **pagosdiv_buscar**: Devuelve pagos diversos según filtros. Implementa la lógica de búsqueda dinámica.

## 5. Frontend (Vue.js)
- Formulario de búsqueda con validación de números.
- Tabla de resultados.
- Vista de detalle con información de contribuyente, concepto, aplicaciones y cancelación.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de procedimientos almacenados para evitar SQL Injection.

## 7. Consideraciones
- El endpoint es único y recibe la acción a ejecutar.
- El frontend es desacoplado y consume la API vía fetch/AJAX.
- El stored procedure permite filtros opcionales.

## 8. Tablas involucradas
- `pagos`: Recibos de pagos diversos.
- `pago_diversos`: Detalle de contribuyente y concepto.
- `auditoria`: Aplicación de pagos.
- `pagoscan`: Cancelaciones.

## 9. Validaciones
- Los campos recaud y folio sólo aceptan números.
- Todos los filtros son opcionales.

## 10. Extensibilidad
- Para agregar nuevas acciones, implementar en el controlador y/o nuevos stored procedures.

---
