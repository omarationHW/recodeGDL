# Documentación Técnica: Migración Formulario Comprobantes (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de reportes y catálogos en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```
- **Acciones soportadas**:
  - `get_movimientos`: Catálogo de movimientos.
  - `get_departamentos`: Catálogo de departamentos.
  - `get_comprobantes_report`: Reporte detallado de comprobantes.
  - `get_comprobantes_totales_dia`: Totales de comprobantes por día.

## 3. Stored Procedures
- Toda la lógica de filtrado y agrupamiento se implementa en SPs.
- Los SPs reciben parámetros para filtros (fechas, movimiento, capturista, departamento).
- Los SPs devuelven tablas con los campos requeridos para el frontend.

## 4. Frontend (Vue.js)
- Página independiente `/comprobantes`.
- Formulario con filtros: periodo, movimiento, capturista, departamento, totales x día.
- Consulta resultados vía API y muestra tabla.
- Navegación breadcrumb.
- Sin tabs ni componentes tabulares.

## 5. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las acciones.
- Cada acción llama al SP correspondiente usando DB::select.
- Manejo de errores y validación de parámetros.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (ej: Sanctum, JWT).
- Validar tipos y rangos de parámetros en el backend.

## 7. Extensibilidad
- Nuevas acciones pueden agregarse fácilmente siguiendo el patrón.
- Los SPs pueden evolucionar sin afectar el frontend si mantienen la interfaz.

## 8. Pruebas
- Casos de uso y pruebas automatizadas deben cubrir todos los filtros y combinaciones.

## 9. Despliegue
- Crear los SPs en la base de datos destino.
- Configurar rutas y controlador en Laravel.
- Integrar el componente Vue.js en la SPA.

## 10. Notas
- El reporte PDF/impresión puede implementarse en el frontend usando bibliotecas JS (ej: jsPDF, print-this) o en el backend generando PDF desde los datos.
- Los nombres de campos y tablas deben coincidir con la estructura real de la base de datos.
