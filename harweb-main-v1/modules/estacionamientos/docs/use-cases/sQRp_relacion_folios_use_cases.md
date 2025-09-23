# Casos de Uso - sQRp_relacion_folios

**Categoría:** Form

## Caso de Uso 1: Consulta de folios por fecha de folio

**Descripción:** El usuario desea obtener la relación de folios generados en una fecha específica usando el filtro por fecha de folio.

**Precondiciones:**
Existen registros en la tabla ta14_folios_adeudo con fecha_folio igual a la fecha consultada.

**Pasos a seguir:**
1. El usuario accede a la página de Relación de Folios.
2. Selecciona 'Por Fecha de Folio' en el tipo de fecha.
3. Ingresa la fecha deseada (ejemplo: 2024-06-01).
4. Presiona el botón 'Buscar'.
5. El sistema muestra la tabla con los folios correspondientes.

**Resultado esperado:**
Se muestra una tabla con los folios, placas, claves, estados y tarifas correspondientes a la fecha seleccionada.

**Datos de prueba:**
opcion: 1
fecha: 2024-06-01

---

## Caso de Uso 2: Consulta de folios por fecha de alta

**Descripción:** El usuario requiere ver los folios dados de alta en una fecha específica.

**Precondiciones:**
Existen registros en ta14_folios_adeudo con fecha_alta igual a la fecha consultada.

**Pasos a seguir:**
1. Acceder a la página de Relación de Folios.
2. Seleccionar 'Por Fecha de Alta'.
3. Ingresar la fecha (ejemplo: 2024-05-15).
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se listan los folios dados de alta en la fecha indicada.

**Datos de prueba:**
opcion: 2
fecha: 2024-05-15

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario consulta una fecha para la cual no existen folios registrados.

**Precondiciones:**
No existen registros en ta14_folios_adeudo para la fecha y filtro seleccionados.

**Pasos a seguir:**
1. Acceder a la página de Relación de Folios.
2. Seleccionar cualquier tipo de fecha.
3. Ingresar una fecha sin registros (ejemplo: 1999-01-01).
4. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra el mensaje 'No hay datos para mostrar.'

**Datos de prueba:**
opcion: 1
fecha: 1999-01-01

---

