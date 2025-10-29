# Casos de Prueba para RecargosMntto

## 1. Alta exitosa de recargo
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 2.5, "id_usuario": 1 } }
- **Resultado esperado:** success=true, message='Recargo insertado correctamente.'
- **Verificación:** El registro aparece en la tabla con los datos correctos.

## 2. Alta duplicada
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 2.5, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='Ya existe un recargo para ese año y periodo.'

## 3. Modificación exitosa
- **Input:** { "action": "update_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 3.0, "id_usuario": 1 } }
- **Resultado esperado:** success=true, message='Recargo actualizado correctamente.'
- **Verificación:** El porcentaje se actualiza en la tabla.

## 4. Modificación de recargo inexistente
- **Input:** { "action": "update_recargo", "params": { "axo": 2025, "periodo": 1, "porcentaje": 1.5, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='No existe el recargo para ese año y periodo.'

## 5. Consulta de recargo existente
- **Input:** { "action": "get_recargo", "params": { "axo": 2024, "periodo": 8 } }
- **Resultado esperado:** data contiene el registro con axo=2024, periodo=8, porcentaje=3.0

## 6. Listado de recargos
- **Input:** { "action": "list_recargos" }
- **Resultado esperado:** data es un array con todos los recargos ordenados por año y periodo descendente.

## 7. Validación de campos obligatorios
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8 } }
- **Resultado esperado:** success=false, message indica campo faltante.
