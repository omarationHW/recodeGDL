# Documentación Técnica: Migración de Formulario grs_dlg (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda rápida de registros en una tabla/campo arbitrario, similar al formulario grs_dlg de Delphi, migrado a una arquitectura moderna:
- **Backend:** Laravel (PHP) + PostgreSQL (Stored Procedure)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Unificada, patrón eRequest/eResponse, endpoint único `/api/execute`

## 2. Arquitectura
- **Frontend:**
  - Componente Vue.js como página completa, sin tabs.
  - Permite al usuario seleccionar tabla, campo, valor, y opciones de búsqueda.
  - Muestra resultados en tabla dinámica.
- **Backend:**
  - Controlador Laravel `ExecuteController` con método `execute`.
  - Recibe `eRequest` y `params`, despacha a stored procedure.
- **Base de Datos:**
  - Stored Procedure `sp_grs_dlg_search` realiza la búsqueda dinámica en cualquier tabla/campo.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "grs_dlg_search",
    "params": {
      "table": "nombre_tabla",
      "field": "nombre_campo",
      "value": "texto_busqueda",
      "case_insensitive": true,
      "partial": true
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_grs_dlg_search`
- **Parámetros:**
  - `p_table`: nombre de la tabla
  - `p_field`: nombre del campo
  - `p_value`: valor a buscar
  - `p_case_insensitive`: booleano (ILIKE vs LIKE)
  - `p_partial`: booleano (búsqueda parcial o exacta)
- **Retorno:** SETOF RECORD (todas las columnas de la tabla)
- **Seguridad:**
  - Solo debe usarse para tablas/campos permitidos (validar en producción).

## 5. Validaciones y Seguridad
- El controlador valida que `table` y `field` estén presentes.
- En producción, se recomienda validar que la tabla/campo sean permitidos para evitar SQL Injection.
- El stored procedure usa `format` y parámetros para evitar inyección.

## 6. Frontend
- Página Vue.js independiente, con formulario y tabla de resultados.
- Permite limpiar formulario y volver a buscar.
- Muestra mensajes de error y estados de carga.

## 7. Extensibilidad
- Se pueden agregar más eRequest en el mismo endpoint para otras funcionalidades.

## 8. Instalación
- Crear el stored procedure en PostgreSQL.
- Registrar la ruta en Laravel:
  ```php
  Route::post('/api/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```
- Agregar el componente Vue.js en el router de la SPA.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
