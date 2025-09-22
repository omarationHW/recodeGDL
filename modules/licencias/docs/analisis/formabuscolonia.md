# Documentación Técnica: Migración de Formulario formabuscolonia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la búsqueda y selección de colonias (asentamientos) para un municipio específico (c_mnpio=39) usando una arquitectura moderna:
- **Backend:** Laravel (API RESTful, endpoint unificado `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (con stored procedures)

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedures:** Toda la lógica SQL reside en funciones de PostgreSQL, facilitando el mantenimiento y la seguridad.
- **Frontend:** El componente Vue.js es una página completa, sin tabs, con navegación breadcrumb y UX amigable.

## 3. Endpoints y Protocolo
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "eRequest": "buscar_colonias", // o "obtener_colonia_seleccionada"
      "params": { ... } // parámetros según la operación
    }
    ```
  - **Response:**
    ```json
    {
      "eResponse": {
        "success": true|false,
        "data": [ ... ],
        "message": "..."
      }
    }
    ```

## 4. Stored Procedures
- **sp_buscar_colonias(p_c_mnpio integer, p_filtro text):**
  - Devuelve todas las colonias del municipio cuyo nombre contiene el filtro (insensible a mayúsculas/minúsculas).
- **sp_obtener_colonia_seleccionada(p_c_mnpio integer, p_colonia text):**
  - Devuelve los datos de la colonia seleccionada (nombre exacto).

## 5. Flujo de la Aplicación
1. **Carga inicial:** Se muestran todas las colonias del municipio 39.
2. **Filtrado:** Al escribir en el campo de texto, se filtran las colonias por nombre.
3. **Selección:** El usuario selecciona una colonia de la tabla.
4. **Aceptar:** Al hacer clic en "Aceptar", se muestran los datos de la colonia seleccionada.

## 6. Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint está preparado para autenticación si se requiere.

## 7. Consideraciones de Migración
- El filtro de búsqueda es insensible a mayúsculas/minúsculas (como en Delphi con `LIKE "%...%"`).
- El municipio está fijo en 39, pero puede parametrizarse en el futuro.
- El frontend es completamente independiente y puede integrarse en cualquier SPA Vue.js.

## 8. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 9. Extensibilidad
- Se pueden agregar más stored procedures y eRequests para otras operaciones CRUD sobre colonias.

