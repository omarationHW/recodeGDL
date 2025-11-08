# Casos de Prueba para Mannto_Tipos_Aseo

## 1. Alta exitosa
- **Input:** { "action": "create", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true, message='Tipo de aseo creado correctamente', data.ctrol_aseo > 0

## 2. Alta duplicada
- **Input:** { "action": "create", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=false, message='Ya existe el tipo de aseo'

## 3. Alta con cuenta de aplicación inexistente
- **Input:** { "action": "create", "data": { "tipo_aseo": "X", "descripcion": "Prueba", "cta_aplicacion": 999999 } }
- **Resultado esperado:** success=false, message='La cuenta de aplicación no existe'

## 4. Edición exitosa
- **Input:** { "action": "update", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario Modificado", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true, message='Tipo de aseo actualizado correctamente'

## 5. Eliminación exitosa (sin contratos asociados)
- **Input:** { "action": "delete", "data": { "tipo_aseo": "Z" } }
- **Resultado esperado:** success=true, message='Tipo de aseo eliminado correctamente'

## 6. Eliminación fallida (con contratos asociados)
- **Input:** { "action": "delete", "data": { "tipo_aseo": "O" } }
- **Resultado esperado:** success=false, message='Existen contratos con este tipo de aseo. No se puede eliminar.'

## 7. Validación de cuenta de aplicación existente
- **Input:** { "action": "validate_cta_aplicacion", "data": { "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true

## 8. Validación de cuenta de aplicación inexistente
- **Input:** { "action": "validate_cta_aplicacion", "data": { "cta_aplicacion": 999999 } }
- **Resultado esperado:** success=false
