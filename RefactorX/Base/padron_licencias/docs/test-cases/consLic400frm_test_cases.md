## Casos de Prueba para consLic400frm Migrado

### Caso 1: Consulta exitosa de licencia
- **Entrada:**
  - eRequest: getLic400
  - params: { licencia: 12345 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene un objeto con todos los campos de lic_400

### Caso 2: Consulta exitosa de pagos
- **Entrada:**
  - eRequest: getPagoLic400
  - params: { numlic: 12345 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo con al menos un pago

### Caso 3: Consulta de licencia inexistente
- **Entrada:**
  - eRequest: getLic400
  - params: { licencia: 999999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
  - Frontend muestra mensaje 'No se encontró la licencia.'

### Caso 4: Consulta de pagos sin pagos registrados
- **Entrada:**
  - eRequest: getPagoLic400
  - params: { numlic: 88888 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
  - Frontend muestra mensaje 'No hay pagos registrados para esta licencia.'

### Caso 5: Parámetro faltante
- **Entrada:**
  - eRequest: getLic400
  - params: { }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica que falta el parámetro

### Caso 6: eRequest inválido
- **Entrada:**
  - eRequest: getLicenciaInexistente
  - params: { licencia: 12345 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Invalid eRequest'
