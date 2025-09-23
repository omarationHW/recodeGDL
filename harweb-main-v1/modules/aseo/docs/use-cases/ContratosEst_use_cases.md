# Casos de Uso - ContratosEst

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadístico General de Contratos Vigentes

**Descripción:** El usuario desea obtener un resumen de contratos y adeudos vigentes agrupados por tipo de aseo.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y adeudos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página Estadístico de Contratos.
2. Selecciona 'VIGENTES' en Vigencia de Contratos.
3. Selecciona 'Todos' en Oficina y Tipo de Aseo.
4. Selecciona 'CON ADEUDOS' y 'POR PERIODO DE ADEUDO'.
5. Ingresa el periodo de inicio y fin (ej: 2023-01 a 2023-12).
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los totales de contratos y adeudos vigentes por tipo de aseo.

**Datos de prueba:**
Contratos con status_vigencia='V', adeudos con status_vigencia='V', periodo entre 2023-01 y 2023-12.

---

## Caso de Uso 2: Reporte de Contratos Cancelados en una Oficina Específica

**Descripción:** El usuario desea ver el estadístico de contratos cancelados en la oficina 'Recaudadora Centro'.

**Precondiciones:**
Existen contratos cancelados en la oficina seleccionada.

**Pasos a seguir:**
1. Accede a la página Estadístico de Contratos.
2. Selecciona 'CANCELADOS' en Vigencia de Contratos.
3. Selecciona 'Recaudadora Centro' en Oficina.
4. Selecciona 'Todos los tipos' en Tipo de Aseo.
5. Selecciona 'CON ADEUDOS' y 'HISTORICO'.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra la tabla con los totales de contratos y adeudos cancelados en la oficina seleccionada.

**Datos de prueba:**
Contratos con status_vigencia='C', id_rec=1.

---

## Caso de Uso 3: Estadístico de Adeudos Pagados por Fecha de Pago

**Descripción:** El usuario quiere ver el resumen de adeudos pagados en un rango de fechas.

**Precondiciones:**
Existen pagos registrados en el rango de fechas.

**Pasos a seguir:**
1. Accede a la página Estadístico de Contratos.
2. Selecciona 'TODOS' en Vigencia de Contratos.
3. Selecciona 'Todos' en Oficina y Tipo de Aseo.
4. Selecciona 'PAGADOS' en Vigencia de Adeudos.
5. Selecciona 'POR PERIODO DE PAGO'.
6. Ingresa la fecha de inicio y fin (ej: 2023-06-01 a 2023-06-30).
7. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra la tabla con los totales de adeudos pagados en el rango de fechas seleccionado.

**Datos de prueba:**
Adeudos con status_vigencia='P', fecha_hora_pago entre 2023-06-01 y 2023-06-30.

---

