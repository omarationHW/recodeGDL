# Casos de Uso - RptParcVencidasPredios

**Categoría:** Form

## Caso de Uso 1: Consulta de Parcialidades Vencidas Vigentes

**Descripción:** El usuario desea obtener el reporte de parcialidades vencidas de predios vigentes para un subtipo específico y una fecha de corte.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de convenios de predios en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Parcialidades Vencidas Predios'.
2. Selecciona el subtipo 'Residencial' (valor 1).
3. Selecciona la fecha de corte '2024-06-30'.
4. Selecciona el estado 'VIGENTES' (valor 'A').
5. Hace clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los predios, agrupados por manzana y lote, mostrando pagos al corriente, pagos vencidos, recargos y adeudos vigentes.

**Datos de prueba:**
{ "subtipo": 1, "fechahst": "2024-06-30", "est": "A" }

---

## Caso de Uso 2: Consulta de Parcialidades Vencidas Dadas de Baja

**Descripción:** El usuario requiere ver los predios dados de baja con parcialidades vencidas a una fecha determinada.

**Precondiciones:**
El usuario tiene acceso y existen predios dados de baja en la base.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Selecciona subtipo 'Comercial' (valor 2).
3. Selecciona fecha de corte '2024-05-31'.
4. Selecciona estado 'DADOS DE BAJA' (valor 'B').
5. Hace clic en 'Consultar'.

**Resultado esperado:**
Se listan los predios dados de baja con sus pagos y adeudos hasta la fecha seleccionada.

**Datos de prueba:**
{ "subtipo": 2, "fechahst": "2024-05-31", "est": "B" }

---

## Caso de Uso 3: Consulta de Parcialidades Vencidas Pagadas

**Descripción:** El usuario desea auditar los predios que ya han sido pagados completamente.

**Precondiciones:**
El usuario tiene acceso y existen predios con estado 'PAGADOS'.

**Pasos a seguir:**
1. Ingresa a la página de parcialidades vencidas.
2. Selecciona subtipo 'Industrial' (valor 3).
3. Selecciona fecha de corte '2024-04-30'.
4. Selecciona estado 'PAGADOS' (valor 'P').
5. Hace clic en 'Consultar'.

**Resultado esperado:**
Se muestran los predios pagados, sin adeudos pendientes.

**Datos de prueba:**
{ "subtipo": 3, "fechahst": "2024-04-30", "est": "P" }

---

