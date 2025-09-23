# Casos de Prueba: Catálogo de Claves de Operación

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 1 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado por ctrol_operacion ascendente

## Caso 2: Consulta por Clave
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 2 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado por cve_operacion ascendente

## Caso 3: Consulta por Descripción
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 3 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado alfabéticamente por descripcion

## Caso 4: Sin registros en la tabla
- **Precondición:** ta_16_operacion está vacía
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = []

## Caso 5: eRequest inválido
- **Entrada:**
  - eRequest: get_operaciones_x
  - params: { opcion: 1 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica eRequest desconocido
