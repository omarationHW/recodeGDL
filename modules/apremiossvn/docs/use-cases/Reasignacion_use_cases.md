# Casos de Uso - Reasignacion

**Categoría:** Form

## Caso de Uso 1: Reasignación masiva de folios a un nuevo ejecutor

**Descripción:** El usuario selecciona un rango de folios, elige un nuevo ejecutor y reasigna todos los folios seleccionados.

**Precondiciones:**
El usuario tiene permisos de reasignación y existen folios en el rango seleccionado.

**Pasos a seguir:**
1. Ingresar rango de folios (Desde/Hasta), recaudadora y módulo.
2. Presionar 'Buscar Folios'.
3. Seleccionar todos los folios listados.
4. Seleccionar el nuevo ejecutor y la fecha de entrega.
5. Presionar 'Reasignar Folios'.

**Resultado esperado:**
Todos los folios seleccionados son reasignados al nuevo ejecutor y la fecha de entrega se actualiza.

**Datos de prueba:**
folioDesde: 1000, folioHasta: 1010, recaudadora: 1, modulo: 16, nuevoEjecutor: 45, fechaEntrega2: '2024-06-10'

---

## Caso de Uso 2: Validación de rango de folios incorrecto

**Descripción:** El usuario ingresa un rango donde el folio desde es mayor que el folio hasta.

**Precondiciones:**
El usuario accede al formulario de reasignación.

**Pasos a seguir:**
1. Ingresar folioDesde: 1050, folioHasta: 1040.
2. Presionar 'Buscar Folios'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Error: Folio Desde no puede ser mayor que Folio Hasta'.

**Datos de prueba:**
folioDesde: 1050, folioHasta: 1040

---

## Caso de Uso 3: Reasignación parcial de folios

**Descripción:** El usuario selecciona solo algunos folios del listado para reasignar.

**Precondiciones:**
Existen al menos 5 folios en el rango buscado.

**Pasos a seguir:**
1. Ingresar rango de folios (Desde/Hasta), recaudadora y módulo.
2. Presionar 'Buscar Folios'.
3. Seleccionar solo los folios con id_control 2001 y 2003.
4. Seleccionar el nuevo ejecutor y la fecha de entrega.
5. Presionar 'Reasignar Folios'.

**Resultado esperado:**
Solo los folios seleccionados son reasignados al nuevo ejecutor.

**Datos de prueba:**
folios seleccionados: [2001, 2003], nuevoEjecutor: 50, fechaEntrega2: '2024-06-15'

---

