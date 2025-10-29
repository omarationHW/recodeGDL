# Documentación Técnica: Migración de Formulario LigaPago (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "LigaPago" permite ligar un pago existente (de la tabla `pagos`) a un folio de requerimiento predial, transmisión patrimonial o diferencia de transmisión. El proceso incluye validaciones de estado de cuenta (exento/cancelada), selección de pago, y actualización de la relación en la base de datos.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `listPagos`: Lista pagos de una cuenta
  - `getPagoDetalle`: Detalle de un pago
  - `ligarPago`: Liga pago a requerimiento/transmisión
  - `ligarPagoDiferencia`: Liga pago a diferencia de transmisión
  - `getCuentaStatus`: Estado de cuenta (exento/vigente)

## 4. Validaciones
- No se permite ligar pagos a cuentas exentas o canceladas
- El folio de transmisión/diferencia debe existir y estar pendiente de pago
- El usuario debe ser proporcionado

## 5. Stored Procedures
- Toda la lógica de actualización reside en stored procedures PostgreSQL:
  - `sp_ligar_pago`: Liga pago a requerimiento predial o transmisión
  - `sp_ligar_pago_diferencia`: Liga pago a diferencia de transmisión

## 6. Frontend (Vue.js)
- Página independiente con navegación breadcrumb
- Selección de cuenta, visualización de pagos, selección de pago, formulario de liga
- Validaciones visuales y mensajes de error
- Llamadas a `/api/execute` para todas las operaciones

## 7. Seguridad
- Validación de usuario en backend
- Validación de parámetros en backend y frontend

## 8. Consideraciones de Integración
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema
- El frontend puede ser integrado en un router Vue.js como página independiente

## 9. Migración de Lógica Delphi
- El evento `DBEdit1Change` y validaciones de exento/vigente se trasladan a validaciones en backend y frontend
- El grid de pagos y navegación se implementa como tabla en Vue.js
- La lógica de actualización de pagos se implementa en stored procedures

## 10. Ejemplo de Request/Response
### Request
```json
{
  "action": "ligarPago",
  "params": {
    "cvepago": 12345,
    "cvecuenta": 67890,
    "usuario": "juan",
    "tipo": 2,
    "folio": null,
    "fecha": "2024-06-01"
  }
}
```
### Response
```json
{
  "success": true,
  "data": [ { "result": "Pago ligado a requerimiento predial" } ],
  "message": ""
}
```
