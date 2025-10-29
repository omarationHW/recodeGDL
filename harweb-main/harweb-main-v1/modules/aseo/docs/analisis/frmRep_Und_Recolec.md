# Documentación Técnica: Migración Formulario Unidades de Recolección (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario de impresión y consulta de Unidades de Recolección (`frmRep_Und_Recolec`) del sistema Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel API, expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs), con navegación y breadcrumbs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL se encapsula en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "und_recolec_report",
    "params": {
      "ejercicio": 2024,
      "order": 1
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```
- **Acciones soportadas:**
  - `und_recolec_list`: Listado general
  - `und_recolec_report`: Reporte para impresión/vista previa
  - `und_recolec_create`: Alta
  - `und_recolec_update`: Modificación
  - `und_recolec_delete`: Baja

## 4. Stored Procedures
- Toda la lógica de consulta, ordenamiento y CRUD se realiza en stored procedures PostgreSQL.
- El ordenamiento dinámico se realiza usando `EXECUTE format(...)` para evitar SQL injection.
- Las operaciones de alta/baja verifican restricciones de integridad (no permitir borrar si hay contratos referenciando la unidad).

## 5. Frontend (Vue.js)
- Página independiente `/unidades-recoleccion`.
- Permite seleccionar ejercicio y tipo de ordenamiento.
- Muestra tabla con los resultados del reporte.
- Botón "Vista Previa" ejecuta la consulta y muestra los datos.
- Botón "Salir" regresa a la página anterior.
- Breadcrumbs para navegación.
- Soporte para loading y errores.

## 6. Backend (Laravel)
- Controlador `UndRecolecController` maneja todas las acciones relacionadas.
- Utiliza el endpoint unificado `/api/execute`.
- Cada acción llama al stored procedure correspondiente.
- Manejo de errores y respuestas estándar.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (ej: JWT o session).
- Los parámetros son validados en el frontend y backend.
- El backend valida que los parámetros sean del tipo esperado antes de ejecutar el SP.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.

## 10. Notas de Migración
- El reporte "Vista Previa" corresponde a la funcionalidad de QuickReport en Delphi, ahora se muestra como tabla en la SPA.
- El ordenamiento por "Control", "Clave", "Descripción", "Costo de Unidad" se respeta.
- El ejercicio se puede seleccionar manualmente.
- El backend puede ser extendido para exportar a PDF/Excel si se requiere.
