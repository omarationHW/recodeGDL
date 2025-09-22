# Casos de Uso - sQRptPagosXContrato

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por contrato hospitalario

**Descripción:** El usuario desea consultar todos los pagos realizados para un contrato específico con tipo de aseo hospitalario.

**Precondiciones:**
El contrato con control_contrato = 1001 existe y tiene pagos registrados con status_vigencia = 'P'.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '1001' en Control Contrato.
3. Ingresa '1001' en Contrato.
4. Selecciona 'HOSPITALARIO' (ctrol_aseo = 4).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados para el contrato 1001, sumatorias correctas y la etiqueta 'HOSPITALARIO'.

**Datos de prueba:**
{ "control": 1001, "contrato": 1001, "ctrol_aseo": 4 }

---

## Caso de Uso 2: Consulta de pagos por contrato ordinario sin resultados

**Descripción:** El usuario consulta un contrato que no tiene pagos registrados.

**Precondiciones:**
El contrato con control_contrato = 9999 no tiene pagos con status_vigencia = 'P'.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '9999' en Control Contrato.
3. Ingresa '9999' en Contrato.
4. Selecciona 'ORDINARIO' (ctrol_aseo = 8).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
{ "control": 9999, "contrato": 9999, "ctrol_aseo": 8 }

---

## Caso de Uso 3: Consulta de pagos por contrato zona centro con varios tipos de adeudo

**Descripción:** El usuario consulta un contrato con pagos de diferentes tipos de adeudo (CUOTA NORMAL, EXCEDENTE, CONTENEDORES).

**Precondiciones:**
El contrato con control_contrato = 2002 tiene pagos de los tres tipos de adeudo.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '2002' en Control Contrato.
3. Ingresa '2002' en Contrato.
4. Selecciona 'ZONA CENTRO' (ctrol_aseo = 9).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los pagos, y las sumatorias por tipo de adeudo reflejan correctamente los importes y cantidades.

**Datos de prueba:**
{ "control": 2002, "contrato": 2002, "ctrol_aseo": 9 }

---

