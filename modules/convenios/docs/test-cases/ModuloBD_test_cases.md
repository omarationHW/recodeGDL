# Casos de Prueba para Catálogo de Tipos

## Prueba 1: Alta de Tipo válido
- **Entrada**: { action: 'addTipo', params: { descripcion: 'Tipo QA' } }
- **Esperado**: success=true, data.tipo > 0, data.descripcion='Tipo QA'

## Prueba 2: Alta de Tipo sin descripción
- **Entrada**: { action: 'addTipo', params: { descripcion: '' } }
- **Esperado**: success=false, error contiene 'descripcion'

## Prueba 3: Edición de Tipo existente
- **Entrada**: { action: 'updateTipo', params: { tipo: 1, descripcion: 'Tipo Modificado' } }
- **Esperado**: success=true, data.tipo=1, data.descripcion='Tipo Modificado'

## Prueba 4: Eliminación de Tipo
- **Entrada**: { action: 'deleteTipo', params: { tipo: 1 } }
- **Esperado**: success=true, data.tipo=1

## Prueba 5: Listado de Tipos
- **Entrada**: { action: 'getTipos' }
- **Esperado**: success=true, data es array de tipos

## Prueba 6: Edición de Tipo inexistente
- **Entrada**: { action: 'updateTipo', params: { tipo: 999, descripcion: 'No existe' } }
- **Esperado**: success=true, data.tipo=999 (pero no cambia nada en la tabla)

## Prueba 7: Eliminación de Tipo inexistente
- **Entrada**: { action: 'deleteTipo', params: { tipo: 999 } }
- **Esperado**: success=true, data.tipo=999
