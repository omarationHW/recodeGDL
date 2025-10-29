# Casos de Prueba: Licencia Microgenerador Ecología

## Caso 1: Alta de Microgenerador (Licencia)
- **Input:**
  - tipo: 'L'
  - id: 12345
- **Acción:** 'alta'
- **Esperado:**
  - success: true
  - data[0].estatus == 1
  - data[0].mensaje contiene 'Alta exitosa'

## Caso 2: Consulta de Microgenerador (Trámite)
- **Input:**
  - tipo: 'T'
  - id: 54321
- **Acción:** 'consulta'
- **Esperado:**
  - success: true
  - data[0].estatus == 1 o 2
  - data[0].mensaje indica si es o no microgenerador

## Caso 3: Cancelación de Microgenerador (Licencia)
- **Input:**
  - tipo: 'L'
  - id: 12345
- **Acción:** 'cancela'
- **Esperado:**
  - success: true
  - data[0].estatus == 1
  - data[0].mensaje contiene 'Cancelación exitosa'

## Caso 4: Error por tipo inválido
- **Input:**
  - tipo: 'X'
  - id: 12345
- **Acción:** 'alta'
- **Esperado:**
  - success: true
  - data[0].estatus == 0
  - data[0].mensaje contiene 'Tipo inválido'

## Caso 5: Error por falta de datos
- **Input:**
  - tipo: 'L'
  - id: null
- **Acción:** 'alta'
- **Esperado:**
  - success: false
  - message contiene 'Tipo y ID requeridos'
