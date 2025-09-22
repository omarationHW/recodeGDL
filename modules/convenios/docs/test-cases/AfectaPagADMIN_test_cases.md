# Casos de Prueba para AfectaPagADMIN

## Caso 1: Consulta de pagos por fecha
- **Entrada:** fecha válida con pagos existentes
- **Acción:** action='listar', fecha='2024-06-01'
- **Esperado:** Lista de pagos con campos correctos

## Caso 2: Afectar pagos exitosamente
- **Entrada:** action='afectar', fecha='2024-06-01', usuario='admin'
- **Acción:** Ejecutar afectación
- **Esperado:** success=true, mensaje de éxito, pagos procesados

## Caso 3: Cancelar pago inexistente
- **Entrada:** action='cancelar', id_pago=999999, usuario='admin'
- **Acción:** Ejecutar cancelación
- **Esperado:** success=false, mensaje de error (pago no existe)

## Caso 4: Afectar pago de licencia con error
- **Entrada:** action='licencias', id_pago=12345, usuario='admin'
- **Acción:** Ejecutar afectación
- **Esperado:** success=false si el SP retorna error

## Caso 5: Validación de permisos
- **Entrada:** usuario sin permisos
- **Acción:** Cualquier acción
- **Esperado:** success=false, mensaje de error de permisos

## Caso 6: SQL Injection
- **Entrada:** action='listar', fecha="2024-06-01'; DROP TABLE pagos_admin; --"
- **Acción:** Ejecutar consulta
- **Esperado:** success=false, sin afectación de la BD
