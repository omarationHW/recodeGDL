# Casos de Uso - CalculoRecargos

**Categoría:** Form

## Caso de Uso 1: Cálculo de Recargos para Contrato Vencido sin Requerimientos

**Descripción:** El usuario desea calcular los recargos de un contrato vencido que no tiene requerimientos/apremios.

**Precondiciones:**
El contrato existe, está vencido, y no tiene registros en ta_15_apremios.

**Pasos a seguir:**
1. El usuario ingresa el ID del contrato en la página.
2. El sistema carga los datos del contrato y muestra los importes.
3. El usuario selecciona 'Pago Inicial' y 'Pago Parcial', elige 2 parcialidades a pagar.
4. El usuario presiona 'Calcular Recargos'.
5. El sistema calcula el importe a pagar y los recargos usando el porcentaje de recargos correspondiente.

**Resultado esperado:**
Se muestra el importe a pagar, el importe de recargos calculado con el porcentaje de recargos (o 100% si el porcentaje es mayor a 100), y el porcentaje aplicado.

**Datos de prueba:**
{ "id_convenio": 123, "fecha_vencimiento": "2023-01-01", "pago_inicial": 1000, "pago_quincenal": 500, "pagos_parciales": 10, "pagos_a_realizar": 2, "requerimientos": [] }

---

## Caso de Uso 2: Cálculo de Recargos para Contrato Vencido con Requerimientos

**Descripción:** El usuario calcula recargos para un contrato vencido que tiene requerimientos/apremios.

**Precondiciones:**
El contrato existe, está vencido, y tiene al menos un registro en ta_15_apremios.

**Pasos a seguir:**
1. El usuario ingresa el ID del contrato.
2. El sistema carga los datos y detecta requerimientos.
3. El usuario selecciona 'Sin Pago Inicial' y 'Pago Parcial', elige 3 parcialidades.
4. El usuario presiona 'Calcular Recargos'.
5. El sistema calcula el importe a pagar y los recargos usando el porcentaje de recargos (o 250% si el porcentaje es mayor a 250).

**Resultado esperado:**
Se muestra el importe a pagar, el importe de recargos calculado con el porcentaje de recargos (o 250% si corresponde), y el porcentaje aplicado.

**Datos de prueba:**
{ "id_convenio": 456, "fecha_vencimiento": "2022-12-01", "pago_inicial": 0, "pago_quincenal": 600, "pagos_parciales": 8, "pagos_a_realizar": 3, "requerimientos": [{...}] }

---

## Caso de Uso 3: Error por Exceso de Parcialidades

**Descripción:** El usuario intenta calcular recargos para más parcialidades de las permitidas.

**Precondiciones:**
El contrato tiene 5 pagos parciales permitidos.

**Pasos a seguir:**
1. El usuario ingresa el ID del contrato.
2. El sistema carga los datos.
3. El usuario selecciona 'Pago Inicial' y 'Pago Parcial', elige 6 parcialidades a pagar.
4. El usuario presiona 'Calcular Recargos'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Error... Los Pagos a Realizar Exceden de 5'.

**Datos de prueba:**
{ "id_convenio": 789, "fecha_vencimiento": "2023-05-01", "pago_inicial": 500, "pago_quincenal": 400, "pagos_parciales": 5, "pagos_a_realizar": 6, "requerimientos": [] }

---

