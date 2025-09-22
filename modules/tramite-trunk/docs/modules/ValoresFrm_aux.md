# Documentación Técnica: Migración de Formulario ValoresFrm_aux a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `ValoresFrm_aux` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite la gestión de valores fiscales y tasas por año/bimestre, con observaciones y rangos.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` bajo patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getValoresAuxList", // o createValoresAux, updateValoresAux, deleteValoresAux, getValoresAuxById
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de acceso y manipulación de datos reside en funciones de PostgreSQL:
  - `get_valores_aux_list()`
  - `get_valores_aux_by_id(p_id)`
  - `create_valores_aux(...)`
  - `update_valores_aux(...)`
  - `delete_valores_aux(p_id)`

## 5. Estructura de la Tabla (valores_aux)
```sql
CREATE TABLE valores_aux (
    id SERIAL PRIMARY KEY,
    axoefec INTEGER NOT NULL,
    bimefec INTEGER NOT NULL,
    valfiscal NUMERIC(18,2) NOT NULL,
    tasa NUMERIC(10,4) NOT NULL,
    axosobre INTEGER,
    ahasta INTEGER,
    bhasta INTEGER,
    observacion TEXT
);
```

## 6. Frontend (Vue.js)
- Página independiente `/valores-aux`.
- Formulario para crear/editar registros.
- Tabla para listar, editar y eliminar registros.
- Filtros "Valores modificados" y "Valores nuevos" simulados (pueden conectarse a flags reales si se requiere).
- Mensajes de éxito/error.

## 7. Backend (Laravel)
- Controlador `ValoresAuxController` con método `execute`.
- Llama a los stored procedures según la acción recibida.
- Manejo de errores y validaciones básicas.

## 8. Seguridad
- Validación de parámetros en backend.
- Se recomienda proteger el endpoint con autenticación (no incluido en este ejemplo).

## 9. Pruebas
- Casos de uso y pruebas detalladas en las secciones siguientes.

## 10. Extensibilidad
- Se pueden agregar más acciones/procedimientos siguiendo el mismo patrón.
- El frontend puede extenderse para incluir paginación, búsqueda avanzada, etc.
