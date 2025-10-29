# Documentación Técnica: Migración de Formulario RptCalles (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario Delphi `RptCalles` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), siguiendo el patrón de API unificada `/api/execute` y empleando stored procedures para la lógica de negocio.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único para API unificada (`/api/execute`).
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Patrón:**
  - **Request:** `{ eRequest: { action: string, data: object } }`
  - **Response:** `{ eResponse: { status: 'success'|'error', message: string, data: any } }`
- **Acción para este formulario:** `RptCalles.getCallesByAxo`
- **Parámetros:** `{ axo: number }`

## 4. Stored Procedure
- **Nombre:** `rpt_calles_get_by_axo`
- **Tipo:** REPORT
- **Parámetro:** `p_axo` (año de obra)
- **Retorna:** Listado de calles, colonias, servicio, tipo y estado calculado ('VIGENTE'/'CANCELADA').
- **Lógica:** Replica el query Delphi, incluyendo el campo calculado `estado`.

## 5. Laravel Controller
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método:** `execute(Request $request)`
- **Lógica:**
  - Valida la estructura del request.
  - Despacha según `eRequest.action`.
  - Para `RptCalles.getCallesByAxo`, llama el SP con el parámetro `axo`.
  - Devuelve los datos en el formato unificado.

## 6. Vue.js Component
- **Nombre:** `RptCallesPage`
- **Características:**
  - Página independiente (no tab).
  - Formulario para seleccionar año (`axo`).
  - Consulta la API y muestra los resultados agrupados por colonia.
  - Incluye encabezado, logo, breadcrumbs y pie de página.
  - Muestra estado, loading y errores.

## 7. Seguridad y Validaciones
- **Backend:**
  - Valida que `axo` sea numérico y requerido.
  - Maneja errores y excepciones.
- **Frontend:**
  - Valida año en el formulario.
  - Maneja estados de carga y error.

## 8. Consideraciones de Migración
- **Campo Calculado:** El campo `estado` se calcula en el SP, replicando la lógica Delphi.
- **Agrupamiento:** El frontend agrupa por colonia para simular el `QRGroup1` de QuickReport.
- **Impresión/Exportación:** Puede agregarse funcionalidad adicional en el frontend si se requiere.

## 9. Extensibilidad
- El endpoint `/api/execute` puede manejar otras acciones y formularios siguiendo el mismo patrón.
- Los stored procedures pueden ser versionados y auditados en la base de datos.

## 10. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad y robustez del sistema.
