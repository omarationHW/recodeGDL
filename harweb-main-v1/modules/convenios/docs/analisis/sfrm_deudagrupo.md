# Documentación Técnica: Migración de Formulario sfrm_deudagrupo

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrm_deudagrupo` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite la gestión de grupos de deuda (alta, modificación, baja y consulta).

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Controlador unificado `DeudaGrupoController` con endpoint `/api/execute`.
  - Utiliza el patrón eRequest/eResponse para todas las operaciones CRUD.
  - Toda la lógica de acceso a datos se delega a stored procedures en PostgreSQL.

- **Frontend (Vue.js):**
  - Componente de página independiente `DeudaGrupoPage`.
  - Permite listar, crear, editar y eliminar grupos de deuda.
  - Navegación breadcrumb incluida.

- **Base de Datos (PostgreSQL):**
  - Tabla `deudagrupo` (debe existir con campos `id`, `nombre`, `descripcion`).
  - Stored procedures para cada operación CRUD y catálogo.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|show|create|update|delete",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Stored Procedures
- Cada operación (listado, consulta, alta, modificación, baja) tiene su propio stored procedure.
- Todas las operaciones devuelven datos estructurados para facilitar el consumo por la API.

## 5. Frontend
- Página Vue.js independiente.
- Permite todas las operaciones CRUD.
- Mensajes de éxito/error y actualización automática de la tabla.

## 6. Consideraciones
- El endpoint es único y recibe la acción a ejecutar.
- El frontend no utiliza tabs ni componentes compartidos con otros formularios.
- El backend es desacoplado y puede ser reutilizado por otros clientes.

## 7. Requisitos Previos
- La tabla `deudagrupo` debe existir:
  ```sql
  CREATE TABLE deudagrupo (
    id serial PRIMARY KEY,
    nombre varchar(255) NOT NULL,
    descripcion varchar(255)
  );
  ```

## 8. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación según la política de la aplicación.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.

