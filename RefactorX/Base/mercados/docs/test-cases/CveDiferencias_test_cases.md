# Casos de Prueba para CveDiferencias

## 1. Alta de Clave de Diferencia
- **Entrada:** descripcion='DIFERENCIA DE CAJA', cuenta_ingreso=44501, id_usuario=1
- **Acción:** POST /api/execute { action: 'addCveDiferencia', params: {...} }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - La clave aparece en la consulta general

## 2. Modificación de Clave de Diferencia
- **Entrada:** clave_diferencia=1, descripcion='DIFERENCIA DE CAJA CORREGIDA', cuenta_ingreso=44501, id_usuario=1
- **Acción:** POST /api/execute { action: 'updateCveDiferencia', params: {...} }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - La descripción se actualiza en la consulta

## 3. Consulta de Claves
- **Entrada:** N/A
- **Acción:** POST /api/execute { action: 'getCveDiferencias' }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un elemento

## 4. Validación de campos obligatorios
- **Entrada:** descripcion='', cuenta_ingreso=44501, id_usuario=1
- **Acción:** POST /api/execute { action: 'addCveDiferencia', params: {...} }
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message indica error de validación

## 5. Selección de cuenta de ingreso
- **Entrada:** N/A
- **Acción:** POST /api/execute { action: 'getCuentasIngreso' }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data contiene lista de cuentas
