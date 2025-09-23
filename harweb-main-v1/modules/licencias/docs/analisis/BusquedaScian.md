# Documentación Técnica: Migración de BusquedaScianFrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda de giros SCIAN, migrando el formulario Delphi `BusquedaScianFrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). Toda la lógica de consulta reside en un stored procedure, y la comunicación entre frontend y backend se realiza mediante un endpoint API unificado (`/api/execute`) usando el patrón `eRequest`/`eResponse`.

## 2. Arquitectura
- **Frontend**: Componente Vue.js de página completa, sin tabs, con tabla de resultados y campo de búsqueda.
- **Backend**: Controlador Laravel que recibe peticiones unificadas y ejecuta el stored procedure correspondiente.
- **Base de Datos**: Stored procedure en PostgreSQL que realiza la búsqueda filtrada.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request Body**:
  ```json
  {
    "eRequest": "catalog.scian.search",
    "params": {
      "descripcion": "texto a buscar"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "error": null
  }
  ```

## 4. Stored Procedure
- **Nombre**: `catalogo_scian_busqueda(p_descripcion TEXT)`
- **Funcionalidad**: Devuelve todos los registros vigentes de `c_scian` filtrando por descripción o código_scian (parcial, insensible a mayúsculas/minúsculas). Si el parámetro es vacío, devuelve todos los vigentes.

## 5. Controlador Laravel
- **Archivo**: `app/Http/Controllers/Api/ExecuteController.php`
- **Método principal**: `handle(Request $request)`
- **Lógica**:
  - Lee `eRequest` y `params`.
  - Ejecuta el stored procedure adecuado según el valor de `eRequest`.
  - Devuelve la respuesta en formato estándar.

## 6. Componente Vue.js
- **Archivo**: `BusquedaScianPage.vue`
- **Características**:
  - Página completa con breadcrumb.
  - Campo de búsqueda reactivo.
  - Tabla de resultados con selección.
  - Botón "Aceptar" habilitado solo si hay selección.
  - Manejo de errores y estados vacíos.

## 7. Seguridad y Validaciones
- El backend valida el valor de `eRequest`.
- El stored procedure previene SQL Injection usando parámetros.
- El frontend limita la longitud del campo de búsqueda.

## 8. Extensibilidad
- Se pueden agregar nuevos `eRequest` en el controlador para otras operaciones.
- El stored procedure puede ampliarse para más filtros si es necesario.

## 9. Consideraciones de Migración
- El campo `vigente` se filtra por 'V' (vigente).
- La búsqueda es insensible a mayúsculas/minúsculas y permite buscar por descripción o código.
- El formulario Delphi usaba un grid y un campo de texto; esto se replica en la UI Vue.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 10

---
