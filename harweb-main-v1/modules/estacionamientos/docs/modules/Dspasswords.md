# Documentación Técnica: Migración de Formulario Dspasswords (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de gestión de contraseñas (Dspasswords) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Se implementa un endpoint API unificado `/api/execute` que recibe peticiones con el patrón `eRequest/eResponse` y delega la lógica de negocio a stored procedures en PostgreSQL.

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Controlador único `ExecuteController` que recibe todas las peticiones relacionadas con passwords.
  - Cada operación (listar, crear, actualizar, eliminar) se mapea a un stored procedure específico.
  - El endpoint `/api/execute` recibe un JSON con `eRequest` y `params`.
- **Frontend (Vue.js):**
  - Componente de página independiente para la gestión de passwords.
  - Permite búsqueda, alta, edición y eliminación de registros.
  - Navegación breadcrumb y feedback de usuario.
- **Base de Datos (PostgreSQL):**
  - Stored procedures para cada operación CRUD y catálogo.
  - Tabla destino: `ta_12_passwords` en la base de datos `BasePHP`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "passwords.list", // o passwords.create, passwords.update, passwords.delete
    "params": { ... } // parámetros según operación
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | null,
      "error": "mensaje de error" | null
    }
  }
  ```

## 4. Stored Procedures
- **sp_passwords_list:** Lista registros, filtrando opcionalmente por usuario.
- **sp_passwords_create:** Inserta un nuevo registro y retorna el registro creado.
- **sp_passwords_update:** Actualiza un registro existente y retorna el registro actualizado.
- **sp_passwords_delete:** Elimina un registro por id_usuario y retorna confirmación.

## 5. Seguridad
- Validación de parámetros en el frontend y backend.
- Uso de prepared statements en Laravel para evitar SQL Injection.
- Se recomienda agregar autenticación y autorización en producción.

## 6. Consideraciones de Migración
- Los nombres de campos y tipos de datos se han mapeado directamente desde Delphi a PostgreSQL.
- El campo `estado` es de tipo CHAR(1) y debe contener un solo carácter.
- El campo `usuario` es clave para la búsqueda y debe ser único si así lo requiere la lógica de negocio.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin modificar la estructura del endpoint.
- Los stored procedures pueden ser extendidos para lógica adicional (auditoría, validaciones, etc).

## 8. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba para ejemplos detallados.
