# Documentación Técnica: Cancelación de Cuenta Catastral

## Descripción General
Este módulo permite la cancelación de cuentas catastrales, replicando la funcionalidad del formulario Delphi `ccuenta.pas` en una arquitectura moderna Laravel + Vue.js + PostgreSQL. Incluye:
- API unificada `/api/execute` con patrón eRequest/eResponse
- Lógica de negocio en stored procedures PostgreSQL
- Componente Vue.js como página completa
- Controlador Laravel centralizado

## Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, endpoint único `/api/execute` que enruta acciones por el campo `action`.
- **Base de Datos**: PostgreSQL, lógica crítica en stored procedures.

## Flujo de Cancelación
1. El usuario accede a la página de cancelación de cuenta.
2. Se cargan los datos de la cuenta y sus valores.
3. Si la cuenta está vigente, el usuario puede iniciar el proceso de cancelación.
4. El usuario ingresa motivo y observación, y confirma la cancelación.
5. El backend ejecuta el stored procedure `cancel_account`, que:
   - Marca la cuenta como cancelada en `convcta`.
   - Inserta un movimiento de cancelación en `catastro`.
   - Cancela requerimientos vigentes en `reqpredial`.
   - Actualiza saldos en `detsaldos`.
   - Llama a `calc_sdos` para recalcular saldos.
6. El frontend muestra el resultado y actualiza el estado de la cuenta.

## API: /api/execute
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "show|start_cancel|confirm_cancel|...",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Acciones soportadas
- `show`: Carga datos de cuenta y valores
- `load_account`: Carga solo datos de cuenta
- `load_values`: Carga solo valores
- `start_cancel`: Muestra formulario de cancelación
- `confirm_cancel`: Ejecuta la cancelación
- `cancel`: Cancela el formulario
- `close`: Libera recursos

## Stored Procedures
- `cancel_account`: Lógica principal de cancelación
- `calc_sdos`: Recalcula saldos (debe implementarse según reglas fiscales)

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel)
- El usuario que ejecuta la cancelación se registra en el movimiento

## Validaciones
- Solo cuentas vigentes pueden ser canceladas
- El motivo es obligatorio
- El usuario debe tener permisos para cancelar

## Integración Vue.js
- El componente recibe el parámetro `cvecuenta` por ruta
- Usa Axios para consumir `/api/execute`
- Muestra mensajes de error y éxito

## Consideraciones
- El proceso es transaccional: si falla algún paso, se revierte todo
- El frontend no permite cancelar cuentas ya canceladas
- El backend valida el estado antes de ejecutar

# Estructura de Tablas Clave
- `convcta`: Catálogo de cuentas catastrales
- `catastro`: Movimientos de cuentas
- `valores`: Valores fiscales asociados
- `reqpredial`: Requerimientos prediales
- `detsaldos`: Detalle de saldos por cuenta

# Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "confirm_cancel",
    "params": {
      "cvecuenta": 12345,
      "motivo": "Duplicidad",
      "observacion": "Cuenta duplicada por error de captura",
      "usuario": "admin"
    }
  }
}
```

# Respuesta Esperada
```json
{
  "eResponse": {
    "success": true,
    "message": "Cuenta cancelada",
    "data": ["OK"]
  }
}
```
