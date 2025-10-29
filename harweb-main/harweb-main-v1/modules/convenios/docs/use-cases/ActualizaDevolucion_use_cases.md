# Casos de Uso - ActualizaDevolucion

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Devoluciones Correctas

**Descripción:** El usuario carga un archivo de devoluciones con todos los contratos existentes y datos válidos.

**Precondiciones:**
El usuario tiene permisos y contratos existen en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Actualización de Devoluciones.
2. Selecciona un archivo de texto con devoluciones válidas.
3. Previsualiza la grilla y confirma la actualización.
4. El sistema procesa todas las filas y las inserta.

**Resultado esperado:**
Todas las devoluciones se insertan correctamente. El sistema muestra mensaje de éxito y cero errores.

**Datos de prueba:**
Archivo con filas como:
TODO|1|REM001|OFI001|FOL001|2024-05-01|101|5|123|1000.00|RFC123|Observación|2024|1|1

---

## Caso de Uso 2: Carga con Contratos Inexistentes

**Descripción:** El usuario carga un archivo donde algunas devoluciones refieren contratos que no existen.

**Precondiciones:**
Algunos contratos (colonia, calle, folio) no existen.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Sube el archivo con devoluciones, algunas con contratos inexistentes.
3. Previsualiza y ejecuta la actualización.

**Resultado esperado:**
El sistema inserta solo las devoluciones válidas y reporta errores para las filas con contratos inexistentes.

**Datos de prueba:**
Archivo con filas válidas y otras con colonia/calle/folio que no existen.

---

## Caso de Uso 3: Carga con Formato Incorrecto

**Descripción:** El usuario carga un archivo con filas que tienen menos de 15 columnas.

**Precondiciones:**
El archivo contiene filas mal formateadas.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Sube el archivo con filas incompletas.
3. Previsualiza y ejecuta la actualización.

**Resultado esperado:**
El sistema reporta errores por columnas insuficientes y no inserta esas filas.

**Datos de prueba:**
Archivo con algunas filas de solo 10 columnas.

---

