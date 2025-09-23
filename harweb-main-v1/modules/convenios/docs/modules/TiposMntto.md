# Documentación Técnica: Migración Formulario TiposMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (PHP 8+) con endpoint único `/api/execute` para todas las operaciones, usando el patrón eRequest/eResponse.
- **Frontend:** Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|create|update|get",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "data": { ... },
      "message": "..."
    }
  }
  ```

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de negocio y acceso a datos se realiza mediante stored procedures.
- Los procedimientos devuelven siempre un registro o tabla, nunca lanzan excepciones no controladas.
- Ejemplo de uso desde Laravel:
  ```php
  DB::select('SELECT * FROM sp_tipos_list()');
  DB::select('SELECT * FROM sp_tipos_create(?, ?)', [$tipo, $descripcion]);
  ```

## 4. Controlador Laravel
- Un solo controlador maneja todas las acciones del formulario TiposMntto.
- Valida los datos de entrada y llama al stored procedure correspondiente.
- Devuelve siempre un eResponse estructurado.

## 5. Componente Vue.js
- Página independiente para TiposMntto.
- Permite alta, modificación y listado de tipos.
- Usa fetch para comunicarse con `/api/execute`.
- Muestra mensajes de éxito/error y refresca la tabla automáticamente.

## 6. Seguridad
- Validación de datos en backend y frontend.
- Los stored procedures sólo permiten operaciones válidas.
- El endpoint puede protegerse con middleware de autenticación si se requiere.

## 7. Convenciones
- Todos los nombres de procedimientos y parámetros en inglés y snake_case.
- Todas las respuestas de la API siguen el patrón eResponse.

## 8. Extensibilidad
- Para agregar nuevos catálogos, sólo se requieren nuevos stored procedures y ampliar el controlador.
- El frontend puede reutilizar el patrón para otros catálogos.

## 9. Manejo de Errores
- Los errores de validación y de base de datos se devuelven en el campo `message` del eResponse.
- El frontend muestra los mensajes al usuario.

## 10. Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

---
