# Casos de Uso - ElaboroMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nuevo registro de Elaboro Oficio

**Descripción:** Un usuario con permisos desea registrar una nueva relación de recaudadora, titular y elabora para convenios.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. Ingresa a la página de Elaboro Oficio.
2. Llena los campos: Recaudadora, ID Usuario Titular, Iniciales Titular, ID Usuario Elabora, Iniciales Elabora.
3. Presiona 'Crear'.

**Resultado esperado:**
El registro se guarda en la base de datos y aparece en la tabla de registros.

**Datos de prueba:**
{ "id_rec": 2, "id_usu_titular": 15, "iniciales_titular": "JLO", "id_usu_elaboro": 18, "iniciales_elaboro": "MRO" }

---

## Caso de Uso 2: Consulta de información de titular y elabora

**Descripción:** El usuario ingresa los IDs y desea ver los nombres completos asociados.

**Precondiciones:**
Existen usuarios activos con los IDs proporcionados.

**Pasos a seguir:**
1. Ingresa los campos: Recaudadora, ID Usuario Titular, ID Usuario Elabora.
2. Sale del campo (blur) o presiona fuera.

**Resultado esperado:**
Se muestran los nombres completos de titular y elabora, así como la recaudadora.

**Datos de prueba:**
{ "id_rec": 2, "id_usu_titular": 15, "id_usu_elaboro": 18 }

---

## Caso de Uso 3: Edición de registro existente

**Descripción:** El usuario desea modificar las iniciales del titular y elabora de un registro existente.

**Precondiciones:**
Existe un registro con id_control=5.

**Pasos a seguir:**
1. Selecciona el registro en la tabla.
2. Modifica los campos Iniciales Titular y/o Iniciales Elabora.
3. Presiona 'Actualizar'.

**Resultado esperado:**
El registro se actualiza correctamente y los cambios se reflejan en la tabla.

**Datos de prueba:**
{ "id_control": 5, "id_rec": 2, "id_usu_titular": 15, "iniciales_titular": "JLOX", "id_usu_elaboro": 18, "iniciales_elaboro": "MROX" }

---

