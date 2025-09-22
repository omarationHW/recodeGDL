# Casos de Uso - Adeudos_Nvo

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta Concentrado - Periodos Vencidos

**Descripción:** El usuario consulta el estado de cuenta concentrado de un contrato para los periodos vencidos.

**Precondiciones:**
El contrato y tipo de aseo existen y están vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Periodos Vencidos'.
3. Da clic en 'Consultar Estado de Cuenta'.
4. El sistema muestra el resumen de adeudos, recargos, multas, gastos y actualización.

**Resultado esperado:**
Se muestra una tabla con los totales por concepto para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 8, "vigencia": "V" }

---

## Caso de Uso 2: Consulta de Estado de Cuenta Detallado - Otro Periodo

**Descripción:** El usuario consulta el estado de cuenta detallado de un contrato para un periodo específico.

**Precondiciones:**
El contrato y tipo de aseo existen.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Otro Periodo'.
3. Ingresa año '2023' y mes '05'.
4. Da clic en 'Consultar Estado de Cuenta'.
5. El sistema muestra el detalle por concepto y periodo.

**Resultado esperado:**
Se muestra una tabla detallada con los conceptos, cantidades y montos para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": 54321, "ctrol_aseo": 4, "vigencia": "O", "anio": "2023", "mes": "05" }

---

## Caso de Uso 3: Impresión de Estado de Cuenta F02

**Descripción:** El usuario imprime el estado de cuenta F02 para un contrato y periodo.

**Precondiciones:**
El contrato existe y tiene adeudos en el periodo solicitado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. Selecciona el periodo deseado.
3. Da clic en 'Imprimir Detallado'.
4. El sistema genera la vista previa de impresión F02.

**Resultado esperado:**
Se muestra la vista previa de impresión con los datos F02.

**Datos de prueba:**
{ "tipo": "O", "numero": 12345, "rep": "V", "pref": "2024-06" }

---

