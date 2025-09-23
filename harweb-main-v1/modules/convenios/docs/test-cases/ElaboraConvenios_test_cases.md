## Casos de Prueba para ElaboraConvenios

### Caso 1: Alta exitosa
- **Entrada:**
  - id_rec: 2
  - id_usu_titular: 101
  - iniciales_titular: "JSM"
  - id_usu_elaboro: 102
  - iniciales_elaboro: "LPR"
- **Acción:** create
- **Resultado esperado:**
  - Código 200, success: true, data contiene el registro creado.

### Caso 2: Alta con datos faltantes
- **Entrada:**
  - id_rec: 2
  - id_usu_titular: 101
  - iniciales_titular: "JSM"
  - id_usu_elaboro: (vacío)
  - iniciales_elaboro: "LPR"
- **Acción:** create
- **Resultado esperado:**
  - Código 422, success: false, errors indica campo requerido.

### Caso 3: Modificación exitosa
- **Entrada:**
  - id_control: 5
  - id_rec: 2
  - id_usu_titular: 101
  - iniciales_titular: "JSM"
  - id_usu_elaboro: 102
  - iniciales_elaboro: "LPR2"
- **Acción:** update
- **Resultado esperado:**
  - Código 200, success: true, data contiene el registro actualizado.

### Caso 4: Eliminación exitosa
- **Entrada:**
  - id_control: 5
- **Acción:** delete
- **Resultado esperado:**
  - Código 200, success: true, data.deleted = true

### Caso 5: Consulta de un registro
- **Entrada:**
  - id_control: 5
- **Acción:** get
- **Resultado esperado:**
  - Código 200, success: true, data contiene el registro solicitado.

### Caso 6: Listado general
- **Entrada:**
  - (sin parámetros)
- **Acción:** list
- **Resultado esperado:**
  - Código 200, success: true, data es un array de registros.
