# Documentación: ligapago

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - ligapago

**Categoría:** Form

## Caso de Uso 1: Ligar pago a requerimiento predial

**Descripción:** Un usuario selecciona una cuenta catastral, elige un pago disponible y lo liga a un folio de requerimiento predial pendiente.

**Precondiciones:**
La cuenta debe estar vigente y no exenta. Debe existir al menos un pago pendiente de ligar.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral.
2. El sistema muestra los pagos disponibles.
3. El usuario selecciona un pago y elige 'Ligar'.
4. El usuario confirma los datos y envía el formulario.
5. El sistema valida el estado de la cuenta y ejecuta el stored procedure.

**Resultado esperado:**
El pago queda ligado al folio de requerimiento predial y se actualiza la base de datos.

**Datos de prueba:**
{ "cvecuenta": 1001, "cvepago": 2001, "usuario": "admin", "tipo": 2 }

---

## Caso de Uso 2: Ligar pago a folio de transmisión patrimonial

**Descripción:** Un usuario liga un pago a un folio de transmisión patrimonial existente.

**Precondiciones:**
La cuenta debe estar vigente y no exenta. El folio de transmisión debe existir y estar pendiente de pago.

**Pasos a seguir:**
1. El usuario ingresa la cuenta catastral.
2. El sistema muestra los pagos disponibles.
3. El usuario selecciona un pago y elige 'Ligar'.
4. El usuario selecciona el tipo 'Transmisión Patrimonial' y proporciona el folio de transmisión.
5. El usuario confirma y envía el formulario.
6. El sistema ejecuta el stored procedure correspondiente.

**Resultado esperado:**
El pago queda ligado al folio de transmisión patrimonial.

**Datos de prueba:**
{ "cvecuenta": 1002, "cvepago": 2002, "usuario": "admin", "tipo": 22, "folio": 3001 }

---

## Caso de Uso 3: Intento de ligar pago a cuenta exenta

**Descripción:** El usuario intenta ligar un pago a una cuenta marcada como exenta.

**Precondiciones:**
La cuenta debe tener el campo exento = 'S'.

**Pasos a seguir:**
1. El usuario ingresa la cuenta catastral exenta.
2. El sistema muestra mensaje de error y no permite continuar.

**Resultado esperado:**
El sistema rechaza la operación y muestra el mensaje 'Cuenta exenta. No puede usar esta opción'.

**Datos de prueba:**
{ "cvecuenta": 9999, "cvepago": 8888, "usuario": "admin", "tipo": 2 }

---

## Casos de Prueba

# Casos de Prueba LigaPago

## Caso 1: Ligar pago a requerimiento predial
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Ligar pago
- Verificar que el pago queda ligado en la base de datos (campo cvepago actualizado en reqpredial)

## Caso 2: Ligar pago a transmisión patrimonial
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Seleccionar tipo 'Transmisión Patrimonial' y folio válido
- Ligar pago
- Verificar que el pago queda ligado en la tabla transmisión

## Caso 3: Ligar pago a diferencia de transmisión
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Seleccionar tipo 'Diferencia Transmisión' y folio válido
- Ligar pago
- Verificar que el pago queda ligado en la tabla diferencias

## Caso 4: Intentar ligar pago a cuenta exenta
- Ingresar cuenta catastral exenta
- Verificar que el sistema muestra mensaje de error y no permite continuar

## Caso 5: Intentar ligar pago a cuenta cancelada
- Ingresar cuenta catastral cancelada
- Verificar que el sistema muestra mensaje de error y no permite continuar

## Caso 6: Ligar pago con usuario vacío
- Intentar ligar pago sin proporcionar usuario
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## Caso 7: Ligar pago con folio de transmisión inexistente
- Ingresar folio de transmisión inválido
- Verificar que el sistema muestra mensaje de error

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

