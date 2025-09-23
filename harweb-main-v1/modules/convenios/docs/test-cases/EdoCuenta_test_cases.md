# Casos de Prueba EdoCuenta

## Caso 1: Consulta exitosa de estado de cuenta
- **Entrada:** { eRequest: { action: 'list', tipo: 1, subtipo: 1 } }
- **Esperado:** Respuesta con success=true y data con al menos un registro.

## Caso 2: Consulta con tipo/subtipo inexistente
- **Entrada:** { eRequest: { action: 'list', tipo: 999, subtipo: 999 } }
- **Esperado:** Respuesta con success=true y data vacía.

## Caso 3: Impresión de reporte detallado
- **Entrada:** { eRequest: { action: 'report', tipo: 1, subtipo: 1 } }
- **Esperado:** Respuesta con success=true y data con detalle de pagos.

## Caso 4: Cálculo de recargos válido
- **Entrada:** { eRequest: { action: 'recargos', id_conv_resto: 123, pago_parcial: 1 } }
- **Esperado:** Respuesta con success=true y data con campo recargos numérico.

## Caso 5: Suma de pagos para convenio
- **Entrada:** { eRequest: { action: 'sumPagos', id_conv_resto: 123 } }
- **Esperado:** Respuesta con success=true y data con total_importe y total_recargo.

## Caso 6: Error por parámetros faltantes
- **Entrada:** { eRequest: { action: 'list' } }
- **Esperado:** Respuesta con success=false y mensaje de error.
