# Casos de Uso - listdesctomultafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de descuentos de multas para una recaudadora en un rango de fechas

**Descripción:** El usuario desea obtener el listado de descuentos otorgados en multas municipales para la recaudadora 3 entre el 1 y el 30 de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de pagos y descuentos para la recaudadora 3 en el rango de fechas.

**Pasos a seguir:**
1. Ingresar '3' en el campo Recaudadora.
2. Seleccionar '2024-06-01' como fecha Desde.
3. Seleccionar '2024-06-30' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con todos los descuentos otorgados en multas para la recaudadora 3 en el rango de fechas especificado, incluyendo todos los campos del reporte.

**Datos de prueba:**
recaud: 3, fini: 2024-06-01, ffin: 2024-06-30

---

## Caso de Uso 2: Consulta sin resultados (rango de fechas sin datos)

**Descripción:** El usuario consulta un rango de fechas donde no existen descuentos otorgados.

**Precondiciones:**
No existen registros de descuentos para la recaudadora 2 entre el 2023-01-01 y 2023-01-31.

**Pasos a seguir:**
1. Ingresar '2' en el campo Recaudadora.
2. Seleccionar '2023-01-01' como fecha Desde.
3. Seleccionar '2023-01-31' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
La tabla de resultados aparece vacía y se muestra 'Total de pagos: 0'.

**Datos de prueba:**
recaud: 2, fini: 2023-01-01, ffin: 2023-01-31

---

## Caso de Uso 3: Error por parámetros inválidos (fecha fin menor a fecha inicio)

**Descripción:** El usuario ingresa una fecha final anterior a la fecha inicial.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar '1' en el campo Recaudadora.
2. Seleccionar '2024-07-01' como fecha Desde.
3. Seleccionar '2024-06-01' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros de fecha son inválidos.

**Datos de prueba:**
recaud: 1, fini: 2024-07-01, ffin: 2024-06-01

---

