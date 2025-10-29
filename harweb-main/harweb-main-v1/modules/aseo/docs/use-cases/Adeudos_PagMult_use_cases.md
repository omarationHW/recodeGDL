# Casos de Uso - Adeudos_PagMult

**Categoría:** Form

## Caso de Uso 1: Pago múltiple de excedencias vigentes de un contrato

**Descripción:** El usuario selecciona un contrato y tipo de aseo, visualiza los adeudos vigentes, selecciona varios y los da de pagado en una sola operación.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes de tipo excedencia.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario presiona 'Ver Adeudos Vigentes'.
5. El sistema muestra la lista de adeudos vigentes.
6. El usuario selecciona varios adeudos (checkbox).
7. El usuario llena los datos de pago (fecha, recaudadora, caja, consecutivo, folio).
8. Presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estatus a 'Pagado' y se actualizan los campos de pago.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 3 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo 1001, folio 'F123'

---

## Caso de Uso 2: Intento de pago sin seleccionar adeudos

**Descripción:** El usuario intenta ejecutar el pago sin seleccionar ningún adeudo.

**Precondiciones:**
El contrato tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato y visualiza los adeudos.
2. No selecciona ningún adeudo.
3. Llena los datos de pago y presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar al menos un adeudo.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 2 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo 1002, folio 'F124'

---

## Caso de Uso 3: Intento de pago con datos incompletos

**Descripción:** El usuario selecciona adeudos pero omite algún dato obligatorio de pago.

**Precondiciones:**
El contrato tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato y visualiza los adeudos.
2. Selecciona uno o más adeudos.
3. Omite llenar el campo 'Consecutivo de Operación'.
4. Presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe completar todos los datos de pago.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 2 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo vacío, folio 'F125'

---

