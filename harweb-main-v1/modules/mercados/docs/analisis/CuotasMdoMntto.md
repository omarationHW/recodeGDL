# Documentación Técnica: CuotasMdoMntto (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la administración de las cuotas de mercado por año (ta_11_cuo_locales), incluyendo alta, modificación, eliminación y consulta. Se implementa como una página Vue.js independiente, con backend en Laravel y lógica de negocio en stored procedures PostgreSQL. El API es unificado bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente, sin tabs.
- **Backend:** Laravel Controller único, endpoint `/api/execute`.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **Comunicación:** JSON, patrón eRequest/eResponse.

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|catalogs|get",
      "data": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```
- **Acciones soportadas:**
  - `list`: Listar todas las cuotas
  - `create`: Crear nueva cuota
  - `update`: Actualizar cuota existente
  - `delete`: Eliminar cuota
  - `catalogs`: Obtener catálogos auxiliares (categoría, sección, clave cuota)
  - `get`: Obtener detalle de una cuota

## 4. Stored Procedures
- Toda la lógica de negocio y validación de duplicados está en los SPs.
- Los SPs devuelven boolean para operaciones de escritura.
- El SP de listado devuelve tabla.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para alta/modificación.
- Tabla de listado con acciones editar/eliminar.
- Validación en frontend y backend.
- Navegación breadcrumb.
- Mensajes de éxito/error.

## 6. Seguridad
- El id_usuario debe ser proporcionado por el frontend (en producción, tomar del usuario autenticado).
- Validación de datos en backend y frontend.

## 7. Consideraciones
- El endpoint es único y multipropósito.
- Los catálogos se obtienen vía acción `catalogs`.
- El frontend debe refrescar el listado tras cada operación.

## 8. Migración de SQL
- Todas las operaciones SQL directas se migran a SPs.
- El control de duplicados y validación de existencia se realiza en los SPs.

## 9. Pruebas
- Casos de uso y pruebas incluidas más abajo.

