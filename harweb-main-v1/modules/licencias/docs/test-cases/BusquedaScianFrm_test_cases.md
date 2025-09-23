# Casos de Prueba: BusquedaScianFrm Migrado

## Caso 1: Búsqueda por descripción parcial
- **Entrada**: descripcion = 'FARMACIA'
- **Acción**: Buscar
- **Resultado esperado**: Se muestran todos los registros vigentes donde la descripción contiene 'FARMACIA'.

## Caso 2: Búsqueda por código SCIAN
- **Entrada**: descripcion = '561110'
- **Acción**: Buscar
- **Resultado esperado**: Se muestra el registro con código_scian 561110 si está vigente.

## Caso 3: Búsqueda sin filtro
- **Entrada**: descripcion = ''
- **Acción**: Buscar
- **Resultado esperado**: Se muestran todos los registros vigentes de c_scian.

## Caso 4: Búsqueda sin resultados
- **Entrada**: descripcion = 'ZZZZZZZ'
- **Acción**: Buscar
- **Resultado esperado**: Se muestra mensaje 'No se encontraron resultados.'

## Caso 5: Selección y aceptación
- **Entrada**: Buscar 'RESTAURANTE', seleccionar un registro, presionar 'Aceptar'
- **Acción**: Seleccionar y aceptar
- **Resultado esperado**: Se emite evento o alerta con los datos del registro seleccionado.

## Caso 6: Error de backend
- **Simulación**: API responde con error
- **Resultado esperado**: Se muestra mensaje de error en la interfaz.
