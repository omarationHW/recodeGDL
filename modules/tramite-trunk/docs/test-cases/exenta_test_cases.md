# Casos de Prueba para Registro de Exenciones

## Caso 1: Registrar Exención Correcta
- **Entrada:** cvecuenta=12345, axoefec=2024, bimefec=2, observacion="Exención por ley especial"
- **Acción:** registrarExencion
- **Esperado:** status=success, exento='S', mensaje de éxito

## Caso 2: Eliminar Exención Existente
- **Entrada:** cvecuenta=12345, axoefec=2024, bimefec=2, observacion="Fin de exención"
- **Acción:** eliminarExencion
- **Esperado:** status=success, exento='N', mensaje de éxito

## Caso 3: Registrar Exención en Cuenta con Abstención
- **Entrada:** cvecuenta=99999 (cuenta con cvemov=12), axoefec=2024, bimefec=2
- **Acción:** registrarExencion
- **Esperado:** status=error, mensaje='CUENTA CON ABSTENCION. NO SE PUEDE EXENTAR'

## Caso 4: Validación de Año Inválido
- **Entrada:** cvecuenta=12345, axoefec=1960, bimefec=2
- **Acción:** registrarExencion
- **Esperado:** status=error, mensaje de validación

## Caso 5: Validación de Bimestre Inválido
- **Entrada:** cvecuenta=12345, axoefec=2024, bimefec=0
- **Acción:** registrarExencion
- **Esperado:** status=error, mensaje de validación

## Caso 6: Eliminar Exención cuando no existe
- **Entrada:** cvecuenta=12345, axoefec=2024, bimefec=2
- **Acción:** eliminarExencion
- **Esperado:** status=success, exento='N', mensaje de éxito (idempotente)
