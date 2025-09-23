# Casos de Uso - impreqCvecat

**Categoría:** Form

## Caso de Uso 1: Asignar requerimientos a ejecutor

**Descripción:** El usuario busca requerimientos por rango de folios y asigna los seleccionados a un ejecutor.

**Precondiciones:**
El usuario está autenticado y tiene permisos de asignación.

**Pasos a seguir:**
1. El usuario ingresa recaudadora, folio inicial, folio final y fecha.
2. Presiona 'Buscar' y visualiza los requerimientos.
3. Selecciona varios folios.
4. Presiona 'Asignar', ingresa el número de ejecutor.
5. El sistema llama a /api/execute con action: 'asignar'.

**Resultado esperado:**
Los requerimientos seleccionados quedan asignados al ejecutor indicado y la tabla se actualiza.

**Datos de prueba:**
{ "recaud": 1, "folioini": 100, "foliofin": 110, "fecha": "2024-06-01", "ejecutor": 5, "usuario": "admin" }

---

## Caso de Uso 2: Imprimir requerimientos seleccionados

**Descripción:** El usuario marca varios folios y los marca como impresos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de impresión.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de requerimientos.
2. Selecciona varios folios.
3. Presiona 'Imprimir'.
4. El sistema llama a /api/execute con action: 'imprimir'.

**Resultado esperado:**
Los folios seleccionados quedan marcados como impresos.

**Datos de prueba:**
{ "recaud": 1, "folioini": 100, "foliofin": 105, "usuario": "admin" }

---

## Caso de Uso 3: Listar ejecutores disponibles

**Descripción:** El usuario consulta los ejecutores disponibles para una recaudadora y fecha.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una recaudadora y fecha.
2. Presiona 'Listar ejecutores'.
3. El sistema llama a /api/execute con action: 'ejecutores'.

**Resultado esperado:**
Se muestra la lista de ejecutores disponibles.

**Datos de prueba:**
{ "recaud": 1, "fecha": "2024-06-01" }

---

