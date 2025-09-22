# Casos de Uso - cartonva

**Categoría:** Form

## Caso de Uso 1: Consulta de Cartografía Predial por Cuenta Catastral

**Descripción:** El usuario ingresa la clave de cuenta catastral y visualiza la información y el visor cartográfico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la clave de cuenta catastral.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Cartografía Predial'.",
  "Ingresa el número de cuenta catastral en el formulario.",
  "Presiona el botón 'Buscar'.",
  "El sistema consulta la API y muestra los datos de la cuenta.",
  "El visor cartográfico se carga en un iframe con la clave catastral correspondiente."
]

**Resultado esperado:**
Se muestran los datos de la cuenta y el visor cartográfico correctamente.

**Datos de prueba:**
cvecuenta: 123456

---

## Caso de Uso 2: Error al Buscar Cuenta Inexistente

**Descripción:** El usuario intenta buscar una cuenta catastral que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
[
  "Accede a la página 'Cartografía Predial'.",
  "Ingresa un número de cuenta catastral inexistente (ej: 99999999).",
  "Presiona 'Buscar'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la cuenta no fue encontrada.

**Datos de prueba:**
cvecuenta: 99999999

---

## Caso de Uso 3: Visualización Directa del Visor Cartográfico

**Descripción:** El usuario accede directamente al visor cartográfico para una clave catastral específica.

**Precondiciones:**
El usuario conoce la clave catastral (cvecatnva).

**Pasos a seguir:**
[
  "El usuario accede a la página 'Cartografía Predial'.",
  "Hace clic en un enlace o botón que abre el visor cartográfico para una clave catastral.",
  "El sistema construye la URL y la muestra en un iframe o nueva ventana."
]

**Resultado esperado:**
El visor cartográfico se muestra correctamente para la clave catastral indicada.

**Datos de prueba:**
cvecatnva: 'A1234567890'

---

