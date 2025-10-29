# Documentación Técnica - Migración Formulario Traslados (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (todas las operaciones críticas en stored procedures)
- **Patrón API**: eRequest/eResponse (todas las acciones viajan por un solo endpoint, con campo `action` y `payload`)

## 2. Flujo de la Página de Traslados
1. **Carga inicial**: El frontend solicita la lista de cementerios (`listarCementerios`).
2. **Verificación Origen**: El usuario ingresa los datos de la ubicación origen y presiona "Verificar Origen". Se llama a `buscarPagosOrigen`.
3. **Verificación Destino**: Si hay pagos en origen, el usuario ingresa los datos de la ubicación destino y presiona "Verificar Destino". Se llama a `buscarPagosDestino`.
4. **Traslado**: Si hay pagos en destino, el usuario presiona "Trasladar Pagos". Se llama a `trasladarPagos`.
5. **Mensajes**: El frontend muestra mensajes de éxito o error según la respuesta del backend.

## 3. API Backend
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "action": "buscarPagosOrigen", // o buscarPagosDestino, trasladarPagos, listarCementerios
    "payload": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 4. Stored Procedures
- Toda la lógica de negocio (búsqueda, traslado, actualización) se realiza en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SP y retorna el resultado.

## 5. Seguridad
- El usuario autenticado se obtiene vía JWT/session en Laravel y se pasa como parámetro a los SP para auditoría.
- Validaciones de datos en frontend y backend.

## 6. Manejo de Errores
- Los SP retornan un campo `success` y `message` para que el frontend pueda mostrar mensajes claros.
- El controlador Laravel captura excepciones y las retorna en el campo `message`.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los formularios pueden ser migrados uno a uno, cada uno como página Vue independiente.

## 8. Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para pruebas de frontend.

## 9. Consideraciones de Integridad
- El traslado de pagos es transaccional: si alguna actualización falla, se revierte todo.
- Los SP pueden ser extendidos para auditar movimientos si se requiere.

## 10. Migración de Datos
- Los nombres de tablas y campos se mantienen para compatibilidad.
- Se recomienda revisar tipos de datos y constraints en PostgreSQL.
