# Casos de Prueba para Mantenimiento de Recargos

## 1. Alta de Recargo Correcto
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=1.5
- **Acción:** recargos.create
- **Esperado:** success=true, message='Recargo creado correctamente'

## 2. Alta de Recargo Duplicado
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=1.5 (ya existe)
- **Acción:** recargos.create
- **Esperado:** success=false, message='Ya existe un recargo para ese periodo'

## 3. Edición de Recargo Existente
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=2.0
- **Acción:** recargos.update
- **Esperado:** success=true, message='Recargo actualizado correctamente'

## 4. Edición de Recargo Inexistente
- **Entrada:** year=2025, month=7, porc_recargo=2.0, porc_multa=1.0
- **Acción:** recargos.update
- **Esperado:** success=false, message='No existe recargo para ese periodo'

## 5. Eliminación de Recargo Existente
- **Entrada:** year=2024, month=6
- **Acción:** recargos.delete
- **Esperado:** success=true, message='Recargo eliminado correctamente'

## 6. Eliminación de Recargo Inexistente
- **Entrada:** year=2025, month=7
- **Acción:** recargos.delete
- **Esperado:** success=false, message='No existe recargo para ese periodo'

## 7. Consulta de Recargos por Año
- **Entrada:** year=2024
- **Acción:** recargos.list
- **Esperado:** success=true, data=[...], message=''

## 8. Validación de Campos Obligatorios
- **Entrada:** year=2024, month=null, porc_recargo=2.5, porc_multa=1.5
- **Acción:** recargos.create
- **Esperado:** success=false, message='The month field is required.'
