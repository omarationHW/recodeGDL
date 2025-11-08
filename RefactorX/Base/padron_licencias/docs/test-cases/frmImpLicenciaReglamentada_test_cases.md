## Casos de Prueba para Licencias Reglamentadas

### Caso 1: Alta exitosa de licencia
- **Entrada:**
  - eRequest: createLicenciaReglamentada
  - params: { "nombre": "Licencia Test", "descripcion": "Test de alta", "usuario_id": 1 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene la nueva licencia con los datos enviados

### Caso 2: Alta con campos obligatorios vacíos
- **Entrada:**
  - eRequest: createLicenciaReglamentada
  - params: { "nombre": "", "descripcion": "", "usuario_id": null }
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message indica error de validación

### Caso 3: Listado de licencias
- **Entrada:**
  - eRequest: getLicenciasReglamentadas
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data es un array (puede estar vacío o con registros)

### Caso 4: Edición exitosa de licencia
- **Entrada:**
  - eRequest: updateLicenciaReglamentada
  - params: { "id": 1, "nombre": "Licencia Editada", "descripcion": "Editada", "usuario_id": 2 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene la licencia actualizada

### Caso 5: Eliminación exitosa de licencia
- **Entrada:**
  - eRequest: deleteLicenciaReglamentada
  - params: { "id": 1 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data.deleted = true

### Caso 6: Eliminación de licencia inexistente
- **Entrada:**
  - eRequest: deleteLicenciaReglamentada
  - params: { "id": 9999 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data.deleted = true (aunque no existía, la operación es idempotente)
