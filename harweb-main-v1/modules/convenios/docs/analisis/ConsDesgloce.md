# Documentación Técnica: Consulta Desgloce de Cuentas de Aplicación

## Descripción General
Este módulo permite consultar el desgloce de cuentas de aplicación asociadas a un adeudo específico, mostrando el importe, cuenta y descripción de cada partida. Es una migración del formulario Delphi `ConsDesgloce` a una arquitectura moderna Laravel + Vue.js + PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures
- **API:** Todas las operaciones se realizan vía POST a `/api/execute` con un objeto `eRequest` que define la acción y parámetros

## Flujo de Datos
1. El usuario ingresa el ID de adeudo y envía la consulta.
2. El frontend envía un POST a `/api/execute` con `{ eRequest: { action: 'getDesgloce', params: { id_adeudo } } }`.
3. El backend ejecuta el stored procedure `sp_consdesgloce_get_desgloce` y retorna los resultados en `eResponse.data`.
4. El frontend muestra la tabla con el desgloce.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'getDesgloce', params: { id_adeudo } } }`
  - Salida: `{ eResponse: { success, data, message } }`

## Stored Procedures
- `sp_consdesgloce_get_desgloce(p_id_adeudo INTEGER)`
- `sp_consdesgloce_get_cuentas_aplicacion(p_year INTEGER)`

## Seguridad
- Validación de parámetros en backend
- Manejo de errores y mensajes amigables

## Consideraciones
- El frontend es una página independiente, no usa tabs ni componentes compartidos.
- El backend es desacoplado y puede ser extendido para otras acciones.
- El endpoint es unificado para facilitar integración y pruebas automatizadas.

## Extensibilidad
- Se pueden agregar nuevas acciones al controlador y nuevos stored procedures para otras consultas relacionadas.

