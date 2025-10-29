# Casos de Uso - prepagofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de resumen de prepago para un contribuyente

**Descripción:** El usuario ingresa a la página de prepago de un contribuyente y visualiza el resumen de adeudo, periodos, descuentos y último requerimiento.

**Precondiciones:**
El contribuyente existe y tiene adeudos registrados.

**Pasos a seguir:**
- El usuario navega a `/prepago/12345`.
- El sistema carga el resumen, periodos, descuentos y último requerimiento usando la API.
- El usuario visualiza toda la información en pantalla.

**Resultado esperado:**
Se muestra correctamente el resumen del contribuyente, periodos de adeudo, descuentos aplicados y último requerimiento practicado.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 2: Simulación de liquidación parcial

**Descripción:** El usuario desea simular el pago parcial de los primeros 3 bimestres del año actual.

**Precondiciones:**
El contribuyente tiene adeudos en el año actual.

**Pasos a seguir:**
- El usuario ingresa a `/prepago/12345`.
- En el formulario de liquidación parcial, selecciona bimestre final 3 y año actual.
- Hace clic en 'Calcular Parcial'.
- El sistema muestra el resumen parcial de pago.

**Resultado esperado:**
Se muestra el cálculo parcial de impuesto, recargos, gastos, multa y total a pagar para el periodo seleccionado.

**Datos de prueba:**
{ "cvecuenta": 12345, "asalf": 2024, "bsalf": 3 }

---

## Caso de Uso 3: Visualización de descuentos aplicados

**Descripción:** El usuario desea ver los descuentos aplicados en el periodo de adeudo.

**Precondiciones:**
El contribuyente tiene descuentos registrados en el periodo.

**Pasos a seguir:**
- El usuario ingresa a `/prepago/12345`.
- Activa la casilla 'Mostrar descuentos'.
- El sistema muestra la tabla de descuentos aplicados.

**Resultado esperado:**
Se listan todos los descuentos aplicados, con su descripción e importe.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

