# Documentación Técnica: Migración de Formulario Colonias (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful unificada con endpoint `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Patrón API:** eRequest/eResponse, todas las operaciones CRUD y reportes se ejecutan vía un solo endpoint.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'colonias.list', params: { ... } } }`
  - Salida: `{ eResponse: { success: true|false, data: [...], message: '' } }`

## Acciones Soportadas
- `colonias.list`   → Lista todas las colonias
- `colonias.create` → Crea una colonia
- `colonias.update` → Actualiza una colonia
- `colonias.delete` → Elimina una colonia
- `colonias.report` → Devuelve el catálogo para impresión/reporte

## Stored Procedures
- Toda la lógica de acceso y validación reside en funciones PostgreSQL:
  - `colonias_list()`
  - `colonias_create(...)`
  - `colonias_update(...)`
  - `colonias_delete(...)`
  - `colonias_report()`

## Validaciones
- El controlador Laravel valida los parámetros antes de llamar al SP.
- Los SP devuelven mensajes de error amigables y controlan excepciones SQL.

## Seguridad
- El endpoint debe protegerse con autenticación JWT o sesión Laravel.
- Los SP sólo pueden ser ejecutados por el usuario autenticado.

## Frontend
- El componente Vue.js es una página completa, con tabla, botones de acción y formularios modales.
- No usa tabs ni subcomponentes tabulares.
- Incluye navegación breadcrumb.
- El reporte se muestra en un modal (puede exportarse a PDF/Excel en versiones futuras).

## Integración
- El frontend consume el endpoint `/api/execute` para todas las operaciones.
- El backend enruta la acción al SP correspondiente y retorna el resultado.

## Migración de Datos
- Los datos existentes deben migrarse a la tabla `ta_17_colonias` en PostgreSQL.
- Los catálogos de zonas y usuarios deben estar sincronizados.

## Consideraciones
- El diseño permite extender el patrón a otros catálogos (calles, zonas, etc).
- El reporte puede adaptarse a formatos PDF/Excel usando librerías Laravel.

# Estructura de la Tabla (PostgreSQL)
```sql
CREATE TABLE ta_17_colonias (
    colonia SMALLINT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
    id_rec SMALLINT NOT NULL,
    id_zona INTEGER NOT NULL,
    col_obra94 SMALLINT,
    id_usuario INTEGER NOT NULL,
    fecha_actual TIMESTAMP DEFAULT now()
);
```

# Ejemplo de eRequest/eResponse
```json
// Solicitud para crear colonia
{
  "eRequest": {
    "action": "colonias.create",
    "params": {
      "colonia": 101,
      "descripcion": "Colonia Nueva",
      "id_rec": 2,
      "id_zona": 5,
      "col_obra94": null,
      "id_usuario": 1
    }
  }
}
```

```json
// Respuesta
{
  "eResponse": {
    "success": true,
    "data": [{"success": true, "message": "Colonia creada correctamente"}],
    "message": ""
  }
}
```

# Flujo de la Página Vue.js
1. Al cargar, llama a `colonias.list` y muestra la tabla.
2. Al hacer clic en "Agregar", abre el formulario modal para crear.
3. Al hacer clic en "Editar", abre el formulario modal con datos precargados.
4. Al guardar, llama a `colonias.create` o `colonias.update`.
5. Al eliminar, llama a `colonias.delete`.
6. Al imprimir, llama a `colonias.report` y muestra el resultado en modal.

# Seguridad y Auditoría
- El campo `id_usuario` y `fecha_actual` permiten rastrear cambios.
- El backend debe validar permisos según el usuario autenticado.

# Extensión
- El patrón es aplicable a cualquier catálogo administrativo.
- Los reportes pueden integrarse con librerías de exportación Laravel.
