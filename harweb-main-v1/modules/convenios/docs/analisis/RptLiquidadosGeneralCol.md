# Documentación Técnica: Migración de RptLiquidadosGeneralCol (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario/reporte "RptLiquidadosGeneralCol" originalmente en Delphi, migrado a una arquitectura moderna con backend Laravel, frontend Vue.js y lógica de datos en PostgreSQL mediante stored procedures. El reporte muestra contratos vigentes liquidados con saldo menor o igual a un importe dado, filtrados por colonia.

## 2. Arquitectura
- **Backend**: Laravel API, endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js SPA, página independiente para el reporte.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedure `rpt_liquidados_general_col`.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (colonia, importe) en la página Vue.
2. Vue envía un POST a `/api/execute` con `{ eRequest: 'RptLiquidadosGeneralCol', params: { colonia, importe } }`.
3. Laravel recibe la petición, identifica el eRequest y ejecuta el stored procedure correspondiente.
4. El resultado se retorna en formato JSON bajo la clave `data`.
5. Vue muestra el reporte tabular, totales y leyendas.

## 4. Backend: Laravel
- **Controlador**: `Api\ExecuteController`
- **Método**: `execute(Request $request)`
- **Lógica**:
  - Recibe `eRequest` y `params`.
  - Ejecuta el stored procedure `rpt_liquidados_general_col` con los parámetros recibidos.
  - Devuelve la respuesta en formato `{ success, data, error }`.

## 5. Frontend: Vue.js
- **Componente**: `RptLiquidadosGeneralCol.vue`
- **Características**:
  - Página completa, no usa tabs.
  - Formulario para parámetros.
  - Tabla de resultados con totales y leyendas.
  - Manejo de loading, errores y estados vacíos.
  - Navegación breadcrumb.

## 6. Stored Procedure PostgreSQL
- **Nombre**: `rpt_liquidados_general_col`
- **Entradas**: `p_colonia integer`, `p_importe numeric`
- **Salidas**: Tabla con los campos del reporte, incluyendo lógica de cálculo de pagos reales y concepto (ADE/LIQ/SAF).
- **Ventajas**: Encapsula toda la lógica SQL y de negocio, facilitando mantenimiento y pruebas.

## 7. API Unificada
- **Endpoint**: `/api/execute`
- **Entrada**: JSON `{ eRequest: 'RptLiquidadosGeneralCol', params: { colonia, importe } }`
- **Salida**: JSON `{ success, data, error }`

## 8. Seguridad
- Validación de parámetros en backend.
- El stored procedure sólo expone los datos requeridos.
- Se recomienda proteger el endpoint con autenticación según la política de la aplicación.

## 9. Extensibilidad
- Para agregar nuevos reportes o procesos, basta con:
  - Crear el stored procedure correspondiente.
  - Añadir el case en el controlador Laravel.
  - Crear el componente Vue si es necesario.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

---
