# Casos de Uso - regHfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de registros históricos de una cuenta

**Descripción:** El usuario desea ver todos los movimientos históricos asociados a una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Ingresa el número de cuenta catastral (por ejemplo, 12345).
3. El sistema envía un eRequest 'get_historic_records' con el parámetro cvecuenta.
4. El backend responde con la lista de registros históricos.

**Resultado esperado:**
Se muestra una tabla con los registros históricos (año, número de comprobante) de la cuenta indicada.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 2: Alta de un nuevo registro histórico

**Descripción:** El usuario agrega un nuevo registro histórico para una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos de escritura.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Hace clic en 'Nuevo Registro Histórico'.
3. Llena los campos Año, No. Comp., Clave Cuenta.
4. Envía el formulario.
5. El sistema envía un eRequest 'create_historic_record' con los datos.
6. El backend inserta el registro y responde con éxito.

**Resultado esperado:**
El nuevo registro aparece en la tabla de registros históricos.

**Datos de prueba:**
{ "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }

---

## Caso de Uso 3: Eliminación de un registro histórico

**Descripción:** El usuario elimina un registro histórico existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Ubica el registro a eliminar en la tabla.
3. Hace clic en 'Eliminar'.
4. El sistema solicita confirmación.
5. El usuario confirma.
6. El sistema envía un eRequest 'delete_historic_record' con los identificadores.
7. El backend elimina el registro y responde con éxito.

**Resultado esperado:**
El registro ya no aparece en la tabla.

**Datos de prueba:**
{ "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }

---

