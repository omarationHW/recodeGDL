# Casos de Uso - Gen_PgosBanorte

**Categoría:** Form

## Caso de Uso 1: Generar una nueva remesa de pagos Banorte para el periodo siguiente

**Descripción:** El usuario consulta el último periodo, selecciona el siguiente día como nuevo periodo, ejecuta la remesa y genera el archivo de texto.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de pagos en el periodo seleccionado.

**Pasos a seguir:**
1. Ingresar a la página de Generación de Pagos Banorte.
2. Visualizar el último periodo mostrado.
3. Seleccionar como fecha de inicio y fin el día siguiente al último periodo.
4. Presionar 'Ejecutar'.
5. Esperar confirmación y cantidad de registros.
6. Presionar 'Generar Archivo Texto'.
7. Descargar el archivo generado.

**Resultado esperado:**
Se genera una nueva remesa, se actualizan los registros y se puede descargar el archivo de texto con los datos.

**Datos de prueba:**
Periodo anterior: 2024-06-10 a 2024-06-10
Nuevo periodo: 2024-06-11 a 2024-06-11

---

## Caso de Uso 2: Intentar generar archivo de texto sin registros en la remesa

**Descripción:** El usuario ejecuta una remesa para un periodo donde no existen registros de pagos.

**Precondiciones:**
No existen registros de pagos para el periodo seleccionado.

**Pasos a seguir:**
1. Ingresar a la página.
2. Seleccionar fechas de un periodo sin registros.
3. Presionar 'Ejecutar'.
4. Intentar 'Generar Archivo Texto'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay registros para generar el archivo.

**Datos de prueba:**
Periodo: 2024-01-01 a 2024-01-01 (sin registros)

---

## Caso de Uso 3: Descargar archivo de remesa previamente generado

**Descripción:** El usuario descarga un archivo de remesa generado anteriormente desde el enlace proporcionado.

**Precondiciones:**
Existe un archivo de remesa generado y almacenado en el sistema.

**Pasos a seguir:**
1. Ingresar a la página.
2. Ejecutar una remesa y generar el archivo.
3. Hacer clic en el enlace de descarga.
4. Verificar que el archivo se descarga correctamente.

**Resultado esperado:**
El archivo de texto se descarga y contiene los registros de la remesa.

**Datos de prueba:**
Archivo: remesa_R20240611120000.txt

---

