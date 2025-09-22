# Casos de Prueba: ImpLicenciaReglamentadaFrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta de licencia válida y vigente | licencia = 12345 | Muestra datos completos, botón Imprimir habilitado, detalle de adeudo visible tras imprimir |
| TC02 | Consulta de licencia bloqueada | licencia = 54321 | Mensaje de error: 'La licencia está bloqueada.' |
| TC03 | Consulta de licencia con giro no permitido | licencia = 67890 | Mensaje de error: 'El giro no es de clasificación D.' |
| TC04 | Consulta de licencia inexistente | licencia = 99999 | Mensaje de error: 'Licencia no encontrada o no vigente' |
| TC05 | Impresión de licencia sin calcular adeudo | licencia = 12345, omitir paso de impresión | No muestra detalle de adeudo, botón Imprimir disponible |
| TC06 | Impresión de licencia con error en SP | licencia = 12345, forzar error en SP | Mensaje de error: 'Error al calcular adeudo' |
