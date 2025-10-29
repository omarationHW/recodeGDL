# Documentación Técnica: Catálogo de Actividades (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel API, PostgreSQL, lógica de negocio en stored procedures.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **API**: Único endpoint `/api/execute` que recibe `{ action, params }` y responde con `{ success, data, message }`.
- **Patrón**: eRequest/eResponse, desacoplando lógica de presentación y negocio.

## Endpoints y Acciones
- `/api/execute` (POST):
  - `action`: string, nombre de la acción (ej: `catalogo_actividades.list`)
  - `params`: objeto, parámetros requeridos por la acción

### Acciones soportadas
- `catalogo_actividades.list`: Listar actividades (filtro opcional por descripción)
- `catalogo_actividades.get`: Obtener actividad por ID
- `catalogo_actividades.create`: Crear nueva actividad
- `catalogo_actividades.update`: Actualizar actividad existente
- `catalogo_actividades.delete`: Baja lógica de actividad
- `catalogo_actividades.giros`: Listar giros vigentes

## Stored Procedures
- Toda la lógica de acceso y manipulación de datos reside en funciones/procedimientos almacenados en PostgreSQL.
- Se utiliza la extensión `unaccent` para búsquedas insensibles a acentos.
- Las bajas son lógicas (`vigente = 'C'`), nunca se borra físicamente.

## Seguridad
- El controlador asume autenticación previa (JWT/Sanctum).
- El usuario autenticado se utiliza para registrar acciones de alta, modificación y baja.

## Frontend (Vue.js)
- Página independiente, sin tabs ni componentes compartidos.
- CRUD completo: listar, buscar, agregar, editar, eliminar (baja lógica).
- Formulario modal para alta/edición.
- Validación básica en frontend y backend.
- Navegación breadcrumb.
- Tabla con acciones por registro.

## Integración
- El frontend consume el endpoint `/api/execute` con la acción y parámetros adecuados.
- El backend enruta la petición al stored procedure correspondiente y retorna el resultado.

## Consideraciones
- El campo `vigente` controla el estatus ('V' = Vigente, 'C' = Cancelado).
- El campo `id_giro` debe existir y estar vigente en la tabla de giros.
- Los campos de auditoría (`usuario_alta`, `usuario_baja`, etc.) se llenan automáticamente.
- El frontend muestra todos los campos relevantes y permite búsqueda por descripción.

# Diagrama de Flujo
1. Usuario accede a la página de Catálogo de Actividades.
2. Se cargan los giros vigentes y la lista de actividades.
3. El usuario puede buscar, agregar, editar o eliminar actividades.
4. Cada acción llama a `/api/execute` con la acción y parámetros adecuados.
5. El backend ejecuta el stored procedure y retorna el resultado.
6. El frontend actualiza la vista según la respuesta.
