# Documentación Técnica: Migración de Formulario formatosEcologiafrm

## 1. Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica encapsulada en stored procedures

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getTramiteById", // o getTramitesByFecha, getCruceCallesByTramite
    "params": { ... } // parámetros según el eRequest
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": null|string
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica SQL reside en funciones de PostgreSQL:
  - `sp_get_tramite_by_id(id_tramite)`
  - `sp_get_tramites_by_fecha(fecha)`
  - `sp_get_cruce_calles_by_tramite(id_tramite)`
- Los procedimientos devuelven tablas con los campos requeridos y los campos calculados (domcompleto, propietarionvo).

## 4. Laravel Controller
- Controlador `ExecuteController` maneja todas las solicitudes al endpoint `/api/execute`.
- Utiliza `DB::select` para invocar los stored procedures.
- El switch-case en el método `execute` determina qué procedimiento ejecutar según el valor de `eRequest`.
- Maneja errores y devuelve el formato eResponse.

## 5. Vue.js Component
- Página independiente, sin tabs, con navegación breadcrumb.
- Permite buscar por número de trámite o por fecha.
- Muestra resultados en tabla y permite ver detalle de cada trámite.
- Permite simular impresión de reporte (en producción, se integraría con generación de PDF).
- Carga cruce de calles al seleccionar un trámite.
- Maneja errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de funciones parametrizadas para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según sea necesario.

## 7. Extensibilidad
- Para agregar nuevos formularios, basta con agregar nuevos eRequest y stored procedures.
- El frontend puede extenderse con nuevas páginas independientes.

## 8. Pruebas
- Casos de uso y escenarios de prueba incluidos para asegurar la funcionalidad.

## 9. Consideraciones
- La impresión real de reportes debe implementarse en backend (PDF, Jasper, etc.) y el frontend debe consumir el archivo generado.
- El componente Vue es completamente funcional y desacoplado de otros formularios.
