# Documentación Técnica: Migración DetallePagosDiversos Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **API**: Endpoint unificado `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "action": "getPagosDiversosDetalle",
    "params": { "id_conv_resto": 123 }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```
- **Acciones soportadas**:
  - `getPagosDiversosDetalle`: Lista de pagos para un convenio/resto
  - `getDesgloceCuentas`: Desgloce de cuentas para un pago/adeudo
  - `getResumenTotales`: Totales de pagos, recargos, intereses

## 3. Stored Procedures
- Toda la lógica SQL se implementa en stored procedures PostgreSQL:
  - `sp_get_pagos_diversos_detalle(p_id_conv_resto)`
  - `sp_get_desgloce_cuentas(p_id_adeudo)`
  - `sp_get_resumen_totales_pagos_diversos(p_id_conv_resto)`
- Los SPs devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel

## 4. Laravel Controller
- Un solo controlador: `DetallePagosDiversosController`
- Método principal: `execute(Request $request)`
- Internamente llama a los SPs usando DB::select
- Valida parámetros y retorna errores claros
- Puede extenderse para más acciones

## 5. Vue.js Component
- Página independiente: NO usa tabs, es una vista completa
- Permite buscar por id_conv_resto
- Muestra tabla de pagos, totales y permite ver desgloce de cuentas
- Modal para desgloce de cuentas
- Navegación simple, breadcrumbs opcional
- Manejo de errores y loading

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación JWT o session según la política del sistema
- Validar que el usuario tenga permisos para consultar el convenio

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones sin crear nuevos endpoints
- Los SPs pueden evolucionar sin cambiar el frontend

## 8. Pruebas
- Se recomienda usar Postman para pruebas API y Cypress/Jest para frontend

## 9. Migración de lógica Delphi
- La lógica de acumulación de totales y desgloce se trasladó a SPs y a la capa Vue para presentación
- Los campos calculados Delphi se replican en los SPs y en el frontend

## 10. Consideraciones
- Los nombres de tablas y campos deben coincidir con la estructura PostgreSQL
- Si existen triggers o lógica adicional en Delphi, migrar a SPs o eventos DB

---
