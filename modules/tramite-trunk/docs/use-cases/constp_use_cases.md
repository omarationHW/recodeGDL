# Casos de Uso - constp

**Categoría:** Form

## Caso de Uso 1: Consulta por Notaría, Municipio y Escritura específicos

**Descripción:** El usuario ingresa los tres campos (Notaría, Municipio de Adscripción y Escritura) para obtener un registro exacto.

**Precondiciones:**
Existe al menos un registro en la tabla transmisiones_patrimoniales con los valores especificados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Transmisiones Patrimoniales.
2. Ingresa Notaría: 1, Municipio: 2, Escritura: 123.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con el registro exacto correspondiente a los valores ingresados.

**Datos de prueba:**
{ "notaria": 1, "municipio": 2, "escritura": 123 }

---

## Caso de Uso 2: Consulta solo por Notaría

**Descripción:** El usuario ingresa solo el campo Notaría y deja los demás en blanco para obtener todos los registros de esa notaría.

**Precondiciones:**
Existen varios registros con notaria = 5 en la tabla.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa Notaría: 5, deja Municipio y Escritura vacíos.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestran todos los registros de la notaría 5.

**Datos de prueba:**
{ "notaria": 5, "municipio": null, "escritura": null }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario ingresa valores que no existen en la base de datos.

**Precondiciones:**
No existen registros con notaria = 99, municipio = 99, escritura = 9999.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa Notaría: 99, Municipio: 99, Escritura: 9999.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados.

**Datos de prueba:**
{ "notaria": 99, "municipio": 99, "escritura": 9999 }

---

