# Casos de Prueba: Catálogo de Secciones

## Caso 1: Alta de sección válida
- **Entrada:** seccion='C3', descripcion='Zona Este'
- **Acción:** secciones.create
- **Esperado:** success=true, mensaje de éxito, la sección aparece en la lista.

## Caso 2: Alta de sección duplicada
- **Entrada:** seccion='A1', descripcion='Zona Duplicada'
- **Acción:** secciones.create
- **Esperado:** success=false, mensaje 'La sección ya existe.'

## Caso 3: Edición de sección existente
- **Entrada:** seccion='C3', descripcion='Zona Este Modificada'
- **Acción:** secciones.update
- **Esperado:** success=true, mensaje de éxito, la descripción se actualiza.

## Caso 4: Edición de sección inexistente
- **Entrada:** seccion='ZZ', descripcion='No existe'
- **Acción:** secciones.update
- **Esperado:** success=false, mensaje 'La sección no existe.'

## Caso 5: Eliminación de sección existente
- **Entrada:** seccion='C3'
- **Acción:** secciones.delete
- **Esperado:** success=true, mensaje de éxito, la sección desaparece de la lista.

## Caso 6: Eliminación de sección inexistente
- **Entrada:** seccion='ZZ'
- **Acción:** secciones.delete
- **Esperado:** success=false, mensaje 'La sección no existe.'

## Caso 7: Listado de secciones
- **Acción:** secciones.list
- **Esperado:** success=true, data es un array de objetos con campos seccion y descripcion.
