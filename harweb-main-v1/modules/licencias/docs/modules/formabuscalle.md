# Documentación Técnica: Migración de Formulario Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `formabuscalle` al stack Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la búsqueda y selección de calles, excluyendo aquellas marcadas como ocultas en la tabla `c_calles_escondidas`.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente para el formulario de búsqueda de calles.
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de negocio encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "buscar_calles", // o "listar_calles"
    "params": {
      "filtro": "texto a buscar" // solo para buscar_calles
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp_buscar_calles(filtro TEXT):** Devuelve las calles cuyo nombre contiene el filtro, excluyendo las ocultas.
- **sp_listar_calles():** Devuelve todas las calles, excluyendo las ocultas.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Input para filtro de nombre de calle (mayúsculas).
- Tabla con resultados, selección de fila.
- Botón "Aceptar" muestra el ID de la calle seleccionada.
- Breadcrumb de navegación.

## 6. Backend (Laravel)
- Controlador `ExecuteController` con método `execute` que despacha la acción recibida.
- Uso de DB::select para invocar los stored procedures.

## 7. Seguridad
- Validación básica de parámetros.
- El endpoint puede ser protegido por autenticación según la configuración general del API.

## 8. Consideraciones
- El filtro es insensible a mayúsculas/minúsculas (ILIKE en PostgreSQL).
- El frontend asume que el backend retorna los campos de la tabla `c_calles`.
- El formulario es una página completa, no un tab ni modal.

## 9. Tablas involucradas
- `c_calles`: Catálogo de calles.
- `c_calles_escondidas`: Calles ocultas (por vigente = 'V' y num_tag = 8000).

## 10. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
