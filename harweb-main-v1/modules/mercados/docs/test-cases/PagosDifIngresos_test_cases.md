# Casos de Prueba: Inconsistencias de Pagos

## Caso 1: Consulta de pagos con renta errónea
- **Entrada**: rec=1, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='renta'
- **Acción**: POST /api/execute con action 'getPagosRentaErronea'
- **Resultado esperado**: Lista de pagos con importe_pago <> renta esperada

## Caso 2: Consulta de pagos con datos diferentes en ingresos
- **Entrada**: rec=2, fpadsd=2024-02-01, fpahst=2024-02-29, tipo='datos'
- **Acción**: POST /api/execute con action 'getPagosDiferentes'
- **Resultado esperado**: Lista de pagos con cuenta/caja/operación errónea

## Caso 3: Exportar resultados a Excel
- **Entrada**: rec=1, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='renta'
- **Acción**: POST /api/execute con action 'exportPagosRentaErronea'
- **Resultado esperado**: Descarga de archivo CSV con los resultados

## Caso 4: Validación de campos obligatorios
- **Entrada**: rec='', fpadsd='', fpahst='', tipo='renta'
- **Acción**: POST /api/execute con action 'getPagosRentaErronea'
- **Resultado esperado**: Error de validación, mensaje de campos obligatorios

## Caso 5: Sin resultados
- **Entrada**: rec=99, fpadsd=2024-01-01, fpahst=2024-01-31, tipo='datos'
- **Acción**: POST /api/execute con action 'getPagosDiferentes'
- **Resultado esperado**: Lista vacía, mensaje 'No se encontraron resultados.'
