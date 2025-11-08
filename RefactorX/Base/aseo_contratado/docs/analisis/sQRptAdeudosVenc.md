# Documentación Técnica: Migración de Formulario sQRptAdeudosVenc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de "Estado de Cuenta de Adeudos Vencidos". Permite consultar, calcular y mostrar los adeudos vencidos de un contrato, incluyendo recargos, multas y gastos, agrupando y sumando por tipo de adeudo.

La migración implementa:
- Backend API unificada en Laravel (endpoint `/api/execute`)
- Lógica de negocio y consultas SQL en stored procedures PostgreSQL
- Frontend en Vue.js como página independiente

## 2. Arquitectura
- **API Unificada**: Un solo endpoint `/api/execute` recibe peticiones con el patrón eRequest/eResponse, ejecutando acciones según el parámetro `action`.
- **Stored Procedures**: Toda la lógica SQL y de negocio reside en funciones de PostgreSQL, invocadas desde Laravel.
- **Frontend**: Un componente Vue.js consulta el API, muestra los datos y permite la navegación.

## 3. Flujo de Consulta
1. El usuario ingresa el número de contrato y (opcionalmente) un periodo.
2. El frontend solicita el día límite del mes actual (`sp_get_dia_limite`).
3. Se consulta la lista de adeudos vencidos para el contrato (`sp_get_adeudos_vencidos`).
4. Se obtiene la información de la empresa asociada (`sp_get_empresa`).
5. Para cada adeudo, se calcula el importe de recargo (`sp_get_importe_recargo`).
6. Se muestran los resultados agrupados y sumados.

## 4. API Backend
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "getAdeudosVencidos", // o getDiaLimite, getEmpresa, getImporteRecargo
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 5. Stored Procedures
- **sp_get_dia_limite**: Devuelve el día límite para el mes.
- **sp_get_empresa**: Devuelve los datos de la empresa.
- **sp_get_adeudos_vencidos**: Devuelve los adeudos vencidos según la lógica de periodos y día límite.
- **sp_get_importe_recargo**: Calcula el importe de recargo para cada adeudo.

## 6. Frontend Vue.js
- Página independiente, no usa tabs.
- Permite ingresar número de contrato y periodo.
- Muestra empresa, tabla de adeudos, totales y recargos.
- Usa Axios para consumir el API.

## 7. Consideraciones Técnicas
- Todas las fechas y periodos se manejan en formato `yyyy-mm`.
- El cálculo de recargos sigue la lógica original Delphi.
- El API es extensible para otras acciones.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

## 8. Seguridad
- Validar que el usuario tenga permisos para consultar contratos.
- Sanitizar entradas en el backend.

## 9. Pruebas
- Se incluyen casos de uso y escenarios de prueba para validar la funcionalidad.

