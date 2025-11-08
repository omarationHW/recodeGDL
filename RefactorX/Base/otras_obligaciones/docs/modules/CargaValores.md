# Documentación Técnica: Carga de Valores

## Descripción General
El formulario "Carga de Valores" permite al usuario cargar y actualizar los valores de unidades para una tabla seleccionada. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa usando:
- **API Unificada**: Un solo endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Stored Procedures**: Toda la lógica de inserción se realiza en procedimientos almacenados de PostgreSQL.
- **Frontend Vue.js**: Página independiente, sin tabs, con navegación y validación.

## Arquitectura
- **Backend**: Laravel Controller (`ExecuteController`) maneja todas las acciones vía un switch-case sobre el parámetro `action`.
- **Frontend**: Componente Vue.js como página completa, con tabla editable y acciones de agregar/eliminar filas.
- **Base de Datos**: PostgreSQL, con stored procedure para inserción.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de petición**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `get_tablas`: Lista las tablas disponibles.
  - `get_unidades`: Lista las unidades de una tabla y ejercicio.
  - `get_max_id_unidad`: Devuelve el máximo id_34_unidad.
  - `insert_valores`: Inserta múltiples valores en t34_unidades usando el stored procedure.

## Stored Procedure
- **sp_insert_t34_unidades**: Inserta un registro en t34_unidades. Se invoca por cada fila válida desde el backend.

## Flujo de la Página Vue.js
1. Al cargar, obtiene las tablas disponibles.
2. Al seleccionar una tabla, obtiene las unidades del año actual.
3. El usuario puede editar/agregar/eliminar filas.
4. Al hacer clic en "Aplicar", se envían solo las filas válidas al backend.
5. El backend ejecuta la inserción en transacción.
6. Se muestra mensaje de éxito o error.

## Validaciones
- No se permite aplicar si no hay al menos una fila válida (todos los campos llenos y costo > 0).
- El backend valida y responde con éxito/error.

## Seguridad
- Todas las operaciones de inserción se realizan en transacción.
- El endpoint requiere autenticación si la API está protegida.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede adaptarse fácilmente a nuevos campos o validaciones.
