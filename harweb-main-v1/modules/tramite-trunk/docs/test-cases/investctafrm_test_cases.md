# Casos de Prueba: Investigación de Cuentas

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC1  | Registro exitoso de investigación | cvecuenta=12345, observacion='CUENTA EN INVESTIGACION' | success=true, message='Investigación de cuenta actualizada correctamente' |
| TC2  | Cuenta inexistente | cvecuenta=999999, observacion='PRUEBA ERROR' | success=false, message='Cuenta no encontrada' |
| TC3  | Observación vacía | cvecuenta=12345, observacion='' | success=false, message='Parámetros requeridos' |
| TC4  | Consulta de último comprobante | cvecuenta=12345 | success=true, data con feccap, capturista, axocomp, nocomp |
| TC5  | Consulta de último comprobante inexistente | cvecuenta=999999 | success=false, message='No hay comprobantes' |
