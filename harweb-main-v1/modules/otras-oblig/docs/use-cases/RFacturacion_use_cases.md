# Casos de Uso - RFacturacion

**Categoría:** Form

## Caso de Uso 1: Consulta de Facturación del Periodo Actual

**Descripción:** El usuario desea obtener el reporte de facturación del rastro para el periodo actual (año y mes en curso), incluyendo adeudos y pagos, sin recargos.

**Precondiciones:**
El usuario tiene acceso a la página y existen datos de facturación para el periodo actual.

**Pasos a seguir:**
1. Ingresar a la página de Facturación Rastro.
2. Seleccionar 'Adeudos y Pagos' en Tipo de Adeudo.
3. Dejar desmarcada la opción 'Adeudos con recargos'.
4. Seleccionar 'Periodo Actual'.
5. Hacer clic en 'Previa'.

**Resultado esperado:**
Se muestra una tabla con los registros de facturación del periodo actual, sumando adeudos y pagos, sin incluir recargos. El total se muestra correctamente.

**Datos de prueba:**
{ "adeudo_status": "A", "adeudo_recargo": "N", "year": 2024, "month": 6, "periodo_actual": true }

---

## Caso de Uso 2: Consulta de Solo Adeudos con Recargos de un Periodo Anterior

**Descripción:** El usuario requiere ver únicamente los adeudos con recargos del mes de marzo de 2023.

**Precondiciones:**
Existen registros de adeudos con recargos para marzo 2023.

**Pasos a seguir:**
1. Ingresar a la página de Facturación Rastro.
2. Seleccionar 'Solo Adeudos' en Tipo de Adeudo.
3. Marcar la opción 'Adeudos con recargos'.
4. Seleccionar 'Otro Periodo'.
5. Ingresar año '2023' y mes '3' (Marzo).
6. Hacer clic en 'Previa'.

**Resultado esperado:**
Se muestra la tabla solo con los adeudos con recargos del periodo seleccionado. El total corresponde a la suma de los importes mostrados.

**Datos de prueba:**
{ "adeudo_status": "B", "adeudo_recargo": "S", "year": 2023, "month": 3, "periodo_actual": false }

---

## Caso de Uso 3: Consulta de Solo Pagados de un Periodo Específico

**Descripción:** El usuario desea ver únicamente los pagos realizados en diciembre de 2022.

**Precondiciones:**
Existen registros de pagos en diciembre 2022.

**Pasos a seguir:**
1. Ingresar a la página de Facturación Rastro.
2. Seleccionar 'Solo Pagados' en Tipo de Adeudo.
3. Seleccionar 'Otro Periodo'.
4. Ingresar año '2022' y mes '12' (Diciembre).
5. Hacer clic en 'Previa'.

**Resultado esperado:**
Se muestra la tabla solo con los registros pagados del periodo seleccionado. El total corresponde a la suma de los importes mostrados.

**Datos de prueba:**
{ "adeudo_status": "C", "adeudo_recargo": "N", "year": 2022, "month": 12, "periodo_actual": false }

---

