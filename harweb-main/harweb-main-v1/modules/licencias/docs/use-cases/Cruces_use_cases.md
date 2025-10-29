# Casos de Uso - Cruces

**Categoría:** Form

## Caso de Uso 1: Búsqueda y selección de dos calles para cruce

**Descripción:** El usuario busca y selecciona dos calles distintas para registrar un cruce.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas en la base de datos.

**Pasos a seguir:**
[
  "El usuario ingresa parte del nombre de la primera calle en el campo de búsqueda.",
  "El sistema muestra una lista de coincidencias (excluyendo calles escondidas).",
  "El usuario selecciona una calle de la lista.",
  "El usuario ingresa parte del nombre de la segunda calle en el campo correspondiente.",
  "El sistema muestra una lista de coincidencias (excluyendo calles escondidas).",
  "El usuario selecciona una calle de la lista.",
  "El usuario presiona el botón 'Aceptar'.",
  "El sistema muestra los datos completos de ambas calles seleccionadas."
]

**Resultado esperado:**
Se muestran correctamente los datos de ambas calles seleccionadas.

**Datos de prueba:**
Calle1: 'INDEPENDENCIA', Calle2: 'JUAREZ'

---

## Caso de Uso 2: Búsqueda de calle inexistente

**Descripción:** El usuario intenta buscar una calle que no existe en el catálogo.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
[
  "El usuario ingresa un texto inexistente en el campo de búsqueda de la primera calle.",
  "El sistema consulta el API.",
  "El sistema muestra una lista vacía.",
  "El usuario repite el proceso en el campo de la segunda calle con otro texto inexistente.",
  "El sistema muestra una lista vacía."
]

**Resultado esperado:**
No se muestran resultados en la lista de búsqueda.

**Datos de prueba:**
Calle1: 'ZZZZZZ', Calle2: 'XXXXXX'

---

## Caso de Uso 3: Selección de solo una calle

**Descripción:** El usuario selecciona solo una calle y deja la otra sin seleccionar.

**Precondiciones:**
El usuario tiene acceso al sistema y existen calles registradas.

**Pasos a seguir:**
[
  "El usuario ingresa parte del nombre de la primera calle y selecciona una opción.",
  "El usuario deja el campo de la segunda calle vacío.",
  "El usuario presiona el botón 'Aceptar'.",
  "El sistema muestra los datos completos solo de la calle seleccionada."
]

**Resultado esperado:**
Se muestra correctamente la información de la calle seleccionada y la otra aparece como N/A.

**Datos de prueba:**
Calle1: 'INDEPENDENCIA', Calle2: ''

---

