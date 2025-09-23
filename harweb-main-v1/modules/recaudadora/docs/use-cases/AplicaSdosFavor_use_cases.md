# Casos de Uso - AplicaSdosFavor

**Categoría:** Form

## Caso de Uso 1: Consulta y Alta de Saldo a Favor

**Descripción:** El usuario busca una solicitud de inconformidad y registra un saldo a favor.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el folio y año de la inconformidad.

**Pasos a seguir:**
1. El usuario ingresa el folio y año en el formulario y presiona 'Buscar'.
2. El sistema muestra los datos de la inconformidad y la cuenta.
3. El usuario ingresa el importe a favor y presiona 'Registrar Saldo a Favor'.

**Resultado esperado:**
El saldo a favor queda registrado y visible en la pantalla.

**Datos de prueba:**
folio: 12345, axofol: 2024, importe: 1500.00

---

## Caso de Uso 2: Aplicar Saldo a Favor a Adeudos

**Descripción:** El usuario aplica el saldo a favor a los adeudos de la cuenta.

**Precondiciones:**
Existe un saldo a favor registrado y la cuenta tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca la solicitud y visualiza el saldo a favor.
2. El usuario ingresa el rango de bimestres/años y el importe a aplicar.
3. El usuario presiona 'Aplicar'.

**Resultado esperado:**
El saldo se aplica correctamente, se actualizan los adeudos y el saldo a favor restante.

**Datos de prueba:**
id_solic: 1, cvecuenta: 1001, bimi: 1, axoi: 2024, bimf: 3, axof: 2024, importe: 1200.00

---

## Caso de Uso 3: Consulta de Detalle de Saldos

**Descripción:** El usuario consulta el detalle de saldos de la cuenta para verificar adeudos.

**Precondiciones:**
La cuenta existe y tiene adeudos.

**Pasos a seguir:**
1. El usuario busca la solicitud y visualiza la cuenta.
2. El sistema muestra el detalle de saldos en la tabla inferior.

**Resultado esperado:**
Se visualizan los bimestres/años con adeudo, impuestos y recargos.

**Datos de prueba:**
cvecuenta: 1001

---

