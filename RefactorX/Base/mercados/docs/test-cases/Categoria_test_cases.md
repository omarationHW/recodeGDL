# Casos de Prueba: Módulo Categoría

## 1. Alta de Categoría Exitosa
- **Input:** { "categoria": 10, "descripcion": "ELECTRÓNICA" }
- **Acción:** categoria.create
- **Resultado esperado:** success=true, message='Categoría creada correctamente', la categoría aparece en el listado.

## 2. Alta de Categoría Duplicada
- **Input:** { "categoria": 10, "descripcion": "ELECTRÓNICA" }
- **Acción:** categoria.create (cuando ya existe la categoría 10)
- **Resultado esperado:** success=false, message='La categoría ya existe'.

## 3. Edición de Categoría Exitosa
- **Input:** { "categoria": 10, "descripcion": "ELECTRODOMÉSTICOS" }
- **Acción:** categoria.update
- **Resultado esperado:** success=true, message='Categoría actualizada correctamente', la descripción se actualiza.

## 4. Edición de Categoría Inexistente
- **Input:** { "categoria": 99, "descripcion": "INEXISTENTE" }
- **Acción:** categoria.update
- **Resultado esperado:** success=false, message='La categoría no existe'.

## 5. Eliminación Exitosa
- **Input:** { "categoria": 10 }
- **Acción:** categoria.delete
- **Resultado esperado:** success=true, message='Categoría eliminada correctamente'.

## 6. Eliminación de Categoría Inexistente
- **Input:** { "categoria": 99 }
- **Acción:** categoria.delete
- **Resultado esperado:** success=false, message='La categoría no existe'.

## 7. Listado de Categorías
- **Input:** (sin parámetros)
- **Acción:** categoria.list
- **Resultado esperado:** success=true, data contiene todas las categorías ordenadas por número.
