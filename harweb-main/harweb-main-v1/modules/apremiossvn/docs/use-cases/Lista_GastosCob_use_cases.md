# Casos de Uso - Lista_GastosCob

**Categoría:** Form

## Caso de Uso 1: Consulta de Gastos de Cobranza por Recaudadora

**Descripción:** El usuario desea consultar todos los pagos de gastos de cobranza realizados en la recaudadora 1 entre el 1 y el 31 de enero de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en ese rango de fechas.

**Pasos a seguir:**
1. El usuario accede a la página 'Gastos Cobrados'.
2. Selecciona la recaudadora '1'.
3. Ingresa '2024-01-01' como fecha desde y '2024-01-31' como fecha hasta.
4. Selecciona 'Oficina Ingresos' como tipo de consulta.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos de gastos de cobranza realizados en la recaudadora 1 en el rango de fechas indicado, incluyendo totales.

**Datos de prueba:**
Pagos en ta_12_recibos con id_rec=1, fecha entre 2024-01-01 y 2024-01-31, impte_gastos > 0.

---

## Caso de Uso 2: Exportación de Resultados a Excel

**Descripción:** El usuario desea exportar los resultados de la consulta anterior a un archivo Excel/CSV.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar Excel'.
2. El sistema genera y descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene todas las filas y columnas de la tabla de resultados.

**Datos de prueba:**
Resultados de la consulta anterior.

---

## Caso de Uso 3: Consulta de Gastos de Cobranza por Oficina Apremios

**Descripción:** El usuario desea consultar los pagos de gastos de cobranza realizados por la Oficina Apremios (tipo_consulta='apremios') para la recaudadora 2 en febrero de 2024.

**Precondiciones:**
El usuario tiene acceso y existen pagos en ese rango.

**Pasos a seguir:**
1. El usuario accede a la página 'Gastos Cobrados'.
2. Selecciona la recaudadora '2'.
3. Ingresa '2024-02-01' como fecha desde y '2024-02-29' como fecha hasta.
4. Selecciona 'Oficina Apremios' como tipo de consulta.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con los pagos correspondientes a la Oficina Apremios para la recaudadora 2 en febrero de 2024.

**Datos de prueba:**
Pagos en ta_12_recibos con id_rec=2, fecha entre 2024-02-01 y 2024-02-29, impte_gastos > 0.

---

