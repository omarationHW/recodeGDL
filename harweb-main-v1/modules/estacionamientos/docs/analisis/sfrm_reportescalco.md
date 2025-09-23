# Documentación Técnica: Migración de Formulario sfrm_reportescalco a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrm_reportescalco` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de generación de reportes de calcomanías expedidas y folios capturados, permitiendo la consulta y exportación de datos mediante una interfaz web y un API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "nombre_de_la_accion",
    "params": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": "mensaje de error si aplica"
    }
  }
  ```

### eRequest soportados:
- `get_calcomania_report` (params: fecha1, fecha2)
- `get_folios_report` (params: fechora)
- `get_inspectors` (sin params)

## 4. Stored Procedures
Toda la lógica SQL se encapsula en funciones PostgreSQL:
- `sp_catalog_inspectors()`: Catálogo de inspectores.
- `sp_report_calcomanias(fecha1, fecha2)`: Reporte de calcomanías expedidas.
- `sp_report_folios(fechora)`: Reporte de folios capturados por inspector.

## 5. Controlador Laravel
- Controlador: `Api\ExecuteController`
- Método principal: `execute(Request $request)`
- Realiza el dispatch según el valor de `eRequest` y ejecuta el stored procedure correspondiente.
- Maneja errores y retorna la respuesta en formato estándar.

## 6. Componente Vue.js
- Página independiente, ruta sugerida: `/reportescalco`
- Permite seleccionar periodo de fechas y generar ambos reportes.
- Muestra los resultados en tablas responsivas.
- Incluye navegación breadcrumb.
- Llama al endpoint `/api/execute` con el eRequest adecuado.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la política de la aplicación.
- Validar y sanear los parámetros recibidos.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad y robustez del módulo.

## 9. Consideraciones
- El frontend no implementa impresión directa, pero la tabla puede ser exportada o impresa desde el navegador.
- El backend puede ser extendido para exportar PDF/Excel si se requiere.

## 10. Dependencias
- Laravel 10+
- Vue.js 3+
- PostgreSQL 12+

## 11. Migración de Datos
- Se asume que las tablas `ta14_calcomanias`, `ta14_personas`, `ta14_folios_adeudo`, y `ta14_agentes` existen y están pobladas en PostgreSQL.

## 12. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin modificar la estructura del endpoint.
