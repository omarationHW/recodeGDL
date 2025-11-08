# Casos de Prueba Rubros

## Caso 1: Alta exitosa de rubro
- **Entrada:** nombre='RUBRO TEST', status_selected=['A', 'I']
- **Acción:** POST /api/execute { action: 'createRubro', params: { nombre: 'RUBRO TEST', status_selected: [{cve_stat:'A',descripcion:'Activo'},{cve_stat:'I',descripcion:'Inactivo'}] } }
- **Esperado:** success=true, message='Rubro creado correctamente', rubro aparece en listado

## Caso 2: Alta de rubro sin nombre
- **Entrada:** nombre='', status_selected=['A']
- **Acción:** POST /api/execute { action: 'createRubro', params: { nombre: '', status_selected: [{cve_stat:'A',descripcion:'Activo'}] } }
- **Esperado:** success=false, message contiene 'obligatorio'

## Caso 3: Alta de rubro sin status
- **Entrada:** nombre='RUBRO SIN STATUS', status_selected=[]
- **Acción:** POST /api/execute { action: 'createRubro', params: { nombre: 'RUBRO SIN STATUS', status_selected: [] } }
- **Esperado:** success=false, message contiene 'status seleccionados son requeridos'

## Caso 4: Alta de rubro duplicado
- **Entrada:** nombre='RUBRO TEST', status_selected=['A']
- **Acción:** POST /api/execute { action: 'createRubro', params: { nombre: 'RUBRO TEST', status_selected: [{cve_stat:'A',descripcion:'Activo'}] } }
- **Esperado:** success=false, message contiene 'ya existe'

## Caso 5: Consulta de rubros
- **Acción:** POST /api/execute { action: 'getRubros' }
- **Esperado:** success=true, data es array de rubros

## Caso 6: Consulta de status
- **Acción:** POST /api/execute { action: 'getStatusCatalog' }
- **Esperado:** success=true, data es array de status
