# Casos de Uso - RptCaratulaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Carátula de Energía para un Local Vigente

**Descripción:** El usuario consulta la carátula de energía de un local vigente, visualizando datos generales, adeudos, recargos y requerimientos.

**Precondiciones:**
El local existe y tiene registros de energía y adeudos.

**Pasos a seguir:**
1. El usuario ingresa el ID del local en el formulario.
2. Presiona el botón 'Consultar'.
3. El sistema muestra los datos generales del local y energía.
4. El sistema muestra la tabla de adeudos y recargos.
5. El sistema muestra la tabla de requerimientos si existen.

**Resultado esperado:**
Se visualiza correctamente la carátula con todos los datos, recargos calculados y requerimientos.

**Datos de prueba:**
id_local: 12345 (local vigente con adeudos y requerimientos)

---

## Caso de Uso 2: Cálculo de Recargos para Adeudo de Energía sin Requerimientos

**Descripción:** El sistema calcula los recargos de un adeudo de energía para un local sin requerimientos asociados.

**Precondiciones:**
El local tiene adeudos de energía y no tiene requerimientos.

**Pasos a seguir:**
1. El usuario consulta la carátula de energía del local.
2. El sistema ejecuta el cálculo de recargos para cada adeudo usando el stored procedure.

**Resultado esperado:**
Los recargos se calculan correctamente según la lógica histórica y se muestran en la tabla.

**Datos de prueba:**
id_local: 23456 (local sin requerimientos, con adeudos de energía)

---

## Caso de Uso 3: Impresión de Carátula de Energía

**Descripción:** El usuario imprime la carátula de energía de un local para entregar al contribuyente.

**Precondiciones:**
La carátula ya fue consultada y se visualiza en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir Carátula'.
2. El navegador muestra el diálogo de impresión.

**Resultado esperado:**
La carátula se imprime correctamente con todos los datos visibles.

**Datos de prueba:**
id_local: 34567 (local con datos completos)

---

