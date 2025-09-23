# Casos de Uso - Bja_Multiple

**Categoría:** Form

## Caso de Uso 1: Carga y grabación de folios de baja múltiple

**Descripción:** El usuario ingresa el nombre de un archivo y varios registros de folios a dar de baja, luego presiona 'Grabar' para almacenarlos.

**Precondiciones:**
El usuario tiene acceso al sistema y la tabla ta14_folios_baja_esta está vacía o lista para recibir datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Baja Múltiple de Folios'.
2. Ingresa 'archivo_test_01' en el campo de archivo.
3. Llena tres filas con datos válidos (placa, folio, fecha, anomalia, referencia).
4. Presiona 'Grabar'.

**Resultado esperado:**
Los tres registros se insertan en la tabla ta14_folios_baja_esta con el archivo 'archivo_test_01'. Se muestra mensaje de éxito.

**Datos de prueba:**
[
  { "placa": "ABC1234", "folio_archivo": 1001, "fecha_archivo": "2024-06-01", "anomalia": "Falta pago", "tarifa": "", "referencia": 501 },
  { "placa": "XYZ5678", "folio_archivo": 1002, "fecha_archivo": "2024-06-01", "anomalia": "Duplicado", "tarifa": "", "referencia": 502 },
  { "placa": "LMN9012", "folio_archivo": 1003, "fecha_archivo": "2024-06-01", "anomalia": "Sin datos", "tarifa": "", "referencia": 503 }
]

---

## Caso de Uso 2: Aplicación de llenado y validación de folios

**Descripción:** Después de grabar los registros, el usuario ejecuta el proceso de llenado y aplicación.

**Precondiciones:**
Existen registros en ta14_folios_baja_esta con estatus NULL.

**Pasos a seguir:**
1. El usuario presiona el botón 'Llenado y Aplicado'.
2. El sistema ejecuta el SP de llenado/aplicación.

**Resultado esperado:**
Los registros con anomalia vacía o nula se actualizan a estatus=9. Se muestra mensaje de éxito.

**Datos de prueba:**
Registros previamente insertados, uno de ellos con anomalia vacía.

---

## Caso de Uso 3: Consulta de incidencias (errores de validación)

**Descripción:** El usuario consulta los registros con error de validación para un archivo específico.

**Precondiciones:**
Existen registros en ta14_folios_baja_esta con archivo='archivo_test_01' y estatus=9.

**Pasos a seguir:**
1. El usuario presiona el botón 'Vista'.
2. El sistema consulta y muestra los registros con error de validación.

**Resultado esperado:**
Se muestra una tabla con los registros que tienen estatus=9 para el archivo indicado.

**Datos de prueba:**
archivo = 'archivo_test_01'

---

