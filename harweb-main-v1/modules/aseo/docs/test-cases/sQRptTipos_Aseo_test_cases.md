# Casos de Prueba: Catálogo de Tipos de Aseo

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 1 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por ctrol_aseo ascendente

## Caso 2: Consulta por Tipo
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 2 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por tipo_aseo ascendente

## Caso 3: Consulta por Descripción
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 3 }
- **Acción:** POST a /api/execute
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data ordenado por descripcion ascendente

## Caso 4: Sin registros en la tabla
- **Precondición:** ta_16_tipo_aseo está vacía
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 1 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data = []

## Caso 5: Parámetro inválido
- **Entrada:**
  - eRequest: get_tipos_aseo_report
  - params: { opcion: 99 }
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data = [] (o sin error, pero sin resultados)

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: "no_existente"
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message = "eRequest not supported."
