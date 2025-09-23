# Casos de Uso - SdosFavor_CtrlExp

**Categoría:** Form

## Caso de Uso 1: Consulta de folios por estatus

**Descripción:** El usuario desea consultar todos los folios de solicitudes de saldo a favor con estatus 'PENDIENTES'.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Control de Expedientes.
2. Selecciona 'PENDIENTES' en el filtro de estatus.
3. Da clic en 'Buscar Folios'.

**Resultado esperado:**
Se muestra la lista de folios con estatus 'PENDIENTES' y el total correspondiente.

**Datos de prueba:**
Estatus: 'P' (PENDIENTES)

---

## Caso de Uso 2: Asignación masiva de folios

**Descripción:** El usuario selecciona varios folios y los asigna cambiando su estatus a 'ASIGNADOS'.

**Precondiciones:**
El usuario está autenticado y existen folios con estatus 'PENDIENTES'.

**Pasos a seguir:**
1. El usuario filtra por estatus 'PENDIENTES'.
2. Selecciona varios folios de la lista.
3. Da clic en 'Asignar Folios'.

**Resultado esperado:**
Los folios seleccionados cambian su estatus a 'ASIGNADOS' y desaparecen del filtro actual.

**Datos de prueba:**
Folios: [1001, 1002, 1003], Nuevo estatus: 'AS'

---

## Caso de Uso 3: Conteo de folios por estatus

**Descripción:** El sistema debe mostrar el total de folios para un estatus seleccionado.

**Precondiciones:**
Existen folios en la base de datos con diferentes estatus.

**Pasos a seguir:**
1. El usuario selecciona un estatus en el filtro.
2. El sistema consulta el total de folios para ese estatus.

**Resultado esperado:**
El total de folios se muestra correctamente junto al filtro.

**Datos de prueba:**
Estatus: 'AS' (ASIGNADOS)

---

