# Documentación Técnica: Migración de Formulario trasladosfrm

## 1. Descripción General
Este módulo permite la gestión de traslados de pagos erróneos, permitiendo buscar pagos, visualizar requerimientos asociados, aplicar traslados (a futuros pagos, saldar adeudos o devolución) y liquidar pagos. La migración se realizó desde Delphi a una arquitectura Laravel + Vue.js + PostgreSQL.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "buscar_pago|obtener_requerimientos|aplicar_traslado|liquidar_pago",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- **buscar_pago:** Busca pagos por recaud, folio, caja, fecha e importe.
- **obtener_requerimientos:** Lista requerimientos asociados a un pago.
- **aplicar_traslado:** Aplica el traslado según tipo (futuros, saldar, devolución).
- **liquidar_pago:** Marca el pago como liquidado.

## 5. Flujo de la Interfaz
1. El usuario ingresa los datos del pago erróneo y busca el pago.
2. Si se encuentra, se muestran los detalles y requerimientos asociados.
3. El usuario selecciona el tipo de aplicación y aplica el traslado.
4. Puede liquidar el pago si es necesario.

## 6. Seguridad
- Validación de parámetros en backend.
- Solo acciones permitidas por el endpoint.

## 7. Consideraciones
- El componente Vue es una página independiente, sin tabs.
- Navegación por breadcrumbs.
- Toda la lógica de negocio reside en stored procedures.

## 8. Extensibilidad
- Para agregar nuevas acciones, crear un nuevo stored procedure y mapearlo en el controlador.
