# Casos de Uso - Adeudos_EdoCta

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta Vigente

**Descripción:** El usuario consulta el estado de cuenta de un contrato vigente para el periodo actual.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Periodos Vigentes'.
3. Presiona 'Procesar'.
4. El sistema ejecuta los stored procedures y muestra el detalle de pagos.

**Resultado esperado:**
Se muestra el detalle de pagos y totales para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "vigencia": "V" }

---

## Caso de Uso 2: Consulta de Estado de Cuenta para Otro Periodo

**Descripción:** El usuario consulta el estado de cuenta de un contrato para un periodo específico (año y mes).

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Otro Periodo'.
3. Ingresa el año y mes deseados.
4. Presiona 'Procesar'.
5. El sistema ejecuta los stored procedures y muestra el detalle de pagos para ese periodo.

**Resultado esperado:**
Se muestra el detalle de pagos y totales para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "vigencia": "A", "ejercicio": 2023, "mes": "03" }

---

## Caso de Uso 3: Error al Consultar Contrato Inexistente

**Descripción:** El usuario intenta consultar un contrato que no existe.

**Precondiciones:**
El contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un número de contrato inexistente y selecciona el tipo de aseo.
2. Presiona 'Procesar'.
3. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no existen contratos con esos datos.

**Datos de prueba:**
{ "contrato": "99999", "ctrol_aseo": 9, "vigencia": "V" }

---

