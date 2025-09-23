## Casos de Prueba para Actualización de Pagos

### Caso 1: Archivo completamente válido
- **Entrada:** Archivo con 5 líneas, todos los registros existen en la base de datos.
- **Acción:** Subir archivo y aplicar actualización.
- **Esperado:**
  - `success: true`
  - `total: 5`
  - `updated: 5`
  - `errors: 0`
  - `error_lines: []`

### Caso 2: Archivo con registros inexistentes
- **Entrada:** Archivo con 3 líneas, 2 registros existen y 1 no existe.
- **Acción:** Subir archivo y aplicar actualización.
- **Esperado:**
  - `success: false`
  - `total: 3`
  - `updated: 2`
  - `errors: 1`
  - `error_lines` contiene la línea no encontrada y mensaje "No se encontró el registro para actualizar"

### Caso 3: Archivo con líneas mal formateadas
- **Entrada:** Archivo con 4 líneas, 2 líneas válidas y 2 con formato incorrecto (menos de 24 caracteres o letras en campos numéricos).
- **Acción:** Subir archivo y aplicar actualización.
- **Esperado:**
  - `success: false`
  - `total: 4`
  - `updated: 2`
  - `errors: 2`
  - `error_lines` contiene las líneas mal formateadas y mensajes de error de parsing

### Caso 4: Archivo vacío
- **Entrada:** Archivo sin líneas.
- **Acción:** Subir archivo y aplicar actualización.
- **Esperado:**
  - `success: true`
  - `total: 0`
  - `updated: 0`
  - `errors: 0`
  - `error_lines: []`

### Caso 5: Archivo con fecha inválida
- **Entrada:** Línea con fecha '991332' (mes 33, día 32).
- **Acción:** Subir archivo y aplicar actualización.
- **Esperado:**
  - `success: false`
  - `errors: 1`
  - `error_lines` contiene mensaje de error de fecha inválida
