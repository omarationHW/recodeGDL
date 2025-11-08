# Casos de Prueba - CategoriaMntto

## 1. Alta de Categoría Válida
- **Entrada:** { "action": "categoria.create", "data": { "categoria": 3, "descripcion": "FRUTAS" } }
- **Esperado:** success=true, message='Categoría creada correctamente', la categoría aparece en el listado.

## 2. Alta de Categoría Duplicada
- **Entrada:** { "action": "categoria.create", "data": { "categoria": 3, "descripcion": "FRUTAS" } }
- **Esperado:** success=false, message='La categoría ya existe'.

## 3. Modificación de Categoría Existente
- **Entrada:** { "action": "categoria.update", "data": { "categoria": 3, "descripcion": "FRUTAS Y VERDURAS" } }
- **Esperado:** success=true, message='Categoría actualizada correctamente', la descripción se actualiza.

## 4. Modificación de Categoría Inexistente
- **Entrada:** { "action": "categoria.update", "data": { "categoria": 99, "descripcion": "NO EXISTE" } }
- **Esperado:** success=false, message='La categoría no existe'.

## 5. Eliminación de Categoría Existente
- **Entrada:** { "action": "categoria.delete", "data": { "categoria": 3 } }
- **Esperado:** success=true, message='Categoría eliminada correctamente'.

## 6. Eliminación de Categoría Inexistente
- **Entrada:** { "action": "categoria.delete", "data": { "categoria": 99 } }
- **Esperado:** success=false, message='La categoría no existe'.

## 7. Listado de Categorías
- **Entrada:** { "action": "categoria.list" }
- **Esperado:** success=true, data contiene arreglo de categorías existentes.

## 8. Validación de Campos Vacíos
- **Entrada:** { "action": "categoria.create", "data": { "categoria": "", "descripcion": "" } }
- **Esperado:** success=false, message de validación indicando campos obligatorios.
