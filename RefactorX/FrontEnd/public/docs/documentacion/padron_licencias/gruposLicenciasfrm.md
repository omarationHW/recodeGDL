# Documentación Técnica: gruposLicenciasfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario gruposLicenciasfrm a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de API**: eRequest/eResponse (un solo endpoint, múltiples operaciones)

## Endpoints
- **POST /api/execute**
  - **Body:** `{ "eRequest": "nombre_operacion", "params": { ... } }`
  - **Response:** `{ "eResponse": { "success": true|false, "data": ..., "error": ... } }`

## Operaciones soportadas (eRequest)
- `get_grupos_licencias`: Listar grupos de licencias (filtro opcional por descripción)
- `insert_grupo_licencia`: Crear grupo de licencias
- `update_grupo_licencia`: Editar grupo de licencias
- `delete_grupo_licencia`: Eliminar grupo de licencias
- `get_licencias_disponibles`: Listar licencias vigentes no asignadas al grupo (filtros: actividad, giro)
- `get_licencias_grupo`: Listar licencias vigentes asignadas al grupo (filtro: actividad)
- `add_licencias_to_grupo`: Agregar licencias seleccionadas a grupo
- `remove_licencias_from_grupo`: Quitar licencias seleccionadas del grupo
- `get_giros`: Listar giros de tipo 'L'

## Stored Procedures
- Toda la lógica de negocio y filtros SQL se implementa en funciones de PostgreSQL (ver sección `stored_procedures`).
- Los procedimientos devuelven tablas (TABLE) para facilitar el consumo desde Laravel.

## Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las operaciones.
- Utiliza `DB::select` para invocar los stored procedures.
- El controlador parsea el `eRequest` y llama el SP correspondiente, devolviendo la respuesta en el formato eResponse.

## Componente Vue.js
- Página única para "Grupos de Licencias" (sin tabs, sin subcomponentes tabulares).
- Permite:
  - Buscar, agregar, editar y eliminar grupos.
  - Seleccionar un grupo y administrar sus licencias (agregar/quitar).
  - Filtros por giro y actividad/propietario.
  - Navegación breadcrumb.
- Todas las operaciones usan el endpoint `/api/execute`.

## Seguridad
- Se recomienda proteger el endpoint con autenticación Laravel (middleware `auth:api` o similar).
- Validar los parámetros en el frontend y backend.

## Consideraciones
- El frontend asume que los IDs de licencias y grupos son enteros.
- El array de licencias se pasa como array de enteros en los procedimientos de agregar/quitar.
- El SP de agregar ignora duplicados (ON CONFLICT DO NOTHING).

## Migración de SQL
- Todas las consultas Delphi han sido convertidas a stored procedures parametrizados.
- Se usa ILIKE para búsquedas insensibles a mayúsculas/minúsculas.
- Se reemplaza la función NVL de Oracle por COALESCE en PostgreSQL.

## Exportación a Excel
- No se implementa exportación a Excel en este MVP, pero puede añadirse fácilmente en el frontend usando bibliotecas JS (ej: SheetJS) o en backend con Laravel Excel.

## Casos de Prueba

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

## Casos de Uso

# Casos de Uso - gruposLicenciasfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de licencias

**Descripción:** El usuario desea crear un nuevo grupo de licencias para organizar licencias relacionadas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para crear grupos.

**Pasos a seguir:**
1. El usuario ingresa a la página de Grupos de Licencias.
2. Hace clic en 'Agregar Grupo'.
3. Ingresa la descripción del grupo (ej: 'GRUPO COMERCIAL 2024').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El grupo aparece en la lista de grupos con su nueva descripción.

**Datos de prueba:**
Descripción: 'GRUPO COMERCIAL 2024'

---

## Caso de Uso 2: Agregar licencias existentes a un grupo

**Descripción:** El usuario quiere asignar varias licencias vigentes a un grupo específico.

**Precondiciones:**
Existe al menos un grupo y varias licencias vigentes no asignadas a ese grupo.

**Pasos a seguir:**
1. El usuario selecciona un grupo de la lista.
2. Filtra licencias disponibles por giro o actividad si lo desea.
3. Selecciona varias licencias de la lista de disponibles.
4. Hace clic en 'Agregar al Grupo'.

**Resultado esperado:**
Las licencias seleccionadas desaparecen de la lista de disponibles y aparecen en la lista de licencias del grupo.

**Datos de prueba:**
Grupo: 'GRUPO COMERCIAL 2024', Licencias a agregar: [1001, 1002, 1003]

---

## Caso de Uso 3: Quitar licencias de un grupo

**Descripción:** El usuario necesita remover licencias de un grupo existente.

**Precondiciones:**
El grupo tiene licencias asignadas.

**Pasos a seguir:**
1. El usuario selecciona un grupo de la lista.
2. En la sección 'Licencias en el Grupo', selecciona una o más licencias.
3. Hace clic en 'Quitar del Grupo'.

**Resultado esperado:**
Las licencias seleccionadas desaparecen de la lista del grupo y vuelven a estar disponibles para asignación.

**Datos de prueba:**
Grupo: 'GRUPO COMERCIAL 2024', Licencias a quitar: [1002]

---
