# Casos de Prueba: Catálogo de Actividades

## Caso 1: Alta de actividad válida
- **Entrada:** id_giro=1001, descripcion="Venta de alimentos preparados", observaciones="Incluye restaurantes y fondas", vigente="V"
- **Acción:** catalogo_actividades.create
- **Esperado:** Código 200, success=true, data contiene id_actividad nuevo, la actividad aparece en la lista.

## Caso 2: Alta con descripción vacía
- **Entrada:** id_giro=1001, descripcion="", observaciones="", vigente="V"
- **Acción:** catalogo_actividades.create
- **Esperado:** Código 200, success=false, message indica error de validación.

## Caso 3: Edición de actividad existente
- **Entrada:** id=5, id_giro=1001, descripcion="Venta de alimentos y bebidas", observaciones="Incluye restaurantes, bares y fondas", vigente="V"
- **Acción:** catalogo_actividades.update
- **Esperado:** Código 200, success=true, data contiene id_actividad=5, cambios reflejados en la lista.

## Caso 4: Baja lógica de actividad
- **Entrada:** id=7, motivo_baja="Actividad obsoleta"
- **Acción:** catalogo_actividades.delete
- **Esperado:** Código 200, success=true, data contiene id_actividad=7, la actividad aparece como 'Cancelado'.

## Caso 5: Listado filtrado por descripción
- **Entrada:** descripcion="alimentos"
- **Acción:** catalogo_actividades.list
- **Esperado:** Código 200, success=true, data contiene solo actividades con "alimentos" en la descripción.

## Caso 6: Obtener giros vigentes
- **Entrada:** (sin parámetros)
- **Acción:** catalogo_actividades.giros
- **Esperado:** Código 200, success=true, data contiene lista de giros vigentes.
