# Casos de Uso - CargaPagosTexto

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos desde Archivo de Texto

**Descripción:** El usuario importa un archivo de texto con pagos realizados en el Mercado Libertad. El sistema previsualiza los registros, permite la confirmación y realiza la importación masiva.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para importar pagos. El archivo de texto cumple con el formato requerido.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Texto.
2. Selecciona el archivo de texto y lo carga.
3. El sistema previsualiza los pagos detectados.
4. El usuario revisa y confirma la importación.
5. El sistema importa los pagos y elimina los adeudos correspondientes.
6. Se muestra un resumen de la importación.

**Resultado esperado:**
Los pagos se importan correctamente, los adeudos pagados se eliminan, y se muestra un resumen con totales.

**Datos de prueba:**
Archivo de texto con 3 líneas de pagos válidos, sin duplicados.

---

## Caso de Uso 2: Intento de Importar Pagos Duplicados

**Descripción:** El usuario intenta importar un archivo que contiene pagos ya registrados previamente.

**Precondiciones:**
Existen pagos en la base de datos con los mismos id_local, año y periodo.

**Pasos a seguir:**
1. El usuario carga el archivo de texto con pagos duplicados.
2. El sistema previsualiza los registros.
3. El usuario confirma la importación.
4. El sistema detecta los duplicados y no los vuelve a grabar.

**Resultado esperado:**
Los pagos duplicados no se importan nuevamente. El resumen indica cuántos ya estaban grabados.

**Datos de prueba:**
Archivo de texto con 2 pagos ya existentes y 1 nuevo.

---

## Caso de Uso 3: Importación con Error de Formato

**Descripción:** El usuario intenta importar un archivo de texto con líneas incompletas o mal formateadas.

**Precondiciones:**
El archivo contiene líneas con menos de 72 caracteres o campos no numéricos.

**Pasos a seguir:**
1. El usuario carga el archivo de texto erróneo.
2. El sistema intenta previsualizar y detecta el error de formato.
3. Se muestra un mensaje de error y no se permite la importación.

**Resultado esperado:**
El sistema rechaza el archivo y muestra un mensaje de error claro.

**Datos de prueba:**
Archivo de texto con una línea de solo 20 caracteres y otra con letras en el campo importe.

---

