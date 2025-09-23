# Casos de Uso - RptEdoCuenta

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta por Tipo/Subtipo

**Descripción:** El usuario desea consultar todos los convenios de regularización de predios para un tipo y subtipo específicos.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo EdoCuenta.

**Pasos a seguir:**
1. El usuario accede a la página EdoCuenta.
2. Selecciona un tipo y subtipo en el formulario.
3. Presiona 'Consultar Estado de Cuenta'.
4. El sistema envía un eRequest con action 'getEdoCuenta' y los parámetros seleccionados.
5. El backend responde con la lista de convenios encontrados.

**Resultado esperado:**
Se muestra una tabla con los convenios encontrados, incluyendo datos de manzana, lote, letra, nombre, domicilio y cantidad total.

**Datos de prueba:**
{ "tipo": 14, "subtipo": 1 }

---

## Caso de Uso 2: Visualización de Detalle de Convenio

**Descripción:** El usuario desea ver el detalle de pagos y adeudos de un convenio específico.

**Precondiciones:**
El usuario ya realizó una consulta de estado de cuenta y tiene la lista de convenios.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver Detalle' de un convenio.
2. El frontend solicita los pagos y adeudos del convenio usando 'getPagos' y 'getAdeudos'.
3. El backend responde con los datos correspondientes.

**Resultado esperado:**
Se muestran dos tablas: una con los pagos realizados y otra con los adeudos (parcialidades) y recargos calculados.

**Datos de prueba:**
{ "id_conv_resto": 12345 }

---

## Caso de Uso 3: Cálculo de Recargos para un Periodo

**Descripción:** El sistema debe calcular el porcentaje de recargos aplicable a un periodo específico.

**Precondiciones:**
El usuario está consultando los adeudos de un convenio.

**Pasos a seguir:**
1. El frontend solicita el cálculo de recargos usando 'getRecargos' con los parámetros del periodo.
2. El backend ejecuta el SP y responde con el porcentaje calculado.

**Resultado esperado:**
El frontend recibe el porcentaje de recargos correcto según la lógica migrada.

**Datos de prueba:**
{ "alov": 2022, "mesv": 3, "alo": 2024, "mes": 6, "dia": 15, "diav": 10 }

---

