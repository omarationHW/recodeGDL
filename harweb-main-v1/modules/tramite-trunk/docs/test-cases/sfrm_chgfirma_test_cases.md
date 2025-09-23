## Casos de Prueba para Cambio de Firma Electrónica

### Caso 1: Cambio exitoso
- **Entrada:**
  - usuario: jdoe
  - firma_actual: abc123
  - firma_nueva: nuevaFirma2024
  - firma_conf: nuevaFirma2024
  - modulos_id: 3
- **Esperado:**
  - success: true
  - message: 'Firma electrónica actualizada correctamente.'
  - La firma electrónica en la base de datos se actualiza.

### Caso 2: Firma actual incorrecta
- **Entrada:**
  - usuario: jdoe
  - firma_actual: claveErronea
  - firma_nueva: nuevaFirma2024
  - firma_conf: nuevaFirma2024
  - modulos_id: 3
- **Esperado:**
  - success: false
  - message: 'La firma actual es incorrecta.'
  - La firma electrónica en la base de datos NO se actualiza.

### Caso 3: Confirmación no coincide
- **Entrada:**
  - usuario: jdoe
  - firma_actual: abc123
  - firma_nueva: nuevaFirma2024
  - firma_conf: otraFirma2024
  - modulos_id: 3
- **Esperado:**
  - success: false
  - message: 'La confirmación no coincide con la nueva firma.'
  - La firma electrónica en la base de datos NO se actualiza.

### Caso 4: Nueva firma igual a la actual
- **Entrada:**
  - usuario: jdoe
  - firma_actual: abc123
  - firma_nueva: abc123
  - firma_conf: abc123
  - modulos_id: 3
- **Esperado:**
  - success: false
  - message: 'La nueva firma no puede ser igual a la actual.'

### Caso 5: Usuario no existe
- **Entrada:**
  - usuario: usuario_inexistente
  - firma_actual: cualquier
  - firma_nueva: nuevaFirma2024
  - firma_conf: nuevaFirma2024
  - modulos_id: 3
- **Esperado:**
  - success: false
  - message: 'Usuario no encontrado.'
