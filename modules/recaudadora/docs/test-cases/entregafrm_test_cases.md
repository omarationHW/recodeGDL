# Casos de Prueba: Entrega de Requerimientos por Ejecutor

## 1. Búsqueda de ejecutor por número
- **Entrada:** criterio=101, tipo=numero
- **Esperado:** Devuelve ejecutor con cveejecutor=101

## 2. Búsqueda de ejecutor por nombre
- **Entrada:** criterio="JUAN PEREZ", tipo=nombre
- **Esperado:** Devuelve lista de ejecutores que coincidan

## 3. Listar requerimientos asignados
- **Entrada:** cveejecutor=101, recaud=1, fecha="2024-06-01"
- **Esperado:** Lista de requerimientos asignados a ese ejecutor en esa fecha y recaudadora

## 4. Asignar requerimiento
- **Entrada:** folio=5001, recaud=1, cveejecutor=101, fecha="2024-06-01"
- **Esperado:** El requerimiento queda asignado y los contadores se actualizan

## 5. Quitar requerimiento
- **Entrada:** folio=5001, recaud=1, cveejecutor=101
- **Esperado:** El requerimiento se desasigna y los contadores se actualizan

## 6. Impresión de entrega
- **Entrada:** cveejecutor=101, recaud=1, fecha="2024-06-01"
- **Esperado:** Devuelve datos para impresión (ejecutor y requerimientos)

## 7. Validación de no asignar requerimiento pagado/cancelado
- **Entrada:** folio de requerimiento ya pagado/cancelado
- **Esperado:** Error y no se realiza la asignación

## 8. Validación de no quitar requerimiento no asignado
- **Entrada:** folio de requerimiento sin asignar
- **Esperado:** Error y no se realiza la desasignación
