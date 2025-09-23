# Casos de Uso - Gen_ArcDiario

**Categoría:** Form

## Caso de Uso 1: Generación exitosa de archivo diario de remesa

**Descripción:** El usuario genera correctamente una remesa diaria y descarga el archivo de texto.

**Precondiciones:**
El usuario está autenticado y existen datos en ta14_datos_mpio para el periodo seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de generación de archivo diario.
2. Visualiza los periodos actuales.
3. Selecciona fechas válidas para el nuevo periodo.
4. Hace clic en 'Ejecutar'.
5. El sistema ejecuta el SP y muestra el resumen de remesa y folios.
6. El usuario hace clic en 'Generar Archivo'.
7. El sistema genera el archivo y muestra el enlace de descarga.
8. El usuario descarga el archivo.

**Resultado esperado:**
El archivo de texto se genera correctamente y contiene los registros de la remesa seleccionada.

**Datos de prueba:**
Periodo: 2024-06-01 a 2024-06-10, existen registros en ta14_datos_mpio para ese rango.

---

## Caso de Uso 2: Intento de generación sin registros

**Descripción:** El usuario intenta generar un archivo de remesa para un periodo sin registros.

**Precondiciones:**
El usuario está autenticado. No existen registros en ta14_datos_mpio para el periodo seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona un periodo sin registros.
3. Hace clic en 'Ejecutar'.
4. El sistema ejecuta el SP y muestra resumen con folios en cero.
5. El usuario intenta 'Generar Archivo'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no hay registros para generar el archivo.

**Datos de prueba:**
Periodo: 2024-07-01 a 2024-07-10, sin registros en ta14_datos_mpio.

---

## Caso de Uso 3: Error en el proceso de remesa (SP)

**Descripción:** El proceso de generación de remesa falla por un error interno en el SP.

**Precondiciones:**
El usuario está autenticado. El SP sp14_remesa retorna status distinto de 0.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona un periodo.
3. Hace clic en 'Ejecutar'.
4. El SP retorna status=1 y mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje de error retornado por el SP y no permite generar el archivo.

**Datos de prueba:**
Forzar error en SP (por ejemplo, periodo inválido o error de lógica).

---

