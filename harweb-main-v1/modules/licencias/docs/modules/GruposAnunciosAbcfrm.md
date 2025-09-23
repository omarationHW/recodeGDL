# Documentación Técnica: Migración de Formulario Grupos de Anuncios (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful unificada, endpoint `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (peticiones y respuestas estructuradas)

## 2. Endpoint Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "anuncios_grupos_list", // o get, insert, update, delete
    "params": { ... } // parámetros según la operación
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | { ... } | null,
      "message": "..."
    }
  }
  ```

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de acceso y manipulación de datos reside en funciones SQL (ver sección `stored_procedures`).
- Cada operación (listar, obtener, insertar, actualizar, eliminar) tiene su propio SP.
- Los SP retornan siempre el registro afectado o la lista de registros.

## 4. Controlador Laravel
- El controlador `ExecuteController` recibe el eRequest y lo enruta al SP correspondiente.
- Maneja errores y formatea la respuesta según el patrón eResponse.
- No expone lógica de negocio fuera de los SP.

## 5. Componente Vue.js
- Página independiente para Grupos de Anuncios.
- Permite buscar, agregar, modificar y eliminar grupos.
- El formulario de edición/agregado aparece como sección aparte (no modal, no tab).
- Navegación breadcrumb incluida.
- Validación básica en frontend.
- Llama siempre al endpoint `/api/execute` con el eRequest adecuado.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (ej: Laravel Sanctum o Passport).
- Validar y sanear los parámetros en backend y frontend.

## 7. Consideraciones de Migración
- El campo `id` es autoincremental y sólo editable en modo lectura.
- El campo `descripcion` se almacena en mayúsculas (UPPER en SP).
- El filtro de búsqueda es por coincidencia parcial (ILIKE en PostgreSQL).
- El formulario Delphi usaba botones habilitados/deshabilitados según modo; en Vue.js se controla por `formMode`.

## 8. Pruebas
- Ver sección `test_cases` para escenarios de prueba recomendados.

## 9. Extensibilidad
- Para agregar más formularios, replicar el patrón: SPs, eRequest, frontend page.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

