# Documentación Técnica: Migración Formulario Busca (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Comunicación:** Patrón eRequest/eResponse (JSON), desacoplado, seguro.

## 2. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "searchByNombre", // o searchByDomicilio, etc
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute(Request $request)`.
- Valida acción y parámetros.
- Llama al stored procedure correspondiente vía DB::select('CALL ...').
- Devuelve eResponse con status, data, message.
- Maneja errores y validaciones.

## 4. Vue.js Component
- Página independiente `/busca`.
- Formulario reactivo, cambia campos según tipo de búsqueda.
- Llama a `/api/execute` con eRequest adecuado.
- Muestra resultados en tabla.
- Maneja errores y validaciones.
- NO usa tabs, cada formulario es una página.

## 5. Stored Procedures PostgreSQL
- Cada tipo de búsqueda tiene su propio SP.
- Todos devuelven el mismo formato de columnas para la tabla de resultados.
- Se recomienda crear una vista `vw_conv_complemento` para los campos calculados (subtipo, manzana, lote, letra, aloofi, numofi, letexp).
- Los SP pueden ser extendidos para otros criterios.

## 6. Seguridad
- Validación de parámetros en backend y frontend.
- Sanitización de entradas.
- Uso de roles/autenticación en endpoints reales (no incluido aquí).

## 7. Extensibilidad
- Para agregar nuevas búsquedas, crear nuevo SP y agregar case en el controlador.
- El frontend puede extender el formulario fácilmente.

## 8. Pruebas
- Casos de uso y pruebas incluidas abajo.

## 9. Notas
- El endpoint `/api/execute` puede ser compartido por otros formularios.
- El frontend puede ser adaptado a cualquier diseño, pero debe ser página única por formulario.
- El backend puede ser desacoplado para microservicios si se requiere.
