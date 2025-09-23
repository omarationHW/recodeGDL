## Casos de Prueba: Firma Electrónica

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Firma válida | { "firma_digital": "123456" } | success: true, message: 'Firma válida.' |
| 2 | Firma inválida | { "firma_digital": "abcdef" } | success: false, message: 'Firma inválida.' |
| 3 | Campo vacío | { "firma_digital": "" } | success: false, message: 'Firma digital requerida.' |
| 4 | Actualizar firma existente | { "usuario_id": 1, "firma_digital": "nuevaFirma2024" } | success: true, message: 'Firma guardada correctamente.' |
| 5 | Actualizar firma con usuario inexistente | { "usuario_id": 999, "firma_digital": "firmaX" } | success: false, message: 'Usuario no encontrado.' |
