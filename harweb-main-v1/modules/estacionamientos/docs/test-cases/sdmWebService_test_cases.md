## Casos de Prueba

### Caso 1: Consulta exitosa de predio existente
- **Entrada:**
  - s_idpredial: '123456'
  - s_opcion: '1'
- **Acción:** Enviar petición a /api/execute con action 'consultaPredio'.
- **Resultado esperado:**
  - status: 'success'
  - data: Array con al menos un predio con cvecuenta = 123456 (o el valor esperado).

### Caso 2: Consulta con ID predial inexistente
- **Entrada:**
  - s_idpredial: '999999'
  - s_opcion: '1'
- **Acción:** Enviar petición a /api/execute con action 'consultaPredio'.
- **Resultado esperado:**
  - status: 'success' o 'error'
  - data: Array vacío o mensaje indicando que no se encontró información.

### Caso 3: Error de validación por campos vacíos
- **Entrada:**
  - s_idpredial: ''
  - s_opcion: ''
- **Acción:** Enviar petición a /api/execute con action 'consultaPredio'.
- **Resultado esperado:**
  - status: 'error'
  - message: Mensaje de validación indicando campos requeridos.

### Caso 4: Error de WebService SOAP caído
- **Entrada:**
  - s_idpredial: '123456'
  - s_opcion: '1'
- **Acción:** Simular caída del WebService SOAP.
- **Resultado esperado:**
  - status: 'error'
  - message: Mensaje de error de conexión o timeout.

### Caso 5: Consulta con caracteres especiales
- **Entrada:**
  - s_idpredial: 'ABC<>&"'
  - s_opcion: '1'
- **Acción:** Enviar petición a /api/execute.
- **Resultado esperado:**
  - status: 'success' o 'error' (según respuesta del WebService)
  - El sistema no debe romperse ni inyectar XML.
