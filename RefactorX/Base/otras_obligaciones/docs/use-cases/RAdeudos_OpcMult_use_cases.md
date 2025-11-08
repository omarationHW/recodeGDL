# Casos de Uso - RAdeudos_OpcMult

**Categoría:** Form

## Caso de Uso 1: Buscar local y mostrar adeudos vigentes

**Descripción:** El usuario ingresa el número y letra de un local, busca y visualiza los adeudos vigentes.

**Precondiciones:**
El local existe en la base de datos y tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número y letra del local.
2. Presiona 'Buscar'.
3. El sistema consulta el backend con action 'search_local'.
4. Si existe, muestra los datos del local.
5. El sistema consulta los adeudos con action 'get_adeudos'.
6. Se listan los adeudos vigentes.

**Resultado esperado:**
Se muestran los datos del local y la lista de adeudos vigentes.

**Datos de prueba:**
{ numero: '123', letra: 'A' }

---

## Caso de Uso 2: Ejecutar opción 'Dar de Pagado' sobre adeudos seleccionados

**Descripción:** El usuario selecciona uno o varios adeudos y ejecuta la opción 'Dar de Pagado'.

**Precondiciones:**
El local tiene adeudos vigentes seleccionables.

**Pasos a seguir:**
1. El usuario busca el local y visualiza los adeudos.
2. Selecciona uno o más adeudos.
3. Ingresa los datos de operación (fecha, recaudadora, caja, consec, folio).
4. Selecciona la opción 'P - DAR DE PAGADO'.
5. Presiona 'Ejecutar'.
6. El sistema envía action 'execute_opc' con los datos seleccionados.
7. El backend procesa y responde.

**Resultado esperado:**
Los adeudos seleccionados cambian de status a 'Pagado'. Mensaje de éxito.

**Datos de prueba:**
{ id_datos: 1001, selected: [{registro: 2001, axo: 2023, mes: 12}], fecha: '2024-06-01', id_rec: 1, caja: 'A', consec: 12345, folio_rcbo: 'RCB123', status: 'P', opc: 'B' }

---

## Caso de Uso 3: Intentar ejecutar opción sin seleccionar adeudos

**Descripción:** El usuario intenta ejecutar una opción sin seleccionar ningún adeudo.

**Precondiciones:**
El local tiene adeudos listados.

**Pasos a seguir:**
1. El usuario busca el local y visualiza los adeudos.
2. No selecciona ningún adeudo.
3. Presiona 'Ejecutar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar al menos un adeudo.

**Datos de prueba:**
{ id_datos: 1001, selected: [], ... }

---

