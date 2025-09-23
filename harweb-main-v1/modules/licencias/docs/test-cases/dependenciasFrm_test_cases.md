# Casos de Prueba: Gestión de Revisiones/Inspecciones

## Caso 1: Agregar inspección válida
- **Input:** { "action": "add_inspeccion", "params": { "id_tramite": 101, "id_dependencia": 22 } }
- **Resultado esperado:** success: true, message: 'Inspección agregada'
- **Validación:** La inspección aparece en la lista de inspecciones del trámite 101.

## Caso 2: Agregar inspección duplicada
- **Input:** { "action": "add_inspeccion", "params": { "id_tramite": 101, "id_dependencia": 22 } }
- **Precondición:** Ya existe la inspección para ese trámite y dependencia.
- **Resultado esperado:** success: false, message: 'Ya existe esta inspección para el trámite'

## Caso 3: Eliminar inspección existente
- **Input:** { "action": "delete_inspeccion", "params": { "id_tramite": 101, "id_dependencia": 22 } }
- **Resultado esperado:** success: true, message: 'Inspección eliminada'
- **Validación:** La inspección ya no aparece en la lista.

## Caso 4: Eliminar inspección inexistente
- **Input:** { "action": "delete_inspeccion", "params": { "id_tramite": 101, "id_dependencia": 99 } }
- **Resultado esperado:** success: false, message: 'No existe la inspección para eliminar'

## Caso 5: Obtener catálogo de dependencias
- **Input:** { "action": "get_dependencias", "params": {} }
- **Resultado esperado:** success: true, data: [ ... ]

## Caso 6: Obtener inspecciones actuales
- **Input:** { "action": "get_tramite_inspecciones", "params": { "id_tramite": 101 } }
- **Resultado esperado:** success: true, data: [ ... ]

## Caso 7: Obtener información de trámite inexistente
- **Input:** { "action": "get_tramite_info", "params": { "id_tramite": 999999 } }
- **Resultado esperado:** success: false, message: 'Trámite no encontrado'
