# Casos de Prueba: Catálogo de Zonas

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 1 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por ctrol_zona ascendente

## Caso 2: Consulta por Zona y Sub-Zona
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 2 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por zona, sub_zona ascendente

## Caso 3: Consulta por Sub-Zona y Zona
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 3 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por sub_zona, zona ascendente

## Caso 4: Consulta por Descripción
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 4 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true
  - Datos ordenados por descripcion, ctrol_zona ascendente

## Caso 5: Parámetro inválido
- **Entrada:**
  - eRequest: getZonasReport
  - params: { opcion: 99 }
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = true (devuelve todos los datos, sin orden específico)

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: getZonasUnknown
  - params: {}
- **Acción:**
  - POST /api/execute
- **Esperado:**
  - Respuesta eResponse.success = false
  - Mensaje de error indicando eRequest no soportado
