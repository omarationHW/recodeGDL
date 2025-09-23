# Casos de Uso - ModifConvDiversos

**Categoría:** Form

## Caso de Uso 1: Modificar datos generales de un convenio vigente

**Descripción:** El usuario necesita actualizar el nombre, domicilio y teléfono de un convenio vigente.

**Precondiciones:**
El usuario tiene permisos de modificación y el convenio no está bloqueado ni dado de baja.

**Pasos a seguir:**
1. El usuario ingresa a la página de Modificación de Convenios Diversos.
2. Selecciona el tipo y subtipo del convenio.
3. Ingresa letras, folio y año de oficio y presiona 'Buscar Convenio'.
4. El sistema muestra los datos actuales.
5. El usuario edita los campos requeridos (nombre, domicilio, teléfono).
6. Presiona 'Modificar Datos Generales'.
7. El sistema actualiza los datos y muestra mensaje de éxito.

**Resultado esperado:**
Los datos generales del convenio se actualizan correctamente en la base de datos.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 2, "letras_ofi": "ZC1", "folio_ofi": 123, "alo_oficio": 2024, "nombre": "JUAN PEREZ", "calle": "AV. JUAREZ", "telefono": "3312345678" }

---

## Caso de Uso 2: Bloquear convenio por falta de pago

**Descripción:** El usuario con permisos de jurídico bloquea un convenio vigente por falta de pago.

**Precondiciones:**
El usuario tiene permisos de bloqueo y el convenio está vigente y no bloqueado.

**Pasos a seguir:**
1. El usuario busca el convenio como en el caso anterior.
2. Presiona 'Bloquear Convenio'.
3. El sistema ejecuta el SP de bloqueo y muestra mensaje de éxito.

**Resultado esperado:**
El campo 'bloqueo' del convenio se actualiza a 1 y no se pueden modificar datos generales hasta ser desbloqueado.

**Datos de prueba:**
{ "id_conv_resto": 123, "observaciones": "Bloqueo por falta de pago" }

---

## Caso de Uso 3: Dar de baja un convenio pagado

**Descripción:** El usuario da de baja un convenio que ya fue pagado en su totalidad.

**Precondiciones:**
El usuario tiene permisos y el convenio está marcado como pagado.

**Pasos a seguir:**
1. El usuario busca el convenio.
2. Presiona 'Dar de Baja'.
3. El sistema ejecuta el SP de baja y muestra mensaje de éxito.

**Resultado esperado:**
El campo 'vigencia' del convenio se actualiza a 'B' (baja).

**Datos de prueba:**
{ "id_conv_resto": 123, "modulo": 5 }

---

