# Casos de Prueba para BloqCtasReq

## Caso 1: Bloquear cuenta válida
- Ingresar recaudadora=1, urbrus=U, cuenta=12345, motivo='Prueba bloqueo', fecha_desbloqueo='2024-06-30', usuario='admin'.
- Esperar mensaje de éxito y ver la cuenta bloqueada en el historial.

## Caso 2: Intentar bloquear cuenta ya bloqueada
- Repetir el caso 1.
- Esperar mensaje de error 'La cuenta ya está bloqueada'.

## Caso 3: Desbloquear cuenta
- Buscar la cuenta bloqueada.
- Ingresar motivo='Regularización', fecha_desbloqueo='2024-07-01', usuario='admin'.
- Esperar mensaje de éxito y ver el movimiento en el historial.

## Caso 4: Consultar historial de bloqueos
- Buscar la cuenta y verificar que el historial muestra todos los movimientos.

## Caso 5: Enviar cuentas bloqueadas a Catastro
- Ejecutar acción 'enviar_catastro' con recaud=1, usuario='admin'.
- Esperar mensaje de éxito y número de cuentas enviadas.

## Caso 6: Desbloqueo masivo
- Ejecutar acción 'desbloqueo_masivo' con usuario='admin'.
- Esperar mensaje de éxito y número de cuentas desbloqueadas.

## Caso 7: Validación de campos obligatorios
- Omitir algún campo requerido y esperar mensaje de error de validación.
