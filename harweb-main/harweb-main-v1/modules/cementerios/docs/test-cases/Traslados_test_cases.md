# Casos de Prueba - Traslados

## Caso 1: Traslado exitoso
- **Preparación**: Crear pagos en la ubicación origen y asegurar que la ubicación destino existe.
- **Acción**: Ejecutar el flujo completo de traslado.
- **Verificación**: Los pagos aparecen en la ubicación destino y desaparecen de la origen. Mensaje de éxito.

## Caso 2: Origen sin pagos
- **Preparación**: Asegurar que la ubicación origen no tiene pagos.
- **Acción**: Intentar trasladar pagos desde esa ubicación.
- **Verificación**: El sistema muestra mensaje de "No se encontraron pagos en el registro de origen".

## Caso 3: Destino inexistente
- **Preparación**: Asegurar que la ubicación destino no existe.
- **Acción**: Intentar trasladar pagos a esa ubicación.
- **Verificación**: El sistema muestra mensaje de "No se encontraron datos en el registro destino".

## Caso 4: Error de base de datos
- **Preparación**: Simular un error en la base de datos (por ejemplo, bloqueo de tabla).
- **Acción**: Intentar trasladar pagos.
- **Verificación**: El sistema muestra mensaje de error técnico y no realiza ningún cambio.

## Caso 5: Validación de campos obligatorios
- **Preparación**: Dejar campos requeridos vacíos en el formulario.
- **Acción**: Intentar verificar origen o destino.
- **Verificación**: El frontend bloquea el envío y muestra mensajes de validación.
