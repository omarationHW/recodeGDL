# Documentación Técnica: Observaciones de Transmisión Patrimonial

## Descripción General
Este módulo permite la gestión de observaciones asociadas a transmisiones patrimoniales (formulario `observafrm` de Delphi) migrado a una arquitectura Laravel + Vue.js + PostgreSQL. Incluye:
- API RESTful unificada (`/api/execute`) bajo el patrón eRequest/eResponse.
- Componente Vue.js de página completa para gestión CRUD de observaciones.
- Stored Procedures en PostgreSQL para todas las operaciones.

## Arquitectura
- **Backend:** Laravel Controller único (`ObservaFrmController`) que recibe todas las acciones vía `/api/execute`.
- **Frontend:** Componente Vue.js independiente, sin tabs, con navegación breadcrumb y formulario completo.
- **Base de Datos:** Tabla `observa_transm` y stored procedures para CRUD.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|get|create|update|delete",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Tabla observa_transm
```sql
CREATE TABLE observa_transm (
    id SERIAL PRIMARY KEY,
    cvecuenta INTEGER NOT NULL,
    folio INTEGER,
    observacion TEXT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    es_global BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## Stored Procedures
- `sp_observa_transm_list(p_cvecuenta)` — Lista observaciones por cuenta
- `sp_observa_transm_get(p_id)` — Obtiene una observación
- `sp_observa_transm_create(p_cvecuenta, p_folio, p_observacion, p_usuario, p_es_global)` — Crea observación
- `sp_observa_transm_update(p_id, p_observacion, p_usuario)` — Actualiza observación
- `sp_observa_transm_delete(p_id)` — Elimina observación

## Seguridad
- Validación de parámetros en backend (Laravel Validator)
- Solo usuarios autenticados pueden crear/modificar/eliminar (agregar middleware según política de la app)

## Frontend
- Página Vue.js independiente, sin tabs.
- Breadcrumb para navegación.
- CRUD completo: listado, alta, edición, borrado.
- Validación de campos obligatorios.
- Observaciones siempre en mayúsculas (evento input).

## Integración
- El componente Vue.js se integra como página independiente en el router.
- El backend expone `/api/execute` para todas las operaciones.
- Las llamadas se hacen vía fetch/AJAX con el patrón eRequest/eResponse.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser reutilizados por otros módulos.
