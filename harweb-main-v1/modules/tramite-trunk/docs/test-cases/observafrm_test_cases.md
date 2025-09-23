# Casos de Prueba: Observaciones de Transmisión Patrimonial

## Caso 1: Alta de observación válida
- **Entrada:**
  - cvecuenta: 123456
  - folio: 789
  - observacion: "SE DETECTÓ INCONSISTENCIA EN DOCUMENTOS"
  - usuario: "jlopez"
  - es_global: false
- **Acción:** create
- **Esperado:**
  - Código 200
  - success: true
  - data: objeto con la observación creada

## Caso 2: Alta de observación sin observacion (inválido)
- **Entrada:**
  - cvecuenta: 123456
  - observacion: ""
  - usuario: "jlopez"
- **Acción:** create
- **Esperado:**
  - Código 200
  - success: false
  - message: "The observacion field is required."

## Caso 3: Listado de observaciones
- **Entrada:**
  - cvecuenta: 123456
- **Acción:** list
- **Esperado:**
  - Código 200
  - success: true
  - data: array de observaciones

## Caso 4: Edición de observación
- **Entrada:**
  - id: 5
  - observacion: "DOCUMENTACIÓN COMPLETA, SIN OBSERVACIONES"
  - usuario: "jlopez"
- **Acción:** update
- **Esperado:**
  - Código 200
  - success: true
  - data: objeto actualizado

## Caso 5: Eliminación de observación
- **Entrada:**
  - id: 5
- **Acción:** delete
- **Esperado:**
  - Código 200
  - success: true
  - data: { deleted: true }

## Caso 6: Obtener observación inexistente
- **Entrada:**
  - id: 99999
- **Acción:** get
- **Esperado:**
  - Código 200
  - success: false
  - message: "Observación no encontrada"
