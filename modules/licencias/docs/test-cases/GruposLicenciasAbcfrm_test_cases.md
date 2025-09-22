# Casos de Prueba para Grupos de Licencias

## Caso 1: Alta de grupo válido
- **Entrada:** { "descripcion": "SOPORTE" }
- **Acción:** POST /api/execute { operation: 'insert_grupo_licencia', params: { descripcion: 'SOPORTE' } }
- **Esperado:** Respuesta success=true, data con id y descripcion='SOPORTE'.

## Caso 2: Alta de grupo con descripción vacía
- **Entrada:** { "descripcion": "" }
- **Acción:** POST /api/execute { operation: 'insert_grupo_licencia', params: { descripcion: '' } }
- **Esperado:** Respuesta success=false, mensaje de error por validación.

## Caso 3: Edición de grupo existente
- **Entrada:** { "id": 2, "descripcion": "VENTAS" }
- **Acción:** POST /api/execute { operation: 'update_grupo_licencia', params: { id: 2, descripcion: 'VENTAS' } }
- **Esperado:** Respuesta success=true, data con id=2 y descripcion='VENTAS'.

## Caso 4: Eliminación de grupo existente
- **Entrada:** { "id": 3 }
- **Acción:** POST /api/execute { operation: 'delete_grupo_licencia', params: { id: 3 } }
- **Esperado:** Respuesta success=true, data con id=3.

## Caso 5: Filtro por descripción parcial
- **Entrada:** { "descripcion": "ADM" }
- **Acción:** POST /api/execute { operation: 'list_grupos_licencias', params: { descripcion: 'ADM' } }
- **Esperado:** Respuesta success=true, data con todos los grupos que contienen 'ADM' en la descripción.

## Caso 6: Consulta de grupo inexistente
- **Entrada:** { "id": 9999 }
- **Acción:** POST /api/execute { operation: 'get_grupo_licencia', params: { id: 9999 } }
- **Esperado:** Respuesta success=true, data=null.
