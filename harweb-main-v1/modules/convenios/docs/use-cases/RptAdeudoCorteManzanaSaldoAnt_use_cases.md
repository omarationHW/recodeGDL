# Casos de Uso - RptAdeudoCorteManzanaSaldoAnt

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de corte por manzana con saldo anterior

**Descripción:** El usuario desea obtener el reporte de convenios de regularización de predios, agrupados por manzana, mostrando el saldo anterior, pagos y saldo actual.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar reportes. Existen datos de convenios y pagos en la base de datos.

**Pasos a seguir:**
- El usuario accede a la página de reporte.
- Selecciona un subtipo de predio.
- Selecciona la fecha desde y hasta.
- Selecciona el estado (VIGENTES, BAJA, PAGADOS).
- Selecciona el tipo de reporte (Saldo Ant.).
- Presiona 'Consultar'.
- El sistema muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los predios agrupados por manzana, mostrando el saldo anterior, pagos realizados y saldo actual.

**Datos de prueba:**
subtipo: 1, fechadsd: '2024-01-01', fechahst: '2024-06-30', rep: 2, est: 'A'

---

## Caso de Uso 2: Validación de parámetros obligatorios

**Descripción:** El usuario intenta consultar el reporte sin seleccionar la fecha desde.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- El usuario deja el campo 'Fecha Desde' vacío.
- Presiona 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la fecha desde es obligatoria.

**Datos de prueba:**
subtipo: 1, fechadsd: '', fechahst: '2024-06-30', rep: 2, est: 'A'

---

## Caso de Uso 3: Consulta de saldo anterior de un predio

**Descripción:** El sistema debe mostrar el saldo anterior de un predio antes de una fecha dada.

**Precondiciones:**
El usuario está autenticado. El predio existe y tiene pagos registrados.

**Pasos a seguir:**
- El usuario solicita el saldo anterior para un predio específico y fecha.
- El sistema ejecuta el stored procedure correspondiente.

**Resultado esperado:**
Se retorna el saldo anterior correctamente calculado.

**Datos de prueba:**
subtipo: 1, id_conv_predio: 123, fechadsd: '2024-01-01'

---

