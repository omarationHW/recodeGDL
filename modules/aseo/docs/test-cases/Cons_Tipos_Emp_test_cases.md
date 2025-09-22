# Casos de Prueba: Cons_Tipos_Emp

## 1. Consulta básica
- Acción: list
- Parámetro: order = 'ctrol_emp'
- Esperado: Lista de todos los tipos de empresa ordenados por control

## 2. Consulta por descripción
- Acción: list
- Parámetro: order = 'descripcion'
- Esperado: Lista ordenada alfabéticamente por descripción

## 3. Alta exitosa
- Acción: create
- Parámetros: tipo_empresa = 'M', descripcion = 'Mixto'
- Esperado: Registro creado, success=true, data contiene el nuevo registro

## 4. Alta inválida (sin descripción)
- Acción: create
- Parámetros: tipo_empresa = 'X', descripcion = ''
- Esperado: success=false, message indica error de validación

## 5. Edición exitosa
- Acción: update
- Parámetros: ctrol_emp=2, tipo_empresa='G', descripcion='Gobierno Federal'
- Esperado: Registro actualizado, success=true

## 6. Eliminación exitosa (sin empresas asociadas)
- Acción: delete
- Parámetros: ctrol_emp=3
- Precondición: No existen empresas con ctrol_emp=3
- Esperado: success=true, message='Eliminado correctamente.'

## 7. Eliminación fallida (con empresas asociadas)
- Acción: delete
- Parámetros: ctrol_emp=1
- Precondición: Existen empresas con ctrol_emp=1
- Esperado: success=false, message='No se puede eliminar: existen empresas asociadas.'

## 8. Exportación
- Acción: export
- Parámetro: order = 'tipo_empresa'
- Esperado: Datos exportados en formato CSV/Excel
