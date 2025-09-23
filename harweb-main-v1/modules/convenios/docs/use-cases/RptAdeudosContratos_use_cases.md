# Casos de Uso - RptAdeudosContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos vigentes con adeudos

**Descripción:** El usuario desea obtener el listado de contratos vigentes con adeudos para una colonia y calle específica.

**Precondiciones:**
El usuario conoce los IDs de colonia y calle válidos. Existen contratos con adeudos en esa combinación.

**Pasos a seguir:**
1. Ingresar el ID de colonia y calle en el formulario.
2. Seleccionar 'Contratos Vigentes con Adeudos' como tipo de reporte.
3. Presionar 'Consultar'.
4. El sistema muestra la tabla con los contratos y sus saldos.

**Resultado esperado:**
Se muestra una tabla con los contratos que tienen saldo pendiente (ADE), incluyendo totales.

**Datos de prueba:**
{ "colonia": 101, "calle": 202, "rep": 1 }

---

## Caso de Uso 2: Consulta de contratos con saldos a favor

**Descripción:** El usuario desea ver contratos que tienen saldo a favor (pagaron de más) en una colonia y calle.

**Precondiciones:**
Existen contratos con saldo a favor en la colonia y calle seleccionadas.

**Pasos a seguir:**
1. Ingresar el ID de colonia y calle.
2. Seleccionar 'Contratos Vigentes con Saldos a Favor'.
3. Presionar 'Consultar'.

**Resultado esperado:**
Se listan los contratos con saldo negativo (SAF), mostrando el monto a favor.

**Datos de prueba:**
{ "colonia": 101, "calle": 202, "rep": 2 }

---

## Caso de Uso 3: Consulta de contratos liquidados

**Descripción:** El usuario requiere un listado de contratos que ya están liquidados (sin adeudo ni saldo a favor).

**Precondiciones:**
Existen contratos liquidados en la colonia y calle seleccionadas.

**Pasos a seguir:**
1. Ingresar el ID de colonia y calle.
2. Seleccionar 'Contratos Vigentes Liquidados'.
3. Presionar 'Consultar'.

**Resultado esperado:**
Se muestran los contratos cuyo saldo es cero (LIQ).

**Datos de prueba:**
{ "colonia": 101, "calle": 202, "rep": 3 }

---

