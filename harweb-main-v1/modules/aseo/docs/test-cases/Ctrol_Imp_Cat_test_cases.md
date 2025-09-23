# Casos de Prueba: Ctrol_Imp_Cat

## Caso 1: Vista previa por número de control
- **Entrada:**
  - action: previewReport
  - params: { order: 1 }
- **Esperado:**
  - success: true
  - data: array ordenada por ctrol_operacion ascendente

## Caso 2: Vista previa por clave
- **Entrada:**
  - action: previewReport
  - params: { order: 2 }
- **Esperado:**
  - success: true
  - data: array ordenada por cve_operacion ascendente

## Caso 3: Vista previa por descripción
- **Entrada:**
  - action: previewReport
  - params: { order: 3 }
- **Esperado:**
  - success: true
  - data: array ordenada por descripcion ascendente

## Caso 4: Parámetro inválido
- **Entrada:**
  - action: previewReport
  - params: { order: 99 }
- **Esperado:**
  - success: true
  - data: array ordenada por ctrol_operacion ascendente (por defecto)

## Caso 5: Error de conexión a BD
- **Simulación:**
  - Desconectar la base de datos
- **Esperado:**
  - success: false
  - message: Mensaje de error de conexión

## Caso 6: Sin registros
- **Simulación:**
  - Vaciar la tabla ta_16_operacion
- **Esperado:**
  - success: true
  - data: []
