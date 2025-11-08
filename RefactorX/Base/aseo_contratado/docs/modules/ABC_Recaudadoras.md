# Documentación Técnica: Migración de ABC_Recaudadoras (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.

## Flujo de Solicitudes
1. **Frontend** envía un POST a `/api/execute` con `{ action: '...', params: {...} }`.
2. **Laravel Controller** recibe la petición, despacha según `action` y llama el stored procedure correspondiente.
3. **Stored Procedure** ejecuta la lógica y retorna resultado estructurado.
4. **Controller** retorna JSON `{ success, data, message }`.
5. **Vue Component** actualiza la UI según respuesta.

## Endpoints y Acciones
- `getRecaudadoras`: Lista todas las recaudadoras.
- `insertRecaudadora`: Inserta una recaudadora (requiere `num_rec`, `descripcion`).
- `updateRecaudadora`: Actualiza descripción (requiere `num_rec`, `descripcion`).
- `deleteRecaudadora`: Elimina recaudadora (requiere `num_rec`).

## Validaciones y Seguridad
- Todas las operaciones de inserción/actualización/eliminación se validan en el SP.
- No se permite eliminar recaudadoras con contratos asociados.
- El frontend valida campos requeridos y tipos.

## Manejo de Errores
- Los SP retornan `success` y `message`.
- El controlador propaga errores de SP o de base de datos.
- El frontend muestra mensajes amigables.

## Estructura de la Tabla
```sql
CREATE TABLE ta_16_recaudadoras (
    num_rec SMALLINT PRIMARY KEY,
    descripcion VARCHAR(80) NOT NULL
);
```

## Ejemplo de eRequest/eResponse
```json
{
  "action": "insertRecaudadora",
  "params": {
    "num_rec": 5,
    "descripcion": "Recaudadora Centro"
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": null,
  "message": "Recaudadora agregada correctamente."
}
```

## Navegación y UI
- Cada formulario es una página Vue.js independiente.
- Breadcrumbs para navegación contextual.
- Modales para alta/edición.
- Tabla con acciones de editar/eliminar.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SP pueden ser versionados y auditados.

## Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o similar en producción.

# Notas de Migración
- El formulario Delphi usaba DataSource y Query; ahora todo es API REST + SP.
- El control de errores y mensajes amigables se traslada al SP y frontend.
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página.
