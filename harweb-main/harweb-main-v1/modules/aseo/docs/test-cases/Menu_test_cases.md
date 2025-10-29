## Casos de Prueba para Catálogo de Unidades

### Caso 1: Alta exitosa de unidad
- **Entrada:** ejercicio=2024, clave='K', descripcion='Unidad K', costo_unidad=100.00, costo_exed=150.00
- **Acción:** catalog.create.unidad
- **Esperado:** Respuesta 'OK', la unidad aparece en la lista.

### Caso 2: Alta duplicada de unidad
- **Entrada:** ejercicio=2024, clave='K', descripcion='Unidad K', costo_unidad=100.00, costo_exed=150.00
- **Acción:** catalog.create.unidad (clave ya existe)
- **Esperado:** Error 'Ya existe la clave para ese ejercicio'.

### Caso 3: Edición exitosa de unidad
- **Entrada:** id=1, descripcion='Unidad K Modificada', costo_unidad=120.00, costo_exed=170.00
- **Acción:** catalog.update.unidad
- **Esperado:** Respuesta 'OK', los valores se actualizan.

### Caso 4: Eliminación exitosa de unidad sin contratos
- **Entrada:** id=2
- **Acción:** catalog.delete.unidad
- **Esperado:** Respuesta 'OK', la unidad desaparece de la lista.

### Caso 5: Eliminación fallida de unidad con contratos
- **Entrada:** id=3 (tiene contratos asociados)
- **Acción:** catalog.delete.unidad
- **Esperado:** Error 'Existen contratos asociados, no se puede eliminar'.
