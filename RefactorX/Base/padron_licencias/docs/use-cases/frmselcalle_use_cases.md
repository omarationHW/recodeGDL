# Casos de Uso - frmselcalle

**Categoría:** Form

## Caso de Uso 1: Búsqueda de calles por prefijo

**Descripción:** El usuario ingresa un texto en el campo de búsqueda para filtrar las calles cuyo nombre comienza con ese texto.

**Precondiciones:**
La base de datos contiene varias calles registradas.

**Pasos a seguir:**
1. El usuario accede a la página de selección de calles.
2. Escribe 'AVENIDA' en el campo de búsqueda.
3. El sistema muestra solo las calles que comienzan con 'AVENIDA'.

**Resultado esperado:**
La tabla muestra únicamente las calles cuyo nombre inicia con 'AVENIDA'.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'} ]

---

## Caso de Uso 2: Selección múltiple de calles

**Descripción:** El usuario selecciona varias calles de la lista y confirma su selección.

**Precondiciones:**
La tabla de calles tiene al menos 3 registros.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Marca las casillas de las calles con cvecalle 1 y 2.
3. Presiona el botón 'Aceptar'.

**Resultado esperado:**
Se muestra un mensaje con los IDs seleccionados: '1,2'.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'} ]

---

## Caso de Uso 3: Visualización de todas las calles sin filtro

**Descripción:** El usuario deja el campo de búsqueda vacío para ver todas las calles.

**Precondiciones:**
La base de datos contiene al menos 5 calles.

**Pasos a seguir:**
1. El usuario accede a la página.
2. No escribe nada en el campo de búsqueda.
3. El sistema muestra todas las calles.

**Resultado esperado:**
La tabla muestra todas las calles ordenadas alfabéticamente.

**Datos de prueba:**
c_calles: [ {cvecalle: 1, calle: 'AVENIDA CENTRAL'}, {cvecalle: 2, calle: 'AVENIDA JUAREZ'}, {cvecalle: 3, calle: 'CALLE 5 DE MAYO'}, {cvecalle: 4, calle: 'CALLE HIDALGO'}, {cvecalle: 5, calle: 'BOULEVARD NORTE'} ]

---

