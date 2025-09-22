# Casos de Prueba: Empresas_Contratos

## Caso 1: Consulta general (sin filtros)
- **Entrada:**
  - parOpc: 'T'
  - parDescrip: ''
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: lista de todas las empresas y contratos

## Caso 2: Búsqueda por filtro (nombre de empresa)
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: 'FARMACIA'
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: solo empresas cuyo nombre o representante contiene 'FARMACIA'

## Caso 3: Filtro por tipo de aseo y vigencia
- **Entrada:**
  - parOpc: 'T'
  - parDescrip: ''
  - parTipo: 'O'
  - parVigencia: 'V'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: solo contratos ordinarios vigentes

## Caso 4: Filtro sin resultados
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: 'ZZZZZZZZ'
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'success'
  - data: [] (vacío)

## Caso 5: Error de parámetros
- **Entrada:**
  - parOpc: 'A'
  - parDescrip: ''
  - parTipo: 'T'
  - parVigencia: 'T'
- **Acción:** POST /api/execute con eRequest=empresas_contratos_list
- **Resultado esperado:**
  - status: 'error'
  - message: 'Falta el dato de búsqueda' o validación frontend
