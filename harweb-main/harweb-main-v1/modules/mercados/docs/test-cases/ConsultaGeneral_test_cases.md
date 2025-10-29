# Casos de Prueba: Consulta General de Locales

## Caso 1: Búsqueda de Local Existente
- **Entrada:**
  - oficina: 1
  - num_mercado: 10
  - categoria: 2
  - seccion: 'SS'
  - local: 5
  - letra_local: null
  - bloque: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: {...} }
- **Esperado:**
  - success: true
  - data: lista con al menos un local
  - message: 'Local encontrado'

## Caso 2: Búsqueda de Local Inexistente
- **Entrada:**
  - oficina: 1
  - num_mercado: 99
  - categoria: 9
  - seccion: 'ZZ'
  - local: 999
  - letra_local: null
  - bloque: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: {...} }
- **Esperado:**
  - success: true
  - data: []
  - message: 'No existe el local digitado'

## Caso 3: Consulta de Detalle de Local
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'detalle_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: objeto con detalle del local
  - message: 'Detalle encontrado'

## Caso 4: Consulta de Adeudos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'adeudos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de adeudos
  - message: 'Adeudos obtenidos'

## Caso 5: Consulta de Pagos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'pagos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de pagos
  - message: 'Pagos obtenidos'

## Caso 6: Consulta de Requerimientos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'requerimientos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de requerimientos
  - message: 'Requerimientos obtenidos'

## Caso 7: Validación de Parámetros Faltantes
- **Entrada:**
  - oficina: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: { oficina: null } }
- **Esperado:**
  - success: false
  - message: 'The oficina field is required.'
