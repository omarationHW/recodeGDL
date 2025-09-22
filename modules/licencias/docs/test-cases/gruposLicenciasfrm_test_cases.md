# Casos de Prueba para Grupos de Licencias

## Caso 1: Crear grupo de licencias
- **Entrada:**
  - eRequest: insert_grupo_licencia
  - params: { "descripcion": "GRUPO TEST QA" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene el grupo creado con descripción 'GRUPO TEST QA'

## Caso 2: Buscar grupos por descripción parcial
- **Entrada:**
  - eRequest: get_grupos_licencias
  - params: { "descripcion": "TEST" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un grupo con 'TEST' en la descripción

## Caso 3: Agregar licencias a grupo
- **Entrada:**
  - eRequest: add_licencias_to_grupo
  - params: { "grupo_id": 1, "licencias": [1001, 1002] }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.added_count = 2

## Caso 4: Quitar licencias de grupo
- **Entrada:**
  - eRequest: remove_licencias_from_grupo
  - params: { "grupo_id": 1, "licencias": [1001] }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.removed_count = 1

## Caso 5: Listar licencias disponibles para grupo
- **Entrada:**
  - eRequest: get_licencias_disponibles
  - params: { "grupo_id": 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array de licencias vigentes no asignadas al grupo 1

## Caso 6: Listar licencias del grupo
- **Entrada:**
  - eRequest: get_licencias_grupo
  - params: { "grupo_id": 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array de licencias vigentes asignadas al grupo 1

## Caso 7: Eliminar grupo de licencias
- **Entrada:**
  - eRequest: delete_grupo_licencia
  - params: { "id": 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.id = 1
