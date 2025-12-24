# Documentación Técnica: sQRptAdeudosVenc

## Análisis

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



## Casos de Uso

# Casos de Uso - sQRptAdeudosVenc

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vencidos de un Contrato Existente

**Descripción:** El usuario consulta el estado de cuenta de adeudos vencidos para un contrato válido, sin especificar periodo.

**Precondiciones:**
El contrato existe y tiene adeudos vencidos registrados.

**Pasos a seguir:**
1. Ingresar el número de contrato en el formulario.
2. Hacer clic en 'Consultar Estado de Cuenta'.
3. El sistema muestra la empresa, los adeudos vencidos, recargos y totales.

**Resultado esperado:**
Se muestra la tabla de adeudos vencidos, con recargos calculados y totales correctos.

**Datos de prueba:**
control_contrato: 1228

---

## Caso de Uso 2: Consulta de Adeudos Vencidos con Periodo Específico

**Descripción:** El usuario consulta los adeudos vencidos de un contrato, especificando un periodo límite.

**Precondiciones:**
El contrato existe y tiene adeudos en el rango de periodos.

**Pasos a seguir:**
1. Ingresar el número de contrato y el periodo (ej: 2024-06).
2. Hacer clic en 'Consultar Estado de Cuenta'.
3. El sistema muestra los adeudos hasta el periodo indicado.

**Resultado esperado:**
Se muestran solo los adeudos hasta el periodo especificado, con recargos y totales.

**Datos de prueba:**
control_contrato: 1228, periodo: '2024-06'

---

## Caso de Uso 3: Consulta de Contrato sin Adeudos Vencidos

**Descripción:** El usuario consulta un contrato que no tiene adeudos vencidos.

**Precondiciones:**
El contrato existe pero no tiene adeudos vencidos.

**Pasos a seguir:**
1. Ingresar el número de contrato sin adeudos.
2. Hacer clic en 'Consultar Estado de Cuenta'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay adeudos vencidos.

**Datos de prueba:**
control_contrato: 9999

---



## Casos de Prueba

# Casos de Prueba para Estado de Cuenta de Adeudos Vencidos

## Caso 1: Consulta exitosa de adeudos vencidos
- **Entrada:** control_contrato = 1228
- **Acción:** Consultar sin periodo
- **Esperado:**
  - Se muestra la empresa asociada
  - Se listan los adeudos vencidos
  - Se calculan y muestran los recargos
  - Los totales son correctos

## Caso 2: Consulta con periodo límite
- **Entrada:** control_contrato = 1228, periodo = '2024-06'
- **Acción:** Consultar
- **Esperado:**
  - Se muestran solo los adeudos hasta el periodo 2024-06
  - Recargos y totales corresponden a los adeudos filtrados

## Caso 3: Contrato sin adeudos vencidos
- **Entrada:** control_contrato = 9999
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje "No se encontraron adeudos vencidos para este contrato."

## Caso 4: Contrato inexistente
- **Entrada:** control_contrato = 0
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje de error o "No se encontraron adeudos vencidos para este contrato."

## Caso 5: Validación de campos obligatorios
- **Entrada:** control_contrato vacío
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje "Debe ingresar el número de contrato."

## Caso 6: Cálculo correcto de recargos
- **Entrada:** control_contrato con adeudos de diferentes tipos y periodos
- **Acción:** Consultar
- **Esperado:**
  - El importe de recargo para cada adeudo corresponde a la suma de porc_recargo según el periodo calculado

## Caso 7: Consulta con error de conexión
- **Simulación:** API no responde
- **Esperado:**
  - Se muestra mensaje de error de red o conexión


