# Casos de Uso - RptListado_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta de adeudos de aseo para todos los tipos en un rango de contratos

**Descripción:** El usuario desea obtener el listado de adeudos de aseo para todos los tipos de aseo, filtrando por un rango de contratos y una fecha de corte específica.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas de contratos y pagos.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Adeudos Aseo.
2. Selecciona la fecha de corte (ejemplo: 2024-06-30).
3. Selecciona 'Todos' en el tipo de aseo.
4. Ingresa el rango de contratos: 1000 a 2000.
5. Ingresa el ID Rec: 1.
6. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los adeudos de aseo para contratos entre 1000 y 2000, de todos los tipos, con los totales generales calculados.

**Datos de prueba:**
{ "vtipo": "todos", "xnum1": 1000, "xnum2": 2000, "vrec": 1, "fecha_corte": "2024-06-30" }

---

## Caso de Uso 2: Consulta de adeudos de aseo solo para tipo 'ORDINARIO'

**Descripción:** El usuario requiere ver únicamente los adeudos de aseo de tipo 'ORDINARIO' para todos los contratos.

**Precondiciones:**
El usuario tiene acceso y existen registros de tipo 'ORDINARIO'.

**Pasos a seguir:**
1. Accede a la página de Listado de Adeudos Aseo.
2. Selecciona la fecha de corte (ejemplo: 2024-06-30).
3. Selecciona 'ORDINARIO' en el tipo de aseo.
4. Deja en blanco los campos de contrato inicial y final.
5. Ingresa el ID Rec: 1.
6. Presiona 'Consultar'.

**Resultado esperado:**
Se muestran solo los adeudos de tipo 'ORDINARIO' con sus totales.

**Datos de prueba:**
{ "vtipo": "ORDINARIO", "xnum1": 0, "xnum2": 0, "vrec": 1, "fecha_corte": "2024-06-30" }

---

## Caso de Uso 3: Consulta de adeudos para un contrato específico y fecha límite de mes

**Descripción:** El usuario consulta los adeudos de aseo para un contrato específico justo en la fecha límite del mes.

**Precondiciones:**
El usuario tiene acceso y el contrato existe.

**Pasos a seguir:**
1. Accede a la página de Listado de Adeudos Aseo.
2. Selecciona la fecha de corte igual al día límite del mes (ejemplo: 2024-06-15 si el límite es 15).
3. Selecciona 'Todos' en tipo de aseo.
4. Ingresa el mismo número en contrato inicial y final (ejemplo: 1234).
5. Ingresa el ID Rec: 1.
6. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra el adeudo del contrato 1234, considerando la lógica de corte de mes.

**Datos de prueba:**
{ "vtipo": "todos", "xnum1": 1234, "xnum2": 1234, "vrec": 1, "fecha_corte": "2024-06-15" }

---

