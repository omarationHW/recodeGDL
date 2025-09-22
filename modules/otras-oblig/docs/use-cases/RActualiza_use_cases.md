# Casos de Uso - RActualiza

**Categoría:** Form

## Caso de Uso 1: Actualización de Concesionario

**Descripción:** El usuario necesita actualizar el nombre del concesionario de un local.

**Precondiciones:**
El usuario conoce el número y letra del local. El local existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa el número y letra del local y presiona Buscar.
2. El sistema muestra los datos actuales del local.
3. El usuario selecciona 'Concesionario' como tipo de actualización.
4. El usuario ingresa el nuevo nombre del concesionario.
5. El usuario presiona 'Aplicar Cambio'.
6. El sistema valida que el nuevo nombre sea diferente al anterior y realiza la actualización.

**Resultado esperado:**
El sistema muestra un mensaje de éxito y el concesionario queda actualizado.

**Datos de prueba:**
{ "numero": "123", "letra": "A", "concesionario": "Nuevo Concesionario S.A." }

---

## Caso de Uso 2: Cambio de Superficie con Validación de Pagos

**Descripción:** El usuario desea modificar la superficie de un local, pero debe validar que no existan pagos posteriores.

**Precondiciones:**
El local existe y no tiene pagos realizados a partir del periodo indicado.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona 'Superficie' como tipo de actualización.
3. Ingresa la nueva superficie, año y mes de inicio.
4. El sistema verifica que no existan pagos posteriores a ese periodo.
5. Si no hay pagos, realiza la actualización.

**Resultado esperado:**
La superficie se actualiza correctamente si no hay pagos posteriores.

**Datos de prueba:**
{ "numero": "456", "letra": "B", "superficie": "50.00", "aso_ini": "2023", "mes_ini": "05" }

---

## Caso de Uso 3: Intento de Actualización con Datos Iguales

**Descripción:** El usuario intenta actualizar un dato (ej. concesionario) con el mismo valor actual.

**Precondiciones:**
El local existe y el dato a actualizar es igual al actual.

**Pasos a seguir:**
1. El usuario busca el local.
2. Selecciona 'Concesionario' como tipo de actualización.
3. Ingresa el mismo nombre de concesionario que ya tiene.
4. Presiona 'Aplicar Cambio'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los datos deben ser diferentes.

**Datos de prueba:**
{ "numero": "789", "letra": "C", "concesionario": "Concesionario Actual" }

---

