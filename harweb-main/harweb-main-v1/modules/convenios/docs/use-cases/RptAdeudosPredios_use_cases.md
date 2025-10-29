# Casos de Uso - RptAdeudosPredios

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vigentes de Predios por Subtipo

**Descripción:** El usuario desea obtener el listado de adeudos vigentes de predios para un subtipo específico al día de hoy.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de predios con adeudos.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos Predios.
2. Selecciona el subtipo deseado del listado.
3. Selecciona la fecha de corte (por defecto, hoy).
4. Selecciona el estado 'VIGENTES'.
5. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los predios, sus datos y los totales de costo, pagos, recargos y saldo.

**Datos de prueba:**
subtipo: 1, fecha_hasta: '2024-06-10', estado: 'A'

---

## Caso de Uso 2: Reporte de Adeudos de Predios con Saldo Anterior

**Descripción:** El usuario requiere ver los adeudos de predios considerando pagos realizados en un rango de fechas y el saldo anterior.

**Precondiciones:**
Existen pagos registrados en el rango de fechas para el subtipo seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos Predios.
2. Selecciona el subtipo.
3. Selecciona el rango de fechas (fecha_desde y fecha_hasta).
4. Selecciona el estado 'VIGENTES'.
5. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los campos de saldo anterior, pagos en el periodo y saldo actual.

**Datos de prueba:**
subtipo: 2, fecha_desde: '2024-01-01', fecha_hasta: '2024-06-10', estado: 'A'

---

## Caso de Uso 3: Validación de Parámetros y Manejo de Errores

**Descripción:** El usuario intenta consultar el reporte sin seleccionar un subtipo.

**Precondiciones:**
El usuario está en la página de Adeudos Predios.

**Pasos a seguir:**
1. El usuario deja el campo subtipo vacío.
2. Presiona el botón 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el subtipo es requerido.

**Datos de prueba:**
subtipo: '', fecha_hasta: '2024-06-10', estado: 'A'

---

