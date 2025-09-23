# Casos de Uso - sfrm_tr_estado_mpio

**Categoría:** Form

## Caso de Uso 1: Carga de archivo de remesas y procesamiento

**Descripción:** El usuario carga un archivo CSV con datos de remesas para ser procesado e insertado en la base de datos.

**Precondiciones:**
El usuario tiene acceso a la página y un archivo CSV válido con los datos requeridos.

**Pasos a seguir:**
1. El usuario accede a la página de Transferencia de Datos.
2. Selecciona un archivo CSV desde su equipo.
3. Presiona el botón 'Subir y Procesar Archivo'.
4. El sistema sube el archivo y lo procesa en el backend.
5. El sistema muestra mensaje de éxito y actualiza la tabla de remesas.

**Resultado esperado:**
El archivo es procesado correctamente, los datos se insertan en la base de datos y la tabla de remesas se actualiza.

**Datos de prueba:**
Archivo CSV: 'dti_est_r011.txt' con datos de ejemplo.

---

## Caso de Uso 2: Visualización de últimas remesas procesadas

**Descripción:** El usuario consulta la página y visualiza las últimas 5 remesas procesadas.

**Precondiciones:**
Existen remesas previamente cargadas en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Transferencia de Datos.
2. El sistema consulta y muestra la tabla de remesas.

**Resultado esperado:**
Se muestran las últimas 5 remesas con sus fechas correspondientes.

**Datos de prueba:**
Base de datos con al menos 5 remesas distintas.

---

## Caso de Uso 3: Eliminación de registro específico vía stored procedure

**Descripción:** El usuario solicita eliminar un registro específico usando el procedimiento spd_delesta01.

**Precondiciones:**
Existe un registro con el folio y placa especificados.

**Pasos a seguir:**
1. El usuario envía una petición a la API con eRequest 'procesar_delesta01' y los parámetros requeridos (folio, placa, opc=1).
2. El sistema ejecuta el stored procedure y elimina el registro.

**Resultado esperado:**
El registro es eliminado y se devuelve un mensaje de éxito.

**Datos de prueba:**
{ "folio": 12345, "placa": "ABC123", "opc": 1 }

---

