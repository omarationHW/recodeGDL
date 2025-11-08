# Documentación Técnica: Migración Formulario repdoc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `repdoc` permite consultar e imprimir los requisitos documentales para el trámite de licencias municipales, según el giro seleccionado. La migración implica separar la lógica en backend (Laravel + PostgreSQL) y frontend (Vue.js), usando un API RESTful unificado y procedimientos almacenados para la lógica SQL.

## 2. Arquitectura
- **Backend:** Laravel Controller único (`RepdocController`) con endpoint `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y búsqueda de giros y requisitos.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures (`sp_repdoc_*`).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getGiros|getGiroById|getRequisitosByGiro|printRequisitos",
      "params": { ... }
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
- Toda la lógica de consulta de giros y requisitos se realiza vía SPs:
  - `sp_repdoc_get_giros(tipo)`
  - `sp_repdoc_get_giro_by_id(id_giro)`
  - `sp_repdoc_get_requisitos_by_giro(id_giro)`

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar por actividad, seleccionar giro, ver tipo y descripción, y listar requisitos.
- Botón de impresión usa `window.print()` o puede integrarse con generación de PDF desde backend.
- Navegación breadcrumb incluida.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT o sesión Laravel).
- Validar permisos de usuario para impresión si aplica.

## 7. Consideraciones de Migración
- Los queries SQL Delphi se migran a SPs PostgreSQL.
- El flujo de selección de giro y obtención de requisitos es idéntico al original.
- El reporte impreso puede ser generado en frontend (HTML/CSS) o backend (PDF).

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- Los SPs pueden ser reutilizados por otros módulos.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

---
