# Casos de Uso - prepagofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudo y Descuentos de Cuenta Predial

**Descripción:** El usuario consulta el adeudo y los descuentos aplicados a una cuenta predial específica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de cuenta catastral.

**Pasos a seguir:**
- El usuario ingresa el número de cuenta catastral en el formulario Prepago.
- Presiona 'Buscar'.
- El sistema muestra los datos del contribuyente y el detalle de adeudo.
- El usuario presiona 'Mostrar Descuentos'.
- El sistema muestra la tabla de descuentos aplicados.

**Resultado esperado:**
El usuario visualiza correctamente los datos del contribuyente, el detalle de adeudo y los descuentos aplicados.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 2: Liquidación Parcial de Adeudo

**Descripción:** El usuario realiza una liquidación parcial del adeudo predial hasta un año y bimestre específico.

**Precondiciones:**
El usuario tiene acceso al sistema y la cuenta tiene adeudo.

**Pasos a seguir:**
- El usuario ingresa la cuenta catastral y busca la información.
- Presiona 'Liquidación Parcial'.
- Ingresa el año y bimestre hasta el cual desea liquidar.
- Presiona 'Calcular'.
- El sistema muestra el resultado de la liquidación parcial.

**Resultado esperado:**
El sistema muestra el cálculo de liquidación parcial correctamente.

**Datos de prueba:**
{ "cvecuenta": 123456, "asalf": 2024, "bsalf": 4 }

---

## Caso de Uso 3: Recalcular Descuento Pronto Pago (DPP)

**Descripción:** El usuario solicita el recálculo del descuento pronto pago para una cuenta.

**Precondiciones:**
El usuario tiene acceso y la cuenta es elegible para DPP.

**Pasos a seguir:**
- El usuario ingresa la cuenta catastral y busca la información.
- Presiona 'Recalcular DPP'.
- El sistema ejecuta el recálculo y muestra el resultado.

**Resultado esperado:**
El sistema confirma que el recálculo se realizó correctamente.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

