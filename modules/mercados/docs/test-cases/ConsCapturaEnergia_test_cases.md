# Casos de Prueba para ConsCapturaEnergia

## Caso 1: Consulta de pagos de energía eléctrica
- **Entrada:** id_energia válido
- **Acción:** Llamar a la API con action 'getPagosEnergia'
- **Esperado:** Respuesta success=true, data es un array de pagos, cada pago tiene los campos requeridos.

## Caso 2: Eliminación de pago y restauración de adeudo
- **Entrada:** id_energia, axo, periodo, cve_consumo, cantidad, importe, usuario_id
- **Acción:**
  1. Llamar a 'restoreAdeudoEnergia' con los datos.
  2. Llamar a 'deletePagoEnergia' con id_energia, axo, periodo, usuario_id.
- **Esperado:**
  - Si el adeudo no existe, se inserta y se elimina el pago.
  - Si el adeudo ya existe, sólo se elimina el pago.
  - Respuesta success=true en ambos casos.

## Caso 3: Intento de restaurar adeudo duplicado
- **Entrada:** Adeudo ya existente para ese periodo
- **Acción:** Llamar a 'restoreAdeudoEnergia'
- **Esperado:** Respuesta success=true, mensaje 'Ya existe el adeudo para este periodo'.

## Caso 4: Error de parámetros
- **Entrada:** id_energia nulo o inválido
- **Acción:** Llamar a cualquier acción
- **Esperado:** Respuesta success=false, mensaje de error descriptivo.

## Caso 5: Seguridad
- **Entrada:** Usuario no autenticado
- **Acción:** Llamar a la API
- **Esperado:** Respuesta HTTP 401 Unauthorized.
