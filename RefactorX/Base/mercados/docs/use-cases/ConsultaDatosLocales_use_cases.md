# Casos de Uso - ConsultaDatosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Locales por Filtros

**Descripción:** El usuario desea buscar todos los locales de la recaudadora 1, mercado 12, sección 'A', local 101.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en la base.

**Pasos a seguir:**
1. Accede a la página de Consulta de Datos Locales.
2. Selecciona la opción 'Local'.
3. Selecciona recaudadora 1, mercado 12, sección 'A', local 101.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los locales que cumplen los filtros.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 12, "categoria": null, "seccion": "A", "local": 101, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de Locales por Nombre

**Descripción:** El usuario busca todos los locales cuyo nombre comienza con 'JUAN'.

**Precondiciones:**
El usuario tiene acceso y existen locales con nombre 'JUAN'.

**Pasos a seguir:**
1. Accede a la página de Consulta de Datos Locales.
2. Selecciona la opción 'Nombre'.
3. Escribe 'JUAN' en el campo nombre.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se listan todos los locales cuyo nombre inicia con 'JUAN'.

**Datos de prueba:**
{ "nombre": "JUAN" }

---

## Caso de Uso 3: Consulta Individual de Local

**Descripción:** El usuario quiere ver el detalle de un local específico.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene el id_local.

**Pasos a seguir:**
1. En la tabla de resultados, hace clic en 'Ver' en el local deseado.

**Resultado esperado:**
Se muestra el detalle completo del local seleccionado.

**Datos de prueba:**
{ "id_local": 123 }

---

