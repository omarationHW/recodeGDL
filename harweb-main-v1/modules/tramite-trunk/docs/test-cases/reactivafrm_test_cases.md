# Casos de Prueba: Reactivación de Cuenta Catastral

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Reactivar cuenta cancelada | cvecuenta = 10001 | Cuenta y entidades relacionadas quedan con vigente = 'V'. Mensaje de éxito. |
| TC02 | Intentar reactivar cuenta vigente | cvecuenta = 10002 | Botón de reactivación deshabilitado. No se ejecuta proceso. |
| TC03 | Reactivar cuenta inexistente | cvecuenta = 99999 | Mensaje 'Cuenta no encontrada'. |
| TC04 | Reactivar sin permisos | cvecuenta = 10001, usuario sin permisos | Mensaje de error de permisos. |
| TC05 | Reactivar con error en base de datos | cvecuenta = 10001, simular error DB | Mensaje de error técnico. |
