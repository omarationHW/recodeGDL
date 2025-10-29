# Casos de Prueba para frmselcalle

## Caso 1: Filtro por prefijo
- **Entrada:** filter = 'AVENIDA'
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: 'AVENIDA' } }
- **Esperado:** Solo se devuelven calles cuyo nombre inicia con 'AVENIDA'.

## Caso 2: Sin filtro (todas las calles)
- **Entrada:** filter = ''
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: '' } }
- **Esperado:** Se devuelven todas las calles ordenadas alfabéticamente.

## Caso 3: Selección múltiple
- **Entrada:** El usuario selecciona cvecalle 1 y 3 en la tabla y presiona 'Aceptar'.
- **Acción:** El frontend muestra '1,3' como IDs seleccionados.
- **Esperado:** El mensaje de confirmación muestra los IDs seleccionados correctamente.

## Caso 4: Filtro sin resultados
- **Entrada:** filter = 'ZZZZZ'
- **Acción:** POST /api/execute { eRequest: 'get_calles', eParams: { filter: 'ZZZZZ' } }
- **Esperado:** La tabla muestra 'No hay resultados'.

## Caso 5: Consulta por IDs
- **Entrada:** ids = [2,4]
- **Acción:** POST /api/execute { eRequest: 'get_calle_by_ids', eParams: { ids: [2,4] } }
- **Esperado:** Se devuelven los registros de cvecalle 2 y 4.
