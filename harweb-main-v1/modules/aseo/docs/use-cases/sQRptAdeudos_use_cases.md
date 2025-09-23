# Casos de Uso - sQRptAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta general de adeudos de todas las empresas

**Descripción:** El usuario desea obtener el reporte de todos los adeudos de aseo contratado, sin filtrar por empresa ni contrato.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas relacionadas.

**Pasos a seguir:**
1. Ingresar a la página de Reporte de Adeudos Generales.
2. Dejar los filtros en sus valores por defecto (todas las empresas, todos los contratos, todos los tipos de aseo, etc).
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los registros de adeudos, agrupados y ordenados según el parámetro de clasificación seleccionado.

**Datos de prueba:**
sel_emp: 1, num_emp: 0, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 0, vig_cont: 'T', vig_adeudos: 'T', ofna: 0, opcion: 1

---

## Caso de Uso 2: Reporte de adeudos por empresa específica y contrato vigente

**Descripción:** El usuario desea ver sólo los adeudos de una empresa específica y sólo los contratos vigentes.

**Precondiciones:**
Existe al menos una empresa con contratos vigentes y adeudos registrados.

**Pasos a seguir:**
1. Seleccionar 'Por Empresa' en el filtro Empresa.
2. Ingresar el número de empresa deseado.
3. Seleccionar 'Vigente' en el filtro Vigencia Contrato.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran únicamente los adeudos correspondientes a la empresa y contratos vigentes seleccionados.

**Datos de prueba:**
sel_emp: 2, num_emp: 123, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 0, vig_cont: 'V', vig_adeudos: 'T', ofna: 0, opcion: 1

---

## Caso de Uso 3: Reporte filtrado por tipo de aseo y recaudadora

**Descripción:** El usuario desea ver los adeudos de un tipo de aseo específico y de una recaudadora determinada.

**Precondiciones:**
Existen registros con el tipo de aseo y recaudadora seleccionados.

**Pasos a seguir:**
1. Ingresar el código de tipo de aseo en el filtro correspondiente.
2. Ingresar el código de recaudadora en el filtro correspondiente.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran sólo los adeudos que cumplen ambos criterios.

**Datos de prueba:**
sel_emp: 1, num_emp: 0, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 5, vig_cont: 'T', vig_adeudos: 'T', ofna: 2, opcion: 1

---

