# Casos de Uso - RptReq_Pba_Aseo

**Categoría:** Form

## Caso de Uso 1: Generar reporte de requerimiento de pago y embargo para una oficina y tipo de aseo específico

**Descripción:** El usuario desea obtener el reporte de adeudos de aseo contratado para la oficina 1 y tipo de aseo 'ORDINARIO' al corte del 1 de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes. Existen datos en las tablas correspondientes.

**Pasos a seguir:**
1. Ingresar a la página de 'Requerimiento de Pago y Embargo - Aseo'.
2. Seleccionar oficina: 1.
3. Seleccionar tipo de aseo: 'ORDINARIO'.
4. Seleccionar fecha de corte: 2024-06-01.
5. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los contratos, periodos, importes, recargos, gastos y total calculado para cada registro correspondiente a la oficina y tipo de aseo seleccionados.

**Datos de prueba:**
{ "id_rec": 1, "tipo_aseo": "ORDINARIO", "fecha_corte": "2024-06-01" }

---

## Caso de Uso 2: Generar reporte para todos los tipos de aseo de una oficina

**Descripción:** El usuario requiere el reporte de todos los contratos de aseo (sin filtrar por tipo) para la oficina 2 al corte del 15 de mayo de 2024.

**Precondiciones:**
El usuario tiene acceso y existen datos de diferentes tipos de aseo para la oficina 2.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Seleccionar oficina: 2.
3. Seleccionar tipo de aseo: 'todos'.
4. Seleccionar fecha de corte: 2024-05-15.
5. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestran todos los contratos de la oficina 2, sin importar el tipo de aseo, con los cálculos correctos.

**Datos de prueba:**
{ "id_rec": 2, "tipo_aseo": "todos", "fecha_corte": "2024-05-15" }

---

## Caso de Uso 3: Validar cálculo de recargos y gastos mínimos/máximos

**Descripción:** El usuario verifica que para un contrato con importe bajo, los gastos no sean menores al mínimo y para importes altos no superen el máximo anual.

**Precondiciones:**
Existen contratos con importes bajos y altos, y los valores de gastos mínimos y máximos están configurados en la tabla ta_15_gastos.

**Pasos a seguir:**
1. Generar reporte para oficina 1, tipo 'ORDINARIO', fecha de corte 2024-06-01.
2. Revisar en la tabla que los gastos calculados no sean menores al mínimo ni mayores al máximo anual según la lógica.

**Resultado esperado:**
Los gastos por registro cumplen con las reglas de mínimo y máximo configuradas.

**Datos de prueba:**
{ "id_rec": 1, "tipo_aseo": "ORDINARIO", "fecha_corte": "2024-06-01" }

---

