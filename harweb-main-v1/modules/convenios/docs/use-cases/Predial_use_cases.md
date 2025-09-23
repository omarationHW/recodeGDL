# Casos de Uso - Predial

**Categoría:** Form

## Caso de Uso 1: Consulta y Pago de Cuenta Predial Vigente

**Descripción:** El usuario busca una cuenta predial vigente, revisa los adeudos y realiza el pago total en efectivo.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los datos de la cuenta predial.

**Pasos a seguir:**
1. Acceder a la página /predial
2. Ingresar recaudadora, urb-rus y número de cuenta
3. Presionar 'Buscar'
4. Revisar los datos del contribuyente y detalle de adeudos
5. Seleccionar forma de pago 'Efectivo'
6. Confirmar el pago
7. El sistema registra el pago y muestra mensaje de éxito

**Resultado esperado:**
El pago se registra correctamente, el usuario recibe confirmación y puede imprimir el recibo.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 123456 }

---

## Caso de Uso 2: Pago con Cheque y Aportación Voluntaria

**Descripción:** El usuario realiza el pago de predial con cheque e incluye una aportación voluntaria.

**Precondiciones:**
La cuenta predial tiene adeudos y el usuario tiene los datos del cheque.

**Pasos a seguir:**
1. Buscar la cuenta predial
2. Revisar los adeudos
3. Seleccionar forma de pago 'Cheque'
4. Ingresar datos del cheque (banco, número, importe)
5. Activar la casilla de aportación voluntaria
6. Confirmar el pago

**Resultado esperado:**
El pago se registra con los datos del cheque y la aportación voluntaria, el recibo refleja ambos conceptos.

**Datos de prueba:**
{ "recaud": 2, "urbrus": "R", "cuenta": 654321, "cheque": { "banco": "BANAMEX", "numero": "1234567", "importe": 1500 } }

---

## Caso de Uso 3: Mostrar Descuentos Aplicados

**Descripción:** El usuario consulta los descuentos aplicados a una cuenta predial en el periodo actual.

**Precondiciones:**
La cuenta predial tiene descuentos vigentes.

**Pasos a seguir:**
1. Buscar la cuenta predial
2. Hacer clic en 'Mostrar Descuentos'
3. El sistema muestra la lista de descuentos aplicados

**Resultado esperado:**
Se muestran correctamente los descuentos aplicados a la cuenta.

**Datos de prueba:**
{ "cvecuenta": 123456, "asal": 1900, "bsal": 1, "asalf": 2024, "bsalf": 6 }

---

