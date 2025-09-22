# Casos de Uso - ActualizaPlazo

**Categoría:** Form

## Caso de Uso 1: Carga y actualización masiva de ampliaciones de plazo

**Descripción:** El usuario importa un archivo plano con datos de ampliaciones de plazo y ejecuta la actualización masiva en la base de datos.

**Precondiciones:**
El usuario tiene permisos de administrador y acceso al módulo. El archivo cumple con el formato requerido.

**Pasos a seguir:**
1. El usuario accede a la página 'Actualización de Contratos con Ampliación de Plazo'.
2. Selecciona el archivo plano (.txt/.csv) con los datos tabulados por '|'.
3. Hace clic en 'Previsualizar' y revisa la grilla de datos.
4. Hace clic en 'Actualizar Plazo'.
5. El sistema procesa cada fila, calcula la fecha de vencimiento y actualiza la tabla.
6. El sistema muestra un mensaje de éxito y los errores por fila (si los hay).

**Resultado esperado:**
Los registros válidos se insertan en ta_17_amp_plazo. Se reportan errores de filas inválidas.

**Datos de prueba:**
Archivo de ejemplo:
OSC001|EXP001|2024-06-01|12|101|5|10|10000.00|500.00|10500.00|12|1000.00|10|500.00|2024-06-01|2025-06-01|M|Observación ejemplo

---

## Caso de Uso 2: Validación de archivo con filas incompletas

**Descripción:** El usuario intenta importar un archivo con filas que no cumplen el número de columnas requerido.

**Precondiciones:**
El usuario tiene acceso al módulo. El archivo contiene filas con menos de 19 columnas.

**Pasos a seguir:**
1. El usuario carga el archivo y previsualiza la grilla.
2. Hace clic en 'Actualizar Plazo'.
3. El sistema procesa y detecta las filas incompletas.

**Resultado esperado:**
El sistema reporta error en las filas con columnas insuficientes y no las inserta.

**Datos de prueba:**
OSC002|EXP002|2024-06-01|12|101|5|10|10000.00|500.00|10500.00|12|1000.00|10|500.00|2024-06-01|M|Observación incompleta

---

## Caso de Uso 3: Error en cálculo de fecha de vencimiento

**Descripción:** El usuario importa un archivo con datos que no corresponden a un convenio existente.

**Precondiciones:**
El usuario tiene acceso al módulo. El archivo contiene filas con colonia/calle/folio inexistentes.

**Pasos a seguir:**
1. El usuario carga el archivo y previsualiza la grilla.
2. Hace clic en 'Actualizar Plazo'.
3. El sistema intenta calcular la fecha de vencimiento y falla en las filas sin convenio.

**Resultado esperado:**
El sistema reporta error en las filas donde no se encuentra el convenio.

**Datos de prueba:**
OSC003|EXP003|2024-06-01|12|999|99|99|10000.00|500.00|10500.00|12|1000.00|10|500.00|2024-06-01|2025-06-01|M|Observación error

---

