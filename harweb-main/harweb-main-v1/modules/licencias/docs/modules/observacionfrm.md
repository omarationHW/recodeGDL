# Documentación Técnica: Migración de Formulario Observaciones (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario `observacionfrm` de Delphi a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (con lógica en stored procedures). Permite ingresar, guardar y visualizar observaciones en la base de datos `BasePHP`.

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Un controlador API unificado (`ExecuteController`) que expone el endpoint `/api/execute`.
  - Toda la lógica de negocio se canaliza a través de este endpoint usando el patrón `eRequest`/`eResponse`.
  - Las operaciones de base de datos se delegan a stored procedures en PostgreSQL.

- **Frontend (Vue.js):**
  - Un componente de página independiente (`ObservacionPage`) que permite ingresar una observación y ver el historial de observaciones.
  - El textarea convierte automáticamente la entrada a mayúsculas (como en Delphi).
  - Navegación breadcrumb incluida.

- **Base de Datos (PostgreSQL):**
  - Stored procedures para guardar y listar observaciones.
  - Tabla `observaciones` con campos `id`, `observacion`, `created_at`.

## 3. Esquema de Base de Datos
```sql
CREATE TABLE IF NOT EXISTS observaciones (
    id BIGSERIAL PRIMARY KEY,
    observacion TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "save_observacion", // o "get_observaciones"
      "observacion": "Texto de la observación" // solo para guardar
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Observación guardada correctamente.",
      "data": { ... } // o array de observaciones
    }
  }
  ```

## 5. Validaciones
- El campo observación es obligatorio y máximo 2000 caracteres.
- El texto se almacena en mayúsculas (tanto en frontend como en backend).

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.
- Validación de entrada estricta en el backend.

## 7. Consideraciones de Migración
- El botón "Aceptar" cierra el formulario en Delphi; en la web, guarda la observación y limpia el campo.
- El color de fondo del textarea replica el color `clInfoBk` de Delphi.
- El historial de observaciones se muestra debajo del formulario.

## 8. Extensibilidad
- Se pueden agregar acciones adicionales en el endpoint `/api/execute` siguiendo el patrón `action`.
- Los stored procedures pueden ampliarse para edición/eliminación si se requiere.

## 9. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 10. Ejemplo de Uso
- Guardar una observación:
  - POST `/api/execute` con `{ "eRequest": { "action": "save_observacion", "observacion": "Texto" } }`
- Listar observaciones:
  - POST `/api/execute` con `{ "eRequest": { "action": "get_observaciones" } }`
