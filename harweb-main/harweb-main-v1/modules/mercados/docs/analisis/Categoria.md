# Documentación Técnica: Módulo Categoría (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario de "Categoría" desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El acceso a la funcionalidad se realiza a través de un endpoint API unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador `CategoriaController`, acceso a procedimientos almacenados PostgreSQL.
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Categoría.
- **Base de Datos:** PostgreSQL, tabla `ta_11_categoria` y stored procedures para CRUD.
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "categoria.create", // o categoria.list, categoria.update, categoria.delete
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true/false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures PostgreSQL
- **sp_categoria_list:** Devuelve todas las categorías.
- **sp_categoria_create:** Inserta una nueva categoría (valida duplicados).
- **sp_categoria_update:** Actualiza la descripción de una categoría existente.
- **sp_categoria_delete:** Elimina una categoría existente.

## 5. Laravel Controller
- Un solo método `execute` que despacha según el valor de `eRequest.action`.
- Valida parámetros y llama a los stored procedures.
- Devuelve siempre la estructura eResponse.

## 6. Vue.js Component
- Página independiente `/categorias`.
- Tabla con listado de categorías.
- Botón para agregar (abre modal).
- Botón para editar (abre modal con datos).
- Botón para eliminar (confirmación).
- Llama al endpoint `/api/execute` para todas las operaciones.
- Mensajes de éxito/error.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la arquitectura global.
- Validar que sólo usuarios autorizados puedan crear/editar/eliminar.

## 8. Consideraciones de Migración
- El campo `categoria` es clave primaria (smallint).
- El campo `descripcion` es varchar(30), se almacena en mayúsculas.
- No hay referencias foráneas en este módulo, pero en producción validar integridad referencial.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.

