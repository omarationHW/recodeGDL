## Casos de Prueba para Propietarios de Hologramas

### Caso 1: Agregar propietario exitosamente
- **Entradas:**
  - nombre: "JUAN PEREZ"
  - domicilio: "AV. PRINCIPAL 123"
  - colonia: "CENTRO"
  - telefono: "555-1234"
  - rfc: "PEPJ800101XXX"
  - curp: "PEPJ800101HDFRRN09"
  - email: "juan.perez@example.com"
  - capturista: "ADMIN"
- **Acción:** Enviar eRequest con operación 'insert_contribholog'.
- **Resultado esperado:**
  - success: true
  - data: contiene el registro insertado con idcontrib asignado.

### Caso 2: Validación de campos obligatorios
- **Entradas:**
  - nombre: ""
  - domicilio: ""
  - capturista: ""
- **Acción:** Enviar eRequest con operación 'insert_contribholog'.
- **Resultado esperado:**
  - success: false
  - message: Indica que los campos son obligatorios.

### Caso 3: Modificar propietario exitosamente
- **Entradas:**
  - idcontrib: 1
  - nombre: "JUAN PEREZ"
  - domicilio: "AV. REFORMA 456"
  - colonia: "CENTRO"
  - telefono: "555-1234"
  - rfc: "PEPJ800101XXX"
  - curp: "PEPJ800101HDFRRN09"
  - email: "juan.perez@example.com"
  - capturista: "ADMIN"
- **Acción:** Enviar eRequest con operación 'update_contribholog'.
- **Resultado esperado:**
  - success: true
  - data: contiene el registro actualizado.

### Caso 4: Eliminar propietario exitosamente
- **Entradas:**
  - idcontrib: 1
- **Acción:** Enviar eRequest con operación 'delete_contribholog'.
- **Resultado esperado:**
  - success: true
  - data: contiene el registro eliminado.

### Caso 5: Eliminar propietario inexistente
- **Entradas:**
  - idcontrib: 9999
- **Acción:** Enviar eRequest con operación 'delete_contribholog'.
- **Resultado esperado:**
  - success: true
  - data: null

### Caso 6: Listar propietarios
- **Entradas:** Ninguna
- **Acción:** Enviar eRequest con operación 'get_contribholog_list'.
- **Resultado esperado:**
  - success: true
  - data: lista de registros existentes.
