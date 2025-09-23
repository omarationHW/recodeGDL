# Casos de Uso - RptReq_pba

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de requerimiento para todos los locales de un mercado

**Descripción:** El usuario desea obtener el reporte de requerimiento de pago y embargo para todos los locales de los mercados 1 al 2, sin filtrar por sección.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas de adeudos y locales.

**Pasos a seguir:**
1. Ingresar Mercado Inicial: 1
2. Ingresar Mercado Final: 2
3. Ingresar Local Inicial: 1
4. Ingresar Local Final: 100
5. Ingresar Sección: 'todas'
6. Presionar 'Consultar'

**Resultado esperado:**
Se muestra una tabla con todos los adeudos de los locales de los mercados 1 y 2, con los campos de importe, recargos, renta y total de gastos correctamente calculados.

**Datos de prueba:**
{ "vmerc1": 1, "vmerc2": 2, "vlocal1": 1, "vlocal2": 100, "vsecc": "todas" }

---

## Caso de Uso 2: Consulta filtrando por sección específica

**Descripción:** El usuario requiere el reporte solo para la sección 'A' de los locales 10 al 20 del mercado 1.

**Precondiciones:**
Existen locales en la sección 'A' del mercado 1 con adeudos registrados.

**Pasos a seguir:**
1. Ingresar Mercado Inicial: 1
2. Ingresar Mercado Final: 1
3. Ingresar Local Inicial: 10
4. Ingresar Local Final: 20
5. Ingresar Sección: 'A'
6. Presionar 'Consultar'

**Resultado esperado:**
Se muestran únicamente los registros de la sección 'A' del mercado 1, locales 10 al 20, con los cálculos correctos.

**Datos de prueba:**
{ "vmerc1": 1, "vmerc2": 1, "vlocal1": 10, "vlocal2": 20, "vsecc": "A" }

---

## Caso de Uso 3: Validación de cálculo de recargos y gastos

**Descripción:** El usuario verifica que los recargos y gastos se calculan correctamente para un local específico en un periodo determinado.

**Precondiciones:**
Existen registros de recargos y gastos para el año y periodo consultados.

**Pasos a seguir:**
1. Ingresar Mercado Inicial: 1
2. Ingresar Mercado Final: 1
3. Ingresar Local Inicial: 5
4. Ingresar Local Final: 5
5. Ingresar Sección: 'B'
6. Presionar 'Consultar'
7. Revisar los valores de recargos y total_gasto en la tabla.

**Resultado esperado:**
El campo 'recargos' corresponde al cálculo esperado según la lógica del stored procedure y los datos de la tabla ta_12_recargos. El campo 'total_gasto' corresponde a la suma de gastos asociados.

**Datos de prueba:**
{ "vmerc1": 1, "vmerc2": 1, "vlocal1": 5, "vlocal2": 5, "vsecc": "B" }

---

