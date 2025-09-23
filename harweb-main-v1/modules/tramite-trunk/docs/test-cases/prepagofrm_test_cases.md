# Casos de Prueba - Formulario Prepago

## Caso 1: Consulta de resumen
- **Entrada:** { "eRequest": { "operation": "getResumen", "params": { "cvecuenta": 12345 } } }
- **Esperado:** Respuesta con los datos del contribuyente, predio y resumen de adeudo.

## Caso 2: Consulta de periodos de adeudo
- **Entrada:** { "eRequest": { "operation": "getPeriodos", "params": { "cvecuenta": 12345 } } }
- **Esperado:** Lista de periodos con valores fiscales, tasas, recargos, etc.

## Caso 3: Consulta de descuentos
- **Entrada:** { "eRequest": { "operation": "getDescuentos", "params": { "cvecuenta": 12345 } } }
- **Esperado:** Lista de descuentos aplicados con descripción e importe.

## Caso 4: Liquidación parcial
- **Entrada:** { "eRequest": { "operation": "liquidacionParcial", "params": { "cvecuenta": 12345, "asalf": 2024, "bsalf": 3 } } }
- **Esperado:** Resumen de pago parcial para el periodo solicitado.

## Caso 5: Último requerimiento
- **Entrada:** { "eRequest": { "operation": "getUltimoRequerimiento", "params": { "cvecuenta": 12345 } } }
- **Esperado:** Datos del último requerimiento practicado.

## Caso 6: Cálculo de multa virtual
- **Entrada:** { "eRequest": { "operation": "calculaMultaVirtual", "params": { "cvecuenta": 12345, "fecha_notificacion": "2024-02-15", "fecha_actual": "2024-03-15" } } }
- **Esperado:** Importe de multa virtual calculada según días de vencimiento y tabla de descuentos.
