# Casos de Uso - PasoEne

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos de Energía desde Archivo TXT

**Descripción:** El usuario carga un archivo de pagos de energía eléctrica generado por el sistema legacy y lo inserta en la base de datos.

**Precondiciones:**
El usuario tiene acceso al sistema y un archivo TXT válido con pagos de energía.

**Pasos a seguir:**
1. El usuario accede a la página PasoEne.
2. Selecciona el archivo TXT de pagos.
3. El sistema parsea y muestra la previsualización de los registros.
4. El usuario revisa y confirma la carga.
5. El sistema ejecuta la inserción masiva y muestra el resultado.

**Resultado esperado:**
Todos los registros válidos se insertan en la tabla ta_11_pago_energia. Se reportan los errores de formato o inserción.

**Datos de prueba:**
Archivo TXT con 10 registros de pagos de energía, incluyendo uno con fecha malformada.

---

## Caso de Uso 2: Validación de Formato de Archivo

**Descripción:** El usuario intenta cargar un archivo TXT con líneas malformadas.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con líneas incompletas o datos corruptos.

**Pasos a seguir:**
1. El usuario accede a PasoEne.
2. Selecciona el archivo TXT con errores.
3. El sistema parsea y muestra los errores detectados.

**Resultado esperado:**
El sistema no permite la carga masiva y muestra los errores de formato.

**Datos de prueba:**
Archivo TXT con 5 líneas, 2 de ellas con menos de 100 caracteres.

---

## Caso de Uso 3: Carga Parcial con Errores de Inserción

**Descripción:** El usuario carga un archivo donde algunos registros ya existen o violan restricciones.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con registros duplicados o con claves foráneas inválidas.

**Pasos a seguir:**
1. El usuario accede a PasoEne.
2. Selecciona el archivo TXT.
3. El sistema parsea y muestra la previsualización.
4. El usuario ejecuta la carga masiva.
5. El sistema inserta los registros válidos y reporta los errores de los inválidos.

**Resultado esperado:**
Solo los registros válidos se insertan. Se reportan los errores de duplicidad o integridad.

**Datos de prueba:**
Archivo TXT con 8 registros, 3 de ellos con id_energia inexistente.

---

