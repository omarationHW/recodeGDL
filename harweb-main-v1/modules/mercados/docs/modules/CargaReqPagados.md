# Documentación Técnica: CargaReqPagados

## Descripción General
El módulo **CargaReqPagados** permite cargar pagos realizados de requerimientos en el Mercado Libertad a partir de un archivo de texto plano, procesar los registros y actualizar la base de datos PostgreSQL, marcando los requerimientos como pagados y registrando los importes de multa y gastos asociados.

## Arquitectura
- **Frontend**: Vue.js SPA, página independiente para la carga de pagos.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de actualización encapsulada en stored procedure `sp_carga_req_pagados`.

## Flujo de Trabajo
1. **Carga de Archivo**: El usuario selecciona un archivo TXT con los pagos realizados.
2. **Parseo**: El frontend parsea el archivo y muestra los registros en una tabla.
3. **Procesamiento**: Al confirmar, los registros se envían al backend, que llama al stored procedure para cada folio de requerimiento.
4. **Totales**: Se muestran los totales de folios grabados, importe de multas y gastos.

## Formato del Archivo de Entrada
Cada línea del archivo representa un pago y tiene los siguientes campos (por posición):
- 0-5: Id Local
- 6-7: Día de pago
- 8-9: Mes de pago
- 10-13: Año de pago
- 14-16: Oficina
- 17: Caja
- 18-22: Operación
- 23-28: Folio
- 29-47: Fecha de actualización
- 48-50: Usuario
- 75-83: Importe Multa
- 84-92: Importe Gastos
- 93-242: Folios de requerimientos (separados por coma)

## API Backend
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: 'processPagos', data: { registros: [...] } } }`
- **Salida**: `{ eResponse: { status, data, errors } }`

## Stored Procedure
- **sp_carga_req_pagados**: Actualiza el requerimiento como pagado y registra los importes de multa y gastos.

## Seguridad
- El endpoint requiere autenticación (puede integrarse con Laravel Sanctum o JWT).
- Validación de datos en backend y frontend.

## Manejo de Errores
- Errores de archivo, parseo o base de datos se reportan en el campo `errors` de la respuesta.

## Extensibilidad
- El endpoint y stored procedure pueden ser reutilizados para otros módulos de carga masiva de pagos.

## Integración
- El componente Vue puede integrarse en cualquier SPA con Vue Router.
- El backend puede integrarse en cualquier API Laravel centralizada.
