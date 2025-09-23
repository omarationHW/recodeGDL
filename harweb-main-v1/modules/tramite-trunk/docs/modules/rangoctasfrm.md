# Documentación Técnica: Migración Formulario rangoctasfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de impresión de extractos de adquiriente por rango de cuentas o por capturista y fechas, migrando la lógica del formulario Delphi `rangoctasfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse para ejecutar acciones del formulario.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación y validación de campos.
- **Base de Datos**: Toda la lógica SQL se implementa en stored procedures PostgreSQL, que son invocados desde el backend.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "print_by_recaudadora|print_by_capturista",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Lógica de Negocio
- **Por Recaudadora**: El usuario ingresa recaudadora, cuenta inicial y final. El backend llama al SP `sp_extractos_rango_cuentas` y retorna los extractos.
- **Por Capturista**: El usuario ingresa capturista y rango de fechas. El backend llama al SP `sp_extractos_rango_capturista` y retorna los extractos.
- **Validaciones**: Se validan los campos requeridos en backend y frontend.
- **Impresión**: El resultado puede ser mostrado en pantalla o exportado a PDF/Excel según necesidades futuras.

## 5. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel, no mostrado aquí).
- Los parámetros son validados y sanitizados antes de ejecutar los SP.

## 6. Integración con otros módulos
- El endpoint `/api/execute` puede ser extendido para otros formularios siguiendo el patrón eRequest/eResponse.
- Los SP pueden ser reutilizados por otros reportes.

## 7. Estructura de la Base de Datos
- Se asume la existencia de la tabla/materialized view `extractos_adq` con todos los campos requeridos para los extractos.
- Los SP pueden ser adaptados si la estructura cambia.

## 8. Extensibilidad
- El controlador puede ser extendido para soportar más acciones.
- El componente Vue puede ser adaptado para otros reportes similares.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.

## 10. Notas de Migración
- El reporte impreso en Delphi (con ReportBuilder) se reemplaza por la visualización en tabla en Vue.js. La exportación a PDF/Excel puede ser implementada posteriormente.
- La lógica condicional de visibilidad de campos y validaciones se replica en el frontend y backend.

