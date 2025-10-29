# Casos de Uso - sFrm_trans_exclu

**Categoría:** Form

## Caso de Uso 1: Importar archivo plano de exclusivos

**Descripción:** El usuario carga un archivo plano exportado del HP3000, visualiza los registros parseados y los importa a la base de datos.

**Precondiciones:**
El usuario tiene acceso al sistema y un archivo plano válido.

**Pasos a seguir:**
1. Ingresar a la página de Transferencia de Exclusivos.
2. Seleccionar el archivo plano a importar.
3. Hacer clic en 'Pasar Datos' para parsear el archivo.
4. Revisar la vista previa de los registros.
5. Hacer clic en 'Altas' para importar todos los registros.

**Resultado esperado:**
Todos los registros del archivo son insertados en la tabla ta_18_exclusivo. Se muestra mensaje de éxito.

**Datos de prueba:**
Archivo plano con 3 líneas de ejemplo, cada una con datos válidos en el layout especificado.

---

## Caso de Uso 2: Actualizar fecha de vencimiento de un público

**Descripción:** El usuario actualiza la fecha de vencimiento de un registro existente en ta_15_publicos.

**Precondiciones:**
Existe un registro en ta_15_publicos con los datos de sector, categoría y número indicados.

**Pasos a seguir:**
1. Ingresar a la página de Transferencia de Exclusivos.
2. Hacer clic en 'Actualizar Fechas'.
3. Ingresar sector, categoría, número y nueva fecha de vencimiento.
4. Hacer clic en 'Actualizar'.

**Resultado esperado:**
La fecha de vencimiento del registro es actualizada correctamente. Se muestra mensaje de éxito.

**Datos de prueba:**
sector: 'A', categ: 'X', num: 1234, fec_venci: '2024-12-31'

---

## Caso de Uso 3: Validación de archivo plano con errores

**Descripción:** El usuario intenta importar un archivo plano con líneas mal formateadas o campos faltantes.

**Precondiciones:**
El usuario tiene un archivo plano con al menos una línea inválida.

**Pasos a seguir:**
1. Ingresar a la página de Transferencia de Exclusivos.
2. Seleccionar el archivo plano con errores.
3. Hacer clic en 'Pasar Datos'.
4. Intentar importar los registros.

**Resultado esperado:**
El sistema muestra mensajes de error para los registros inválidos y sólo importa los válidos.

**Datos de prueba:**
Archivo plano con 2 líneas: una con todos los campos, otra con campos vacíos o mal posicionados.

---

