# Casos de Prueba: RptAdeudosConvDiversosSaldoAnt

## Caso 1: Parámetros válidos, reporte con resultados
- **Entrada:** tipo=3, subtipo=1, letras=ZO3, estado=A, fechadsd=2024-01-01, fechahst=2024-06-30
- **Acción:** getReport
- **Esperado:** status=success, data=lista no vacía, message='Reporte generado correctamente'

## Caso 2: Parámetros inválidos (falta tipo)
- **Entrada:** subtipo=1, letras=ZO3, estado=A, fechadsd=2024-01-01, fechahst=2024-06-30
- **Acción:** getReport
- **Esperado:** status=error, message='The tipo field is required.'

## Caso 3: Consulta de saldo anterior existente
- **Entrada:** tipo=3, subtipo=1, id_conv_diver=12345, fechadsd=2024-01-01
- **Acción:** getSaldoAnterior
- **Esperado:** status=success, data con campos id_conv_diver, tipo, cantidad_total, pagos

## Caso 4: Consulta de reporte sin resultados
- **Entrada:** tipo=99, subtipo=99, letras=ZZZ, estado=A, fechadsd=2024-01-01, fechahst=2024-06-30
- **Acción:** getReport
- **Esperado:** status=success, data=[], message='Reporte generado correctamente'

## Caso 5: Exportación a CSV
- **Precondición:** Hay datos en el reporte
- **Acción:** Click en 'Exportar CSV'
- **Esperado:** Se descarga archivo con encabezados y filas correspondientes
