# Casos de Prueba: Licencias Relacionadas

## Caso 1: Consulta de todas las licencias relacionadas
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 0 }
- **Esperado:**
  - status: success
  - data: Array con registros de licencias relacionadas

## Caso 2: Consulta por número de licencia
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 1, num_licencia: 12345 }
- **Esperado:**
  - status: success
  - data: Array con relaciones de la licencia 12345

## Caso 3: Consulta por contrato
- **Entrada:**
  - action: listar_licencias_relacionadas
  - params: { opcion: 2, control_contrato: 3215 }
- **Esperado:**
  - status: success
  - data: Array con relaciones del contrato 3215

## Caso 4: Desligar licencia de contrato
- **Entrada:**
  - action: desligar_licencia
  - params: { num_licencia: 12345, control_contrato: 3215 }
- **Esperado:**
  - status: success
  - message: 'Licencia desligada correctamente'

## Caso 5: Error por parámetros inválidos
- **Entrada:**
  - action: desligar_licencia
  - params: { num_licencia: 'abc', control_contrato: null }
- **Esperado:**
  - status: error
  - message: 'Parámetros inválidos'

## Caso 6: Listar tipos de aseo
- **Entrada:**
  - action: listar_tipos_aseo
  - params: { }
- **Esperado:**
  - status: success
  - data: Array de tipos de aseo
