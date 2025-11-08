# Casos de Uso - GRep_Padron

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Concesiones con Adeudos Vigentes

**Descripción:** El usuario desea consultar el padrón de concesiones con adeudos vigentes para el rubro Rastro.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón con Adeudos'.
2. Selecciona 'TODOS' en Vigencia de la Concesión.
3. Selecciona 'Periodos Vencidos' como periodo.
4. Da clic en 'Buscar'.
5. El sistema muestra la lista de concesiones con adeudos vigentes.

**Resultado esperado:**
Se muestra una tabla con los concesionarios, control, superficie, etc. Solo aparecen los que tienen adeudos vigentes.

**Datos de prueba:**
par_tabla: 3, par_vigencia: 'TODOS', periodoTipo: 'vencidos', año: 2024, mes: 06

---

## Caso de Uso 2: Detalle de Adeudos de una Concesión Específica

**Descripción:** El usuario desea ver el detalle de adeudos de una concesión específica para un periodo determinado.

**Precondiciones:**
El usuario ya visualizó el padrón y seleccionó una concesión.

**Pasos a seguir:**
1. El usuario da clic en 'Ver' en la fila de la concesión deseada.
2. El sistema solicita el detalle de adeudos para ese control y periodo.
3. El sistema muestra el desglose de conceptos y montos.

**Resultado esperado:**
Se muestra una tabla con los conceptos de adeudo, montos, recargos, multas, gastos y actualización.

**Datos de prueba:**
par_tab: 3, par_control: 123, par_rep: 'V', par_fecha: '2024-06'

---

## Caso de Uso 3: Consulta de Padrón por Vigencia Específica

**Descripción:** El usuario desea consultar el padrón filtrando por una vigencia específica (por ejemplo, 'VIGENTE').

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón con Adeudos'.
2. Selecciona 'VIGENTE' en Vigencia de la Concesión.
3. Da clic en 'Buscar'.
4. El sistema muestra solo las concesiones con esa vigencia.

**Resultado esperado:**
Se muestra una tabla filtrada solo por la vigencia seleccionada.

**Datos de prueba:**
par_tabla: 3, par_vigencia: 'VIGENTE', periodoTipo: 'vencidos', año: 2024, mes: 06

---

