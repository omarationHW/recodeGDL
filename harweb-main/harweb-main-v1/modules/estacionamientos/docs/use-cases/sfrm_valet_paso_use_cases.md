# Casos de Uso - sfrm_valet_paso

**Categoría:** Form

## Caso de Uso 1: Carga y vista previa de archivo de valet

**Descripción:** El usuario carga un archivo CSV de valet y visualiza las primeras filas como vista previa.

**Precondiciones:**
El usuario tiene acceso a la página y un archivo CSV válido.

**Pasos a seguir:**
1. Ingresar a la página 'Pasar datos de Valet'.
2. Seleccionar un archivo CSV válido.
3. Hacer clic en 'Abrir archivo'.

**Resultado esperado:**
El archivo se sube correctamente y se muestra una tabla con las primeras filas del archivo.

**Datos de prueba:**
Archivo CSV con 5 filas y 3 columnas: col1,col2,col3\nA,1,X\nB,2,Y\nC,3,Z\nD,4,W\nE,5,V

---

## Caso de Uso 2: Procesamiento exitoso de datos de valet

**Descripción:** El usuario procesa un archivo previamente cargado y los datos se insertan en la base de datos.

**Precondiciones:**
Archivo subido y visible en la vista previa.

**Pasos a seguir:**
1. Hacer clic en 'Pasar datos de valet'.

**Resultado esperado:**
Se muestra un mensaje de éxito y un resumen de las filas insertadas.

**Datos de prueba:**
Archivo CSV con datos válidos, sin errores de formato.

---

## Caso de Uso 3: Manejo de error por archivo inválido

**Descripción:** El usuario intenta subir un archivo con formato incorrecto o columnas faltantes.

**Precondiciones:**
El usuario tiene un archivo CSV con columnas incorrectas.

**Pasos a seguir:**
1. Seleccionar el archivo inválido.
2. Hacer clic en 'Abrir archivo'.
3. Intentar procesar los datos.

**Resultado esperado:**
Se muestra un mensaje de error indicando el problema con el archivo.

**Datos de prueba:**
Archivo CSV con solo 1 columna: col1\nA\nB\nC

---

