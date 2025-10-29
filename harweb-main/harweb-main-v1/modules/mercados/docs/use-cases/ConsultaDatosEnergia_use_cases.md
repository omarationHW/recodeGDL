# Casos de Uso - ConsultaDatosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Energía de un Local con Adeudos y Requerimientos

**Descripción:** El usuario consulta los datos de energía de un local que tiene adeudos y requerimientos activos.

**Precondiciones:**
El local existe y tiene registros en ta_11_energia, ta_11_adeudo_energ y ta_15_apremios.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta Datos de Energía'.
2. Ingresa el ID del local (por ejemplo, 12345) y presiona 'Buscar'.
3. El sistema muestra los datos generales de energía.
4. El sistema muestra la tabla de requerimientos asociados.
5. El sistema muestra la tabla de adeudos por mes, con recargos calculados.
6. El usuario puede ver el resumen de adeudos, recargos, multas y gastos.

**Resultado esperado:**
Se muestran correctamente los datos de energía, requerimientos, adeudos y el resumen total.

**Datos de prueba:**
{ "id_local": 12345 }

---

## Caso de Uso 2: Visualización de Pagos de Energía

**Descripción:** El usuario consulta los pagos realizados para la energía de un local.

**Precondiciones:**
El local tiene pagos registrados en ta_11_pago_energia.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de energía para un local.
2. Hace clic en 'Ver Pagos'.
3. El sistema consulta y muestra la tabla de pagos realizados.

**Resultado esperado:**
Se muestran todos los pagos de energía asociados al local.

**Datos de prueba:**
{ "id_local": 12345 }

---

## Caso de Uso 3: Consulta de Condonaciones de Energía

**Descripción:** El usuario consulta las condonaciones aplicadas a la energía de un local.

**Precondiciones:**
El local tiene condonaciones registradas en ta_11_ade_ene_canc.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de energía para un local.
2. Hace clic en 'Ver Condonaciones'.
3. El sistema consulta y muestra la tabla de condonaciones.

**Resultado esperado:**
Se muestran todas las condonaciones de energía asociadas al local.

**Datos de prueba:**
{ "id_local": 12345 }

---

