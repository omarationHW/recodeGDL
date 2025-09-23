# Casos de Uso - IndividualPredios

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenio Individual de Predio

**Descripción:** El usuario consulta el detalle de un convenio de regularización de predio, visualizando los datos generales y el estado de cuenta.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existe un convenio con id_conv_predio=12345.

**Pasos a seguir:**
- El usuario accede a la página /predios/individual/12345
- El frontend envía eRequest con action 'getPredioById' y params { id_conv_predio: 12345 }
- El backend responde con los datos del predio
- El frontend muestra los datos generales
- El frontend envía eRequest con action 'getAdeudosByPredio' y params { id_conv_resto, fecha }
- El backend responde con la lista de adeudos y recargos
- El frontend muestra la tabla de parcialidades vencidas
- El frontend envía eRequest con action 'getTotPagadoByPredio' y params { id_conv_resto }
- El backend responde con el total pagado
- El frontend calcula y muestra los totales

**Resultado esperado:**
El usuario visualiza correctamente los datos del convenio, el estado de cuenta y la lista de parcialidades vencidas.

**Datos de prueba:**
{ id_conv_predio: 12345, fecha: '2024-06-01' }

---

## Caso de Uso 2: Cálculo de Recargos para Parcialidad Vencida

**Descripción:** El sistema calcula el recargo correspondiente a una parcialidad vencida de un convenio.

**Precondiciones:**
Existe un adeudo con id_conv_resto=6789, importe=1000.00, fecha_venc='2024-05-01', fecha_actual='2024-06-01'.

**Pasos a seguir:**
- El frontend envía eRequest con action 'getRecargosByAdeudo' y params { id_conv_resto: 6789, importe: 1000.00, fecha_venc: '2024-05-01', fecha_actual: '2024-06-01' }
- El backend ejecuta el SP de cálculo de recargos
- El backend responde con el valor calculado

**Resultado esperado:**
El backend responde con el recargo calculado según la lógica de negocio.

**Datos de prueba:**
{ id_conv_resto: 6789, importe: 1000.00, fecha_venc: '2024-05-01', fecha_actual: '2024-06-01' }

---

## Caso de Uso 3: Detalle de Pagos del Convenio

**Descripción:** El usuario navega al detalle de pagos del convenio desde la página de consulta individual.

**Precondiciones:**
El usuario está en la página de consulta individual de un convenio con id_conv_predio=12345.

**Pasos a seguir:**
- El usuario hace clic en el botón 'Detalle Pagos'
- El frontend navega a la ruta /predios/individual/12345/pagos
- El frontend carga el componente de detalle de pagos y solicita los datos vía API

**Resultado esperado:**
El usuario visualiza la lista de pagos realizados para el convenio seleccionado.

**Datos de prueba:**
{ id_conv_predio: 12345 }

---

