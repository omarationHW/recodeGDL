# Casos de Prueba: Catálogo de Gastos

## Caso 1: Crear registro válido
- Ingresar valores positivos en todos los campos.
- Presionar 'Crear'.
- Verificar que el registro se crea y se muestra correctamente.

## Caso 2: Crear registro con valores cero o negativos
- Ingresar 0 o valores negativos en cualquier campo.
- Presionar 'Crear'.
- El sistema debe mostrar un mensaje de error y no permitir la operación.

## Caso 3: Actualizar registro existente
- Modificar uno o más campos del registro actual.
- Presionar 'Actualizar'.
- Verificar que los cambios se reflejan correctamente.

## Caso 4: Eliminar registro
- Presionar 'Eliminar'.
- Confirmar la acción.
- Verificar que la tabla queda vacía.

## Caso 5: Acceso concurrente
- Dos usuarios intentan crear o actualizar el registro al mismo tiempo.
- El sistema debe mantener la integridad y solo permitir un registro.

## Caso 6: Validación de autenticación
- Intentar acceder al endpoint sin autenticación.
- El sistema debe rechazar la petición.
