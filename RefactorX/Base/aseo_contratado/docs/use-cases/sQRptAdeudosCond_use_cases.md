# Casos de Uso - sQRptAdeudosCond

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Condonados por Contrato y Periodo de Pago

**Descripción:** El usuario desea obtener el reporte de adeudos condonados para un contrato específico, clasificados por periodo de pago.

**Precondiciones:**
El contrato existe y tiene adeudos condonados registrados.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 1228).
3. Selecciona 'Periodo de Pago' como opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema muestra la tabla con los adeudos condonados clasificados por periodo de pago.

**Resultado esperado:**
Se muestra la lista de adeudos condonados para el contrato 1228, ordenados por periodo de pago, junto con los totales por contrato.

**Datos de prueba:**
{ "control_contrato": 1228, "opcion": 1 }

---

## Caso de Uso 2: Consulta de Adeudos Condonados por Contrato y Operación

**Descripción:** El usuario desea obtener el reporte de adeudos condonados para un contrato específico, clasificados por operación.

**Precondiciones:**
El contrato existe y tiene adeudos condonados registrados.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 1228).
3. Selecciona 'Operación' como opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema muestra la tabla con los adeudos condonados clasificados por operación.

**Resultado esperado:**
Se muestra la lista de adeudos condonados para el contrato 1228, ordenados por operación, junto con los totales por contrato.

**Datos de prueba:**
{ "control_contrato": 1228, "opcion": 2 }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario consulta un contrato que no tiene adeudos condonados.

**Precondiciones:**
El contrato existe pero no tiene adeudos condonados con status 'S'.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Adeudos Condonados'.
2. Ingresa el número de contrato (ejemplo: 9999).
3. Selecciona cualquier opción de clasificación.
4. Hace clic en 'Consultar'.
5. El sistema informa que no se encontraron datos.

**Resultado esperado:**
Se muestra un mensaje de advertencia indicando que no hay datos para los criterios seleccionados.

**Datos de prueba:**
{ "control_contrato": 9999, "opcion": 1 }

---

