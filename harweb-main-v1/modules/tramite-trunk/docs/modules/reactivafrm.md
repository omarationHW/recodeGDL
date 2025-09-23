# Documentación Técnica: Reactivación de Cuenta Catastral

## Descripción General
Este módulo permite la reactivación de cuentas catastrales que se encuentran en estado cancelado (vigente = 'C'). El proceso reactiva la cuenta y sus entidades relacionadas (ubicación, propietario, catastro) y deja registro de la operación.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto eRequest con los parámetros `action` y `params`.
- **Frontend:** Componente Vue.js de página completa, independiente, con navegación breadcrumb y formulario reactivo.
- **Base de Datos:** PostgreSQL, lógica principal en stored procedures.
- **API:** Unificada, patrón eRequest/eResponse.

## Flujo de Proceso
1. El usuario ingresa el número de cuenta catastral.
2. El sistema consulta el estado de la cuenta y muestra los datos principales.
3. Si la cuenta está cancelada (`vigente = 'C'`), se habilita el botón de reactivación.
4. Al confirmar, se ejecuta el stored procedure `sp_reactivar_cuenta`, que actualiza los estados de las tablas relacionadas.
5. El usuario recibe confirmación visual y la cuenta queda activa.

## Endpoints
- **POST /api/execute**
  - **Body:**
    - `action`: string (ej: 'getCuenta', 'reactivarCuenta')
    - `params`: objeto con parámetros específicos
  - **Ejemplo:**
    ```json
    { "action": "reactivarCuenta", "params": { "cvecuenta": 12345 } }
    ```

## Stored Procedures
- `sp_reactivar_cuenta(p_cvecuenta INTEGER)`: Reactiva la cuenta y entidades relacionadas.
- `sp_get_cuenta(p_cvecuenta INTEGER)`: Devuelve datos principales de la cuenta.
- `sp_get_observacion(p_cvecuenta INTEGER)`: Devuelve la observación de la cuenta.

## Validaciones
- Solo se puede reactivar cuentas con `vigente = 'C'`.
- El campo `cvecuenta` es obligatorio.
- El proceso es transaccional: si alguna actualización falla, se revierte todo.

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o session.
- El usuario debe tener permisos para reactivar cuentas.

## Manejo de Errores
- Respuestas JSON con `success`, `message` y `data`.
- Mensajes claros para errores de validación y de base de datos.

## Integración Frontend
- El componente Vue.js consume el endpoint `/api/execute` usando Axios.
- El formulario es reactivo y muestra mensajes de éxito o error.
- El botón de reactivación solo aparece si la cuenta está cancelada.

## Ejemplo de eRequest/eResponse
### eRequest
```json
{
  "action": "reactivarCuenta",
  "params": { "cvecuenta": 12345 }
}
```
### eResponse
```json
{
  "success": true,
  "message": "",
  "data": { "result": "Cuenta reactivada correctamente" }
}
```
