# Documentación Técnica: Migración de Formulario sQRptPagosXContrato

## 1. Descripción General
Este desarrollo migra el formulario de reporte de pagos por contrato (sQRptPagosXContrato) de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página "Pagos por Contrato".
2. Ingresa los parámetros requeridos (control_contrato, contrato, ctrol_aseo) y envía la consulta.
3. El frontend realiza un POST a `/api/execute` con `eRequest: getPagosPorContrato` y los parámetros.
4. El backend ejecuta el stored procedure `rpt_pagos_por_contrato` y retorna los datos y sumatorias.
5. El frontend muestra la tabla de resultados y los totales agrupados.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
```json
{
  "eRequest": "getPagosPorContrato",
  "params": {
    "control": 123,
    "contrato": 123,
    "ctrol_aseo": 4
  }
}
```
- **Respuesta:**
```json
{
  "eResponse": "success",
  "data": [ ... ],
  "summary": { ... },
  "contrato": 123,
  "aseo_label": "HOSPITALARIO"
}
```

## 5. Stored Procedure
- **Nombre:** `rpt_pagos_por_contrato`
- **Entradas:**
  - `p_control_contrato` (integer)
  - `p_contrato` (integer, solo para referencia en frontend)
  - `p_ctrol_aseo` (integer, solo para referencia en frontend)
- **Salida:** Tabla con los campos requeridos para el reporte.
- **Lógica:**
  - Filtra por `control_contrato` y `status_vigencia = 'P'`.
  - Une con operaciones y recaudadoras.
  - Ordena por contrato, periodo y operación.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para parámetros.
- Tabla de resultados y sumatorias.
- Breadcrumb de navegación.
- Manejo de errores y estados de carga.

## 7. Resumen de Sumatorias
- Total de registros y total de importe.
- Totales por tipo de adeudo: CUOTA NORMAL, EXCEDENTE, CONTENEDORES.
- Etiqueta de tipo de aseo según parámetro.

## 8. Seguridad
- Validación de parámetros en backend.
- El stored procedure solo retorna datos permitidos.

## 9. Pruebas
- Casos de uso y escenarios de prueba incluidos en este documento.

## 10. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevos eRequest fácilmente.
- El frontend puede extenderse para otros reportes siguiendo el mismo patrón.
