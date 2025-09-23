## Casos de Prueba para Cambio de Firma Electrónica

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Cambio exitoso | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: true, message: 'Firma electrónica actualizada correctamente' |
| 2 | Firma actual incorrecta | usuario: 'jdoe', firma_actual: 'incorrecta', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: false, message: 'La firma actual es incorrecta' |
| 3 | Confirmación no coincide | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'otraFirma789', modulos_id: 1 | success: false, message: 'La confirmación no coincide' |
| 4 | Nueva firma igual a actual | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: 'abc123', firma_conf: 'abc123', modulos_id: 1 | success: false, message: 'La nueva firma no puede ser igual a la actual' |
| 5 | Nueva firma muy corta | usuario: 'jdoe', firma_actual: 'abc123', firma_nueva: '123', firma_conf: '123', modulos_id: 1 | success: false, message: 'La nueva firma debe tener al menos 6 caracteres' |
| 6 | Usuario no existe | usuario: 'noexiste', firma_actual: 'abc123', firma_nueva: 'nuevaFirma456', firma_conf: 'nuevaFirma456', modulos_id: 1 | success: false, message: 'Usuario no encontrado' |
