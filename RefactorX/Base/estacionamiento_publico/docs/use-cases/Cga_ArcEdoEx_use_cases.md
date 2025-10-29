# Casos de Uso - Cga_ArcEdoEx

**Categoría:** Form

## Caso de Uso 1: Carga exitosa de archivo de pagos y aplicación de remesa

**Descripción:** El usuario carga un archivo de pagos válido, graba los registros y aplica la remesa correctamente.

**Precondiciones:**
El usuario tiene acceso al sistema y un archivo .txt válido con datos de pagos.

**Pasos a seguir:**
1. El usuario accede a la página de Carga Pagos SECFIN.
2. Selecciona un archivo .txt válido.
3. Presiona 'Descargar Datos' y visualiza la vista previa.
4. Presiona 'GRABAR' y espera confirmación de carga.
5. Presiona 'APLICAR' y espera confirmación de aplicación.

**Resultado esperado:**
Todos los registros se insertan correctamente, la remesa se aplica y se registra en bitácora. El usuario ve mensajes de éxito.

**Datos de prueba:**
Archivo .txt con líneas como:
113|PN|12345|ABC123|2024-06-01|1000.00|2024-06-01

---

## Caso de Uso 2: Carga de archivo con registros erróneos

**Descripción:** El usuario intenta cargar un archivo con algunos registros inválidos (por ejemplo, folio duplicado o campos vacíos).

**Precondiciones:**
El usuario tiene acceso y un archivo .txt con registros inválidos.

**Pasos a seguir:**
1. Accede a la página.
2. Selecciona el archivo con errores.
3. Presiona 'Descargar Datos'.
4. Presiona 'GRABAR'.

**Resultado esperado:**
El sistema muestra errores específicos para los registros fallidos y no permite aplicar la remesa hasta corregirlos.

**Datos de prueba:**
Archivo .txt con líneas:
113|PN|12345|ABC123|2024-06-01|1000.00|2024-06-01
113|PN||ABC124|2024-06-01|500.00|2024-06-01

---

## Caso de Uso 3: Intento de aplicar remesa sin registros cargados

**Descripción:** El usuario intenta aplicar una remesa sin haber cargado registros.

**Precondiciones:**
El usuario accede a la página sin cargar ningún archivo.

**Pasos a seguir:**
1. Accede a la página.
2. Intenta presionar 'APLICAR' sin cargar ni grabar registros.

**Resultado esperado:**
El botón 'APLICAR' está deshabilitado y el sistema no permite continuar.

**Datos de prueba:**
Sin archivo cargado.

---

