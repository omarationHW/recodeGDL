# Casos de Uso - cvecatdupfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de claves catastrales duplicadas

**Descripción:** El usuario desea consultar todas las claves catastrales duplicadas registradas en el sistema.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla cvecatdup.

**Pasos a seguir:**
1. El usuario accede a la página de Claves Catastrales Duplicadas.
2. No ingresa ningún filtro y presiona 'Buscar'.
3. El sistema muestra la lista completa de registros.

**Resultado esperado:**
Se muestra una tabla con todas las claves catastrales duplicadas existentes.

**Datos de prueba:**
Tabla cvecatdup con al menos 2 registros.

---

## Caso de Uso 2: Agregar una clave catastral duplicada

**Descripción:** El usuario necesita registrar una nueva clave catastral duplicada.

**Precondiciones:**
El usuario tiene acceso a la página y conoce los datos de la clave a registrar.

**Pasos a seguir:**
1. El usuario hace clic en 'Agregar'.
2. Completa los campos: Recaudadora=5, U/R='U', Cuenta=123456, Clave Catastral='D6512345678'.
3. Presiona 'Agregar'.
4. El sistema confirma el registro y actualiza la tabla.

**Resultado esperado:**
El nuevo registro aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ recaud: 5, urbrus: 'U', cuenta: 123456, cvecatnva: 'D6512345678' }

---

## Caso de Uso 3: Eliminar una clave catastral duplicada

**Descripción:** El usuario elimina un registro de clave catastral duplicada existente.

**Precondiciones:**
Existe al menos un registro en la tabla cvecatdup.

**Pasos a seguir:**
1. El usuario localiza el registro a eliminar en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la acción.
4. El sistema elimina el registro y actualiza la tabla.

**Resultado esperado:**
El registro desaparece de la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
Registro existente: { recaud: 5, urbrus: 'U', cuenta: 123456, cvecatnva: 'D6512345678' }

---

