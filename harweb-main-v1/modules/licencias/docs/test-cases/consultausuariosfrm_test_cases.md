# Casos de Prueba

## Caso 1: Consulta por usuario exacto
- **Entrada:** usuario = 'jdoe'
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_usuario', params: { usuario: 'jdoe' } }
- **Resultado esperado:**
  - success: true
  - data: array con un registro de usuario 'jdoe'
  - message: ''

## Caso 2: Consulta por nombre (prefijo)
- **Entrada:** nombre = 'JUAN'
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_nombre', params: { nombre: 'JUAN' } }
- **Resultado esperado:**
  - success: true
  - data: array con todos los usuarios cuyo nombre inicia con 'JUAN'
  - message: ''

## Caso 3: Consulta por dependencia y departamento
- **Entrada:** id_dependencia = 2, cvedepto = 5
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_depto', params: { id_dependencia: 2, cvedepto: 5 } }
- **Resultado esperado:**
  - success: true
  - data: array con todos los usuarios del departamento 5 de la dependencia 2
  - message: ''

## Caso 4: Validación de campos requeridos
- **Entrada:** usuario = ''
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_usuario', params: { usuario: '' } }
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'usuario is required'

## Caso 5: Consulta de dependencias
- **Entrada:**
- **Acción:** POST /api/execute { eRequest: 'get_dependencias' }
- **Resultado esperado:**
  - success: true
  - data: array de dependencias
  - message: ''

## Caso 6: Consulta de departamentos por dependencia
- **Entrada:** id_dependencia = 2
- **Acción:** POST /api/execute { eRequest: 'get_deptos_by_dependencia', params: { id_dependencia: 2 } }
- **Resultado esperado:**
  - success: true
  - data: array de departamentos de la dependencia 2
  - message: ''
