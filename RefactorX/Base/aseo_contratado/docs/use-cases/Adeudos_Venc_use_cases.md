# Casos de Uso - Adeudos_Venc

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vencidos Vigentes

**Descripción:** El usuario consulta los adeudos vencidos vigentes de un contrato específico.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario deja la opción 'Periodos Vigentes' seleccionada.
3. El usuario hace clic en 'Buscar'.
4. El sistema muestra los datos del contrato.
5. El usuario hace clic en 'Consultar Adeudos'.
6. El sistema muestra la lista de adeudos vencidos.

**Resultado esperado:**
Se muestra la lista de adeudos vencidos vigentes para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9 }

---

## Caso de Uso 2: Consulta de Adeudos de Otro Periodo

**Descripción:** El usuario consulta los adeudos de un contrato para un periodo específico (año y mes).

**Precondiciones:**
El contrato existe y tiene adeudos en el periodo seleccionado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario selecciona 'Otro Periodo' y elige año y mes.
3. El usuario hace clic en 'Buscar'.
4. El sistema muestra los datos del contrato.
5. El usuario hace clic en 'Consultar Adeudos'.
6. El sistema muestra la lista de adeudos para el periodo seleccionado.

**Resultado esperado:**
Se muestra la lista de adeudos para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "aso": 2023, "mes": 5 }

---

## Caso de Uso 3: Generación de Reporte de Adeudos Vencidos

**Descripción:** El usuario genera un reporte resumen de los adeudos vencidos de un contrato.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de contrato y consulta los adeudos.
2. El usuario hace clic en 'Ver Reporte'.
3. El sistema genera y muestra el resumen de adeudos (multas, recargos, gastos, total).

**Resultado esperado:**
Se muestra el resumen de adeudos con los totales correspondientes.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9 }

---

