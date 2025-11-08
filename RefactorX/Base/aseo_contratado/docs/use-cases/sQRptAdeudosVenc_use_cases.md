# Casos de Uso - sQRptAdeudosVenc

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vencidos de un Contrato Existente

**Descripción:** El usuario consulta el estado de cuenta de adeudos vencidos para un contrato válido, sin especificar periodo.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos registrados.

**Pasos a seguir:**
1. Ingresar el número de contrato en el formulario.
2. Hacer clic en 'Consultar Estado de Cuenta'.
3. El sistema muestra la empresa, los adeudos vencidos, recargos y totales.

**Resultado esperado:**
Se muestra la tabla de adeudos vencidos, con recargos calculados y totales correctos.

**Datos de prueba:**
control_contrato: 1228

---

## Caso de Uso 2: Consulta de Adeudos Vencidos con Periodo Específico

**Descripción:** El usuario consulta los adeudos vencidos de un contrato, especificando un periodo límite.

**Precondiciones:**
El contrato existe y tiene adeudos en el rango de periodos.

**Pasos a seguir:**
1. Ingresar el número de contrato y el periodo (ej: 2024-06).
2. Hacer clic en 'Consultar Estado de Cuenta'.
3. El sistema muestra los adeudos hasta el periodo indicado.

**Resultado esperado:**
Se muestran solo los adeudos hasta el periodo especificado, con recargos y totales.

**Datos de prueba:**
control_contrato: 1228, periodo: '2024-06'

---

## Caso de Uso 3: Consulta de Contrato sin Adeudos Vencidos

**Descripción:** El usuario consulta un contrato que no tiene adeudos vencidos.

**Precondiciones:**
El contrato existe pero no tiene adeudos vencidos.

**Pasos a seguir:**
1. Ingresar el número de contrato sin adeudos.
2. Hacer clic en 'Consultar Estado de Cuenta'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay adeudos vencidos.

**Datos de prueba:**
control_contrato: 9999

---

