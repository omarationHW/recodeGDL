# Casos de Uso - SubTipoMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo SubTipo

**Descripción:** El usuario desea agregar un nuevo SubTipo para un Tipo existente.

**Precondiciones:**
El usuario tiene permisos y conoce el Tipo y la cuenta de ingreso.

**Pasos a seguir:**
1. Accede a la página de SubTipos.
2. Da clic en 'Agregar'.
3. Llena los campos: Tipo, SubTipo, Descripción, Cuenta Ingreso.
4. Da clic en 'Agregar'.

**Resultado esperado:**
El nuevo SubTipo se agrega y aparece en el listado.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 2, "desc_subtipo": "SUBTIPO TEST", "cuenta_ingreso": 12345, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de un SubTipo existente

**Descripción:** El usuario edita la descripción y cuenta de ingreso de un SubTipo.

**Precondiciones:**
El SubTipo existe.

**Pasos a seguir:**
1. Accede a la página de SubTipos.
2. Da clic en 'Editar' en el registro deseado.
3. Modifica la descripción y/o cuenta.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
El SubTipo se actualiza correctamente.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 2, "desc_subtipo": "SUBTIPO MODIFICADO", "cuenta_ingreso": 54321, "id_usuario": 1 }

---

## Caso de Uso 3: Validación de duplicados al crear

**Descripción:** El usuario intenta crear un SubTipo con tipo y subtipo ya existentes.

**Precondiciones:**
Ya existe un registro con ese tipo y subtipo.

**Pasos a seguir:**
1. Accede a la página de SubTipos.
2. Intenta agregar un SubTipo con tipo y subtipo duplicados.
3. Da clic en 'Agregar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando duplicidad.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 2, "desc_subtipo": "DUPLICADO", "cuenta_ingreso": 11111, "id_usuario": 1 }

---

