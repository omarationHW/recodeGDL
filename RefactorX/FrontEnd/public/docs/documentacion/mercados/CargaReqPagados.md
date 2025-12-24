# CargaReqPagados

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - CargaReqPagados

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos de Requerimientos

**Descripción:** El usuario carga un archivo TXT con los pagos realizados en el Mercado Libertad y actualiza los requerimientos como pagados.

**Precondiciones:**
El usuario tiene acceso al sistema y cuenta con el archivo TXT generado por el área de recaudación.

**Pasos a seguir:**
1. El usuario accede a la página 'Carga de Pagos Realizados en Mdo. Libertad'.
2. Selecciona el archivo TXT desde su equipo.
3. Visualiza la tabla con los registros parseados.
4. Da clic en 'Actualizar Pagos'.
5. El sistema procesa los registros y muestra los totales de folios grabados, multa y gastos.

**Resultado esperado:**
Los requerimientos correspondientes quedan marcados como pagados en la base de datos. Se muestran los totales correctamente.

**Datos de prueba:**
Archivo TXT con 3 líneas, cada una con folios de requerimientos distintos.

---

## Caso de Uso 2: Carga con Errores en el Archivo

**Descripción:** El usuario intenta cargar un archivo TXT con líneas mal formateadas o con folios inexistentes.

**Precondiciones:**
El usuario tiene acceso y un archivo con errores de formato o folios no existentes.

**Pasos a seguir:**
1. El usuario selecciona el archivo con errores.
2. El sistema parsea y muestra los registros.
3. Al procesar, el backend detecta errores y los reporta en la respuesta.

**Resultado esperado:**
El sistema muestra mensajes de error indicando las líneas o folios problemáticos. No se actualizan registros erróneos.

**Datos de prueba:**
Archivo TXT con una línea con folio inexistente y otra con campos vacíos.

---

## Caso de Uso 3: Consulta de Totales de Última Carga

**Descripción:** El usuario consulta los totales de la última carga de pagos realizada.

**Precondiciones:**
Se ha realizado al menos una carga de pagos.

**Pasos a seguir:**
1. El usuario accede a la página y realiza una carga.
2. Da clic en 'Actualizar Pagos'.
3. El sistema muestra los totales de la carga.

**Resultado esperado:**
Se muestran correctamente los totales de folios grabados, importe de multas y gastos.

**Datos de prueba:**
Archivo TXT con 5 registros válidos.

---



## Casos de Prueba

# Casos de Prueba para CargaReqPagados

## Caso 1: Carga exitosa de pagos
- **Entrada**: Archivo TXT con 3 líneas válidas, cada una con folios de requerimientos existentes.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=ok, grabados=3, importe_multa y importe_gastos sumados correctamente, sin errores.

## Caso 2: Archivo con folio inexistente
- **Entrada**: Archivo TXT con una línea cuyo folio de requerimiento no existe en la base de datos.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error indicando el folio inexistente, no se actualiza ese registro.

## Caso 3: Archivo con campos vacíos
- **Entrada**: Archivo TXT con una línea donde el campo 'id_local' o 'folio' está vacío.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error de validación, no se procesa ese registro.

## Caso 4: Archivo con formato incorrecto
- **Entrada**: Archivo TXT con líneas de longitud menor a la esperada.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error de parseo, no se procesa ese registro.

## Caso 5: Consulta de totales después de carga
- **Entrada**: Realizar una carga válida y luego consultar los totales.
- **Acción**: Llamar a getTotals con los datos de la última carga.
- **Resultado esperado**: status=ok, totales coinciden con los datos procesados.



