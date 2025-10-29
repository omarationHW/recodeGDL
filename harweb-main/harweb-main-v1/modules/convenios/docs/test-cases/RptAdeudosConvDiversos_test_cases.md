# Casos de Prueba para RptAdeudosConvDiversos

## Caso 1: Consulta básica de adeudos vigentes
- **Entrada:** tipo=1, subtipo=1, letras='ZC1', estado='A', fecha='2024-06-30'
- **Acción:** POST /api/execute con action 'getRptAdeudosConvDiversos'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con al menos una fila
  - Cada fila contiene los campos: id_conv_diver, letras_exp, numero_exp, axo_exp, nombre, calle, num_exterior, cantidad_total, pagos, recargos, oficio

## Caso 2: Exportación a CSV
- **Precondición:** Se realizó la consulta del caso 1
- **Acción:** Click en 'Exportar CSV' en el frontend
- **Esperado:**
  - Se descarga un archivo .csv
  - El archivo contiene encabezados y filas correspondientes a los datos del reporte

## Caso 3: Consulta de detalle de pagos de un convenio
- **Entrada:** id_conv_diver=12345
- **Acción:** POST /api/execute con action 'getRptAdeudosConvDiversosDetalle'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con los pagos del convenio
  - Cada fila contiene: id_conv_resto, fecha_pago, importe_pago, importe_recargo, pago_parcial, total_parciales

## Caso 4: Consulta con filtros inexistentes
- **Entrada:** tipo=99, subtipo=99, letras='ZZZ', estado='X', fecha='2024-06-30'
- **Acción:** POST /api/execute con action 'getRptAdeudosConvDiversos'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array vacío

## Caso 5: Error de parámetros
- **Entrada:** tipo=null, subtipo=null, letras=null, estado=null, fecha=null
- **Acción:** POST /api/execute con action 'getRptAdeudosConvDiversos'
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message indica error de parámetros
