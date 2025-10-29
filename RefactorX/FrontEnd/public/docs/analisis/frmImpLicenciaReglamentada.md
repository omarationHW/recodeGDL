# Documentación Técnica: Migración de frmImpLicenciaReglamentada a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `frmImpLicenciaReglamentada` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite la gestión CRUD de "Licencias Reglamentadas".

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Controlador `ImpLicenciaReglamentadaController` con endpoint unificado `/api/execute`.
  - Uso del patrón eRequest/eResponse para todas las operaciones.
  - Lógica de negocio y acceso a datos delegada a stored procedures en PostgreSQL.

- **Frontend (Vue.js):**
  - Componente de página independiente `ImpLicenciaReglamentadaPage`.
  - Navegación breadcrumb.
  - Formularios para alta, edición y listado de licencias.

- **Base de Datos (PostgreSQL):**
  - Tabla `licencias_reglamentadas` (debe existir con los campos: id, nombre, descripcion, usuario_id, created_at, updated_at).
  - Stored procedures para operaciones CRUD.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: String que indica la operación (ej: `getLicenciasReglamentadas`, `createLicenciaReglamentada`, etc.)
  - `params`: Objeto con los parámetros necesarios para la operación.
- **Salida:**
  - `eResponse`: Objeto con `success`, `data`, y `message`.

## 4. Stored Procedures
- **sp_get_licencias_reglamentadas:** Listado de licencias.
- **sp_create_licencia_reglamentada:** Alta de licencia.
- **sp_update_licencia_reglamentada:** Modificación de licencia.
- **sp_delete_licencia_reglamentada:** Eliminación de licencia.

## 5. Flujo de Datos
1. El usuario interactúa con la página Vue.js.
2. Vue.js envía solicitudes POST a `/api/execute` con el eRequest y parámetros.
3. Laravel recibe la solicitud, ejecuta el stored procedure correspondiente y retorna la respuesta estructurada.
4. Vue.js actualiza la interfaz según la respuesta.

## 6. Consideraciones
- El frontend es una página independiente, no usa tabs ni componentes compartidos.
- El backend centraliza todas las operaciones en un solo endpoint para facilitar la integración y el mantenimiento.
- Los stored procedures encapsulan toda la lógica SQL, facilitando la trazabilidad y el mantenimiento de la base de datos.

## 7. Seguridad
- Validar y sanitizar todos los parámetros recibidos en el backend.
- Se recomienda implementar autenticación y autorización en el endpoint `/api/execute`.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad completa del módulo.
