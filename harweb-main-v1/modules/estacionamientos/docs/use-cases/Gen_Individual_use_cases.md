# Casos de Uso - Gen_Individual

**Categoría:** Form

## Caso de Uso 1: Generar remesa por placa

**Descripción:** El usuario desea generar una remesa de folios usando únicamente el número de placa.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce una placa válida con folios asociados.

**Pasos a seguir:**
[
  "Ingresar a la página de Generación de Folios Individuales.",
  "Seleccionar la opción 'Por Placa'.",
  "Ingresar el número de placa (ejemplo: JBB3322).",
  "Presionar el botón 'Añadir'.",
  "Verificar que los registros aparecen en la tabla.",
  "Presionar 'Ejecutar' para grabar la remesa.",
  "Presionar 'Generar Archivo' para obtener el archivo de texto.",
  "Descargar el archivo generado."
]

**Resultado esperado:**
La remesa se genera correctamente, los registros aparecen en la tabla, los contadores se actualizan y el archivo de texto es descargable.

**Datos de prueba:**
Placa: JBB3322

---

## Caso de Uso 2: Generar remesa por placa y folios específicos

**Descripción:** El usuario desea generar una remesa sólo para ciertos folios de una placa.

**Precondiciones:**
El usuario conoce la placa y los folios válidos.

**Pasos a seguir:**
[
  "Ingresar a la página de Generación de Folios Individuales.",
  "Seleccionar la opción 'Por Placa y Folios'.",
  "Ingresar la placa (ejemplo: JBB3322) y los folios (ejemplo: 123,124).",
  "Presionar 'Añadir'.",
  "Verificar que sólo los folios indicados aparecen en la tabla.",
  "Presionar 'Ejecutar'.",
  "Presionar 'Generar Archivo'.",
  "Descargar el archivo."
]

**Resultado esperado:**
Sólo los folios especificados se incluyen en la remesa y en el archivo generado.

**Datos de prueba:**
Placa: JBB3322, Folios: 123,124

---

## Caso de Uso 3: Generar remesa por año y folios

**Descripción:** El usuario desea generar una remesa para folios de un año específico.

**Precondiciones:**
El usuario conoce el año y los folios válidos.

**Pasos a seguir:**
[
  "Ingresar a la página de Generación de Folios Individuales.",
  "Seleccionar la opción 'Por Año y Folios'.",
  "Ingresar el año (ejemplo: 2023) y los folios (ejemplo: 1001,1002).",
  "Presionar 'Añadir'.",
  "Verificar que los registros aparecen en la tabla.",
  "Presionar 'Ejecutar'.",
  "Presionar 'Generar Archivo'.",
  "Descargar el archivo."
]

**Resultado esperado:**
Los folios del año especificado se incluyen en la remesa y en el archivo generado.

**Datos de prueba:**
Año: 2023, Folios: 1001,1002

---

