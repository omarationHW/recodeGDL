# Casos de Prueba - Catálogo de Categorías

## Caso 1: Agregar Categoría
- **Entrada:** { "action": "addCategoria", "params": { "descripcion": "Industrial" } }
- **Esperado:** Respuesta success true, data contiene la nueva categoría con descripción 'INDUSTRIAL'.

## Caso 2: Editar Categoría
- **Entrada:** { "action": "updateCategoria", "params": { "categoria": 1, "descripcion": "Residencial" } }
- **Esperado:** Respuesta success true, data contiene la categoría con ID 1 y descripción 'RESIDENCIAL'.

## Caso 3: Listar Categorías
- **Entrada:** { "action": "getCategorias" }
- **Esperado:** Respuesta success true, data es un array de categorías.

## Caso 4: Validación de campos vacíos
- **Entrada:** { "action": "addCategoria", "params": { "descripcion": "" } }
- **Esperado:** Respuesta success false, message indica error de validación.

## Caso 5: Error de SP
- **Simular:** Forzar error en base de datos (por ejemplo, descripción muy larga).
- **Esperado:** Respuesta success false, message contiene el error del SP.
