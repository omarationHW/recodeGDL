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
