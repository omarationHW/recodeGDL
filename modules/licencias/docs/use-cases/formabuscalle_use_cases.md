# Casos de Uso - formabuscalle

**Categoría:** Form

## Caso de Uso 1: Búsqueda de calles por nombre parcial

**Descripción:** El usuario desea buscar todas las calles que contienen la palabra 'INDEPENDENCIA' en su nombre.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles con 'INDEPENDENCIA' en su nombre en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. Escribe 'INDEPENDENCIA' en el campo de filtro.
3. El sistema muestra todas las coincidencias en la tabla.
4. El usuario puede seleccionar una calle de la lista.

**Resultado esperado:**
Se muestran todas las calles que contienen 'INDEPENDENCIA' en su nombre, excluyendo las ocultas.

**Datos de prueba:**
Filtro: 'INDEPENDENCIA'

---

## Caso de Uso 2: Listar todas las calles disponibles

**Descripción:** El usuario desea ver el catálogo completo de calles disponibles.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. No escribe nada en el campo de filtro.
3. El sistema muestra todas las calles disponibles en la tabla.

**Resultado esperado:**
Se muestran todas las calles, excluyendo las ocultas.

**Datos de prueba:**
Filtro: '' (vacío)

---

## Caso de Uso 3: Seleccionar una calle y obtener su ID

**Descripción:** El usuario busca una calle, la selecciona y confirma su selección para obtener el ID.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda de calles.
2. Escribe parte del nombre de una calle.
3. Selecciona una fila de la tabla.
4. Presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra el ID de la calle seleccionada.

**Datos de prueba:**
Filtro: 'JUAREZ', Selección: primera coincidencia

---

