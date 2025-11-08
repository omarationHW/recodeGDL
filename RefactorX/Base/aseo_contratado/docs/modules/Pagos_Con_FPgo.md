# Documentación Técnica: Migración Formulario Pagos_Con_FPgo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la consulta de pagos realizados en una fecha específica, permitiendo visualizar el detalle de cada pago y consultar el detalle del contrato relacionado. La migración se realiza desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb y modal para detalle de contrato.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getPagosByFecha",
      "params": { "fecha": "2024-06-01" }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **Acciones soportadas**:
  - `getPagosByFecha`: Lista pagos por fecha de pago.
  - `getContratoDetalle`: Detalle de contrato por control_contrato.
  - `getTipoAseoCatalog`: Catálogo de tipos de aseo.

## 4. Stored Procedures
- Toda la lógica de consulta se implementa en funciones PostgreSQL (ver sección stored_procedures).
- Se recomienda crear índices en las columnas usadas en WHERE para optimizar rendimiento.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar fecha, buscar pagos, ver resultados en tabla y abrir modal con detalle de contrato.
- Filtros y formatos para moneda, fechas y periodos.
- Navegación breadcrumb.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar y sanitizar todos los parámetros recibidos.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser extendidos para soportar nuevos filtros o columnas.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben mapearse fielmente desde el modelo Delphi.
- Los tipos de datos Delphi (Currency, Smallint, etc.) deben mapearse a los equivalentes PostgreSQL.
- El formato de fechas debe ser consistente (YYYY-MM-DD).

## 9. Pruebas y Validación
- Se recomienda usar los casos de uso y pruebas incluidas para validar la funcionalidad.
- El frontend debe manejar errores de red y mostrar mensajes claros al usuario.

## 10. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+

---
