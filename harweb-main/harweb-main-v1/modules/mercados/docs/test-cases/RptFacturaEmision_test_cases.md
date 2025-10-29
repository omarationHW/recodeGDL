# Casos de Prueba: RptFacturaEmision

## Caso 1: Consulta exitosa para un mercado
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 1, "axo": 2024, "periodo": 6, "mercado": 5, "opc": 1 } }
- **Esperado:** status=success, data contiene lista de locales del mercado 5, message correcto.

## Caso 2: Consulta exitosa para todos los mercados
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 2, "axo": 2023, "periodo": 12, "mercado": 0, "opc": 2 } }
- **Esperado:** status=success, data contiene lista de todos los mercados de oficina 2.

## Caso 3: Parámetro faltante
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 1, "axo": 2024, "periodo": "", "mercado": 5, "opc": 1 } }
- **Esperado:** status=error, message indica que 'periodo' es requerido.

## Caso 4: Error de base de datos
- **Simulación:** Forzar error en el SP (ej: pasar oficina inexistente)
- **Esperado:** status=error, message con detalle del error SQL.

## Caso 5: Consulta de vencimiento de recargos
- **Entrada:** { "action": "getVencimientoRec", "params": { "mes": 6 } }
- **Esperado:** status=success, data contiene fechas de recargo y descuento para el mes 6.
