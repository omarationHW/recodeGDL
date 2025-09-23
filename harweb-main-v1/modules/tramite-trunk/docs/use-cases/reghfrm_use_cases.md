# Casos de Uso - reghfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de historial de movimientos de una cuenta catastral

**Descripción:** El usuario desea consultar todos los movimientos históricos de una cuenta catastral específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
1. El usuario accede a la página de Registros Históricos.
2. Ingresa el número de cuenta catastral en el campo correspondiente.
3. Presiona el botón 'Buscar'.
4. El sistema consulta el historial y muestra la tabla de movimientos.

**Resultado esperado:**
Se muestra una tabla con todos los movimientos históricos de la cuenta, ordenados por año y número de comprobante.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 2: Visualización de detalle de un movimiento histórico

**Descripción:** El usuario desea ver el detalle completo de un movimiento específico del historial.

**Precondiciones:**
El usuario ya visualizó la tabla de movimientos históricos.

**Pasos a seguir:**
1. El usuario localiza el movimiento deseado en la tabla.
2. Presiona el botón 'Ver' en la fila correspondiente.
3. El sistema muestra el detalle completo del movimiento.

**Resultado esperado:**
Se muestra una tabla con todos los campos del movimiento seleccionado.

**Datos de prueba:**
{ "cvecuenta": 123456, "axocomp": 2022, "nocomp": 15 }

---

## Caso de Uso 3: Búsqueda avanzada de movimientos históricos por capturista y rango de fechas

**Descripción:** El usuario desea buscar movimientos históricos filtrando por capturista y un rango de fechas.

**Precondiciones:**
El usuario tiene permisos de consulta avanzada.

**Pasos a seguir:**
1. El usuario accede a la búsqueda avanzada.
2. Ingresa el nombre del capturista y el rango de fechas.
3. Presiona 'Buscar'.
4. El sistema muestra los movimientos que cumplen los criterios.

**Resultado esperado:**
Se muestra una tabla con los movimientos filtrados por capturista y fechas.

**Datos de prueba:**
{ "filters": { "capturista": "jdoe", "feccap_from": "2022-01-01", "feccap_to": "2022-12-31" } }

---

