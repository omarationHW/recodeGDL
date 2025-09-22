# Casos de Uso - Rep_PadronContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Contratos Vigentes de Tipo Ordinario

**Descripción:** El usuario desea obtener el listado de todos los contratos vigentes de tipo ordinario.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Padrón de Contratos.
2. Selecciona 'O = Ordinario' en Tipo de Aseo.
3. Selecciona 'V = VIGENTE' en Vigencia.
4. Selecciona 'Periodos Vencidos' en Periodo.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos vigentes de tipo ordinario, incluyendo empresa, domicilio, inicio y fin de obligación.

**Datos de prueba:**
{ "tipo": "O", "vigencia": "V" }

---

## Caso de Uso 2: Detalle de Adeudos de un Contrato Específico

**Descripción:** El usuario consulta el detalle de adeudos de un contrato seleccionado.

**Precondiciones:**
El usuario ya visualizó el padrón de contratos y seleccionó uno.

**Pasos a seguir:**
1. En la tabla de contratos, da clic en 'Ver' en la fila del contrato deseado.
2. El sistema muestra el detalle de adeudos (adeudos, recargos, multas, gastos) para ese contrato.

**Resultado esperado:**
Se muestra el detalle de adeudos correctamente sumados y desglosados.

**Datos de prueba:**
{ "control": 12345, "rep": "V", "fecha": "2024-06" }

---

## Caso de Uso 3: Consulta de Padrón de Contratos por Periodo Personalizado

**Descripción:** El usuario desea consultar el padrón de contratos para un periodo específico.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Padrón de Contratos.
2. Selecciona 'T = TODOS' en Tipo de Aseo.
3. Selecciona 'T = TODOS' en Vigencia.
4. Selecciona 'Otro Periodo' en Periodo.
5. Ingresa año '2023' y mes '03'.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra la lista de contratos activos en el periodo seleccionado.

**Datos de prueba:**
{ "tipo": "T", "vigencia": "T", "anio": "2023", "mes": "03" }

---

