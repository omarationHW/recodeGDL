# Casos de Prueba LigaPago

## Caso 1: Ligar pago a requerimiento predial
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Ligar pago
- Verificar que el pago queda ligado en la base de datos (campo cvepago actualizado en reqpredial)

## Caso 2: Ligar pago a transmisión patrimonial
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Seleccionar tipo 'Transmisión Patrimonial' y folio válido
- Ligar pago
- Verificar que el pago queda ligado en la tabla transmisión

## Caso 3: Ligar pago a diferencia de transmisión
- Ingresar cuenta catastral válida y vigente
- Seleccionar pago disponible
- Seleccionar tipo 'Diferencia Transmisión' y folio válido
- Ligar pago
- Verificar que el pago queda ligado en la tabla diferencias

## Caso 4: Intentar ligar pago a cuenta exenta
- Ingresar cuenta catastral exenta
- Verificar que el sistema muestra mensaje de error y no permite continuar

## Caso 5: Intentar ligar pago a cuenta cancelada
- Ingresar cuenta catastral cancelada
- Verificar que el sistema muestra mensaje de error y no permite continuar

## Caso 6: Ligar pago con usuario vacío
- Intentar ligar pago sin proporcionar usuario
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## Caso 7: Ligar pago con folio de transmisión inexistente
- Ingresar folio de transmisión inválido
- Verificar que el sistema muestra mensaje de error
