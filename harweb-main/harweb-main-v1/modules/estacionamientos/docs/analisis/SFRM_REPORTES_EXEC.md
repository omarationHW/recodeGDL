# Documentación Técnica: Migración de SFRM_REPORTES_EXEC (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (JSON)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## 3. Operaciones soportadas
- `get_reportes_exec` (params: order_by, group_by)
- `get_adeudos_exec`
- `get_deudores_exec`
- `get_estado_cuenta` (params: no_exclusivo)
- `get_adeudos_detalle` (params: contrato_id, axo, mes)

## 4. Stored Procedures
- Toda la lógica de consulta y cálculo se encapsula en funciones/stored procedures PostgreSQL.
- Los SPs devuelven tablas con la estructura esperada por el frontend.
- Los SPs pueden ser extendidos para incluir filtros adicionales si es necesario.

## 5. Frontend (Vue.js)
- Cada formulario/reporte es una página independiente.
- Navegación mediante breadcrumbs.
- Selección de tipo de reporte y parámetros.
- Visualización de resultados en tabla dinámica.
- Manejo de errores y estados de carga.

## 6. Backend (Laravel)
- Un solo controlador (`ExecuteController`) maneja todas las operaciones.
- El controlador despacha la operación solicitada y ejecuta el SP correspondiente.
- Manejo de errores y validaciones de parámetros.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación (JWT, Sanctum, etc.) en producción.
- Validar y sanitizar todos los parámetros recibidos.

## 8. Extensibilidad
- Para agregar nuevos reportes, basta con crear un nuevo SP y agregar el case correspondiente en el controlador.
- El frontend puede ser extendido para soportar nuevos formularios/páginas.

## 9. Notas de Migración
- Las funciones Delphi que calculan adeudos se asumen como funciones SQL en PostgreSQL (`fn_exc_axomin`, etc.).
- El SP de detalle de adeudos (`cajero_exc_detalle`) se implementa como tabla o vista en PostgreSQL.
- Los nombres de campos y tablas deben coincidir con los de la base de datos destino.

## 10. Pruebas
- Se recomienda usar Postman o similar para pruebas de API.
- El frontend puede ser probado con datos reales o mockeados.

