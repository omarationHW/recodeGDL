# Casos de Prueba: RptEmisionLaser

## Caso 1: Generar reporte con datos válidos
- **Entrada:** { "eRequest": { "action": "getReport", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 3 } } }
- **Esperado:** eResponse.report contiene array de locales con campos id_local, nombre, descripcion_local, meses, rentaaxos, recargos, subtotal.

## Caso 2: Generar reporte con parámetros inexistentes
- **Entrada:** { "eRequest": { "action": "getReport", "params": { "oficina": 99, "axo": 2050, "periodo": 1, "mercado": 99 } } }
- **Esperado:** eResponse.report es array vacío o error indicando que no hay datos.

## Caso 3: Consultar pagos de un local existente
- **Entrada:** { "eRequest": { "action": "getPagos", "params": { "id_local": 123, "axo": 2024, "periodo": 6 } } }
- **Esperado:** eResponse.pagos contiene array de pagos con campos id_pago_local, fecha_pago, importe_pago, folio.

## Caso 4: Consultar meses de adeudo de un local
- **Entrada:** { "eRequest": { "action": "getMesAdeudo", "params": { "id_local": 123, "axo": 2024 } } }
- **Esperado:** eResponse.mes_adeudo contiene array de meses con campos id_adeudo_local, axo, periodo, importe.

## Caso 5: Consultar requerimientos de un local
- **Entrada:** { "eRequest": { "action": "getRequerimientos", "params": { "id_local": 123, "modulo": 11 } } }
- **Esperado:** eResponse.requerimientos contiene array de requerimientos con campos folio, importe_multa, importe_gastos.

## Caso 6: Obtener fecha de descuento
- **Entrada:** { "eRequest": { "action": "getFecDes", "params": { "mes": 6 } } }
- **Esperado:** eResponse.fec_des contiene array con campos fecha_descuento, fecha_recargos.

## Caso 7: Obtener subtotal de local
- **Entrada:** { "eRequest": { "action": "getSubT", "params": { "id_local": 123, "axo": 2024, "periodo": 6 } } }
- **Esperado:** eResponse.subtotal contiene array con campos adeudo, recargos, subtotalcalc.
