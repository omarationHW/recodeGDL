# Casos de Prueba: RptLiquidadosGeneralCol

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa con datos | colonia: 12, importe: 5000 | Tabla con contratos, totales y conceptos. |
| 2 | Consulta sin resultados | colonia: 99, importe: 1000 | Mensaje: 'No se encontraron registros...' |
| 3 | Parámetros faltantes | colonia: '', importe: '' | Error: 'Parámetros colonia e importe son requeridos.' |
| 4 | Importe negativo | colonia: 12, importe: -100 | Error de validación en frontend (no permite enviar) |
| 5 | Colonia inexistente | colonia: 9999, importe: 1000 | Mensaje: 'No se encontraron registros...' |
| 6 | Consulta con importe alto | colonia: 12, importe: 999999 | Todos los contratos liquidados de la colonia 12 se muestran |
| 7 | Consulta con importe cero | colonia: 12, importe: 0 | Sólo contratos con saldo exactamente cero se muestran |
| 8 | Consulta con caracteres no numéricos | colonia: 'abc', importe: 'xyz' | Error de validación en frontend |
