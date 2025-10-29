# Casos de Uso - consuem400

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa de registros históricos

**Descripción:** El usuario ingresa los parámetros correctos y obtiene los registros históricos del UEM-400.

**Precondiciones:**
La tabla historico contiene registros con recaud=1, ur=0, cuenta=12345.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta UEM-400.
2. Ingresa '1' en Recaudadora, '0' en UR, '12345' en Cuenta.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra una tabla con los registros históricos correspondientes.

**Datos de prueba:**
{ "recaud": 1, "ur": 0, "cuenta": 12345 }

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario ingresa parámetros que no existen en la base de datos.

**Precondiciones:**
No existen registros en historico con recaud=99, ur=9, cuenta=99999.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta UEM-400.
2. Ingresa '99' en Recaudadora, '9' en UR, '99999' en Cuenta.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra un mensaje: 'No se localizaron registros históricos del AS400'.

**Datos de prueba:**
{ "recaud": 99, "ur": 9, "cuenta": 99999 }

---

## Caso de Uso 3: Validación de parámetros requeridos

**Descripción:** El usuario intenta buscar sin ingresar todos los parámetros.

**Precondiciones:**
El usuario deja vacío uno o más campos del formulario.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta UEM-400.
2. Deja vacío el campo 'Cuenta'.
3. Presiona el botón Buscar.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{ "recaud": 1, "ur": 0, "cuenta": null }

---

