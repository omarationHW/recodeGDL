# Casos de Uso - consreq400

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa de requerimientos existentes

**Descripción:** El usuario ingresa una recaudadora, UR y cuenta válidos que existen en la base de datos y obtiene los requerimientos correspondientes.

**Precondiciones:**
La tabla req_400 contiene al menos un registro con ofnar='001234', tpr='1', ctarfc='000789'.

**Pasos a seguir:**
1. El usuario accede a la página de Requerimientos AS-400.
2. Ingresa '1234' en Recaudadora, '1' en UR y '789' en Cuenta.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra una tabla con los registros encontrados y el mensaje 'Consulta exitosa.'

**Datos de prueba:**
Recaudadora: 1234
UR: 1
Cuenta: 789

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario ingresa parámetros que no existen en la base de datos.

**Precondiciones:**
No existe ningún registro en req_400 con ofnar='009999', tpr='0', ctarfc='000001'.

**Pasos a seguir:**
1. El usuario accede a la página de Requerimientos AS-400.
2. Ingresa '9999' en Recaudadora, '0' en UR y '1' en Cuenta.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra el mensaje 'No se localizaron requerimientos del AS400' y la tabla está vacía.

**Datos de prueba:**
Recaudadora: 9999
UR: 0
Cuenta: 1

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta buscar sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario accede a la página.

**Pasos a seguir:**
1. El usuario deja vacío el campo Cuenta.
2. Ingresa '1234' en Recaudadora y '1' en UR.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
Recaudadora: 1234
UR: 1
Cuenta: (vacío)

---

