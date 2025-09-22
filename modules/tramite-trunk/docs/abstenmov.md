# Documentación Técnica: Abstención de Movimientos (abstenmov)

## Descripción General
Este módulo permite registrar y eliminar la abstención de movimientos para una cuenta catastral. La abstención impide modificaciones en el propietario y otros movimientos hasta que sea eliminada.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio.

## Flujo de Trabajo
1. El usuario accede a la página de abstención de movimientos.
2. El sistema carga los datos del predio, propietario y ubicación.
3. El usuario puede:
   - Registrar una abstención (si no existe una activa).
   - Eliminar la abstención (si existe una activa).
4. Todas las operaciones se realizan vía `/api/execute` con acciones:
   - `get_predio_data`
   - `registrar_abstencion`
   - `eliminar_abstencion`

## API
### Endpoint
`POST /api/execute`

#### Request
```json
{
  "action": "nombre_accion",
  "payload": { ... }
}
```

#### Acciones Soportadas
- `get_predio_data`: { cvecuenta }
- `registrar_abstencion`: { cvecuenta, axoefec, bimefec, observacion, usuario }
- `eliminar_abstencion`: { cvecuenta, axoefec, bimefec, observacion, usuario }

#### Response
```json
{
  "success": true|false,
  "message": "Mensaje de resultado",
  "data": { ... }
}
```

## Validaciones
- El año (`axoefec`) debe ser >= 1900 y <= 2100.
- El bimestre (`bimefec`) debe ser entre 1 y 6.
- No se puede registrar abstención si ya existe una activa (cvemov=12).
- No se puede eliminar abstención si no existe una activa.
- No se puede operar sobre cuentas canceladas.

## Seguridad
- El usuario debe estar autenticado y su nombre se envía en el campo `usuario`.
- Todas las operaciones quedan registradas con usuario y fecha.

## Integración
- El frontend Vue.js consume el endpoint `/api/execute` usando Axios.
- El backend Laravel ejecuta los stored procedures de PostgreSQL según la acción.

## Estructura de la Base de Datos
- **catastro**: Información principal del predio.
- **convcta**: Información de la cuenta catastral.
- **regprop**: Relación de propietarios.
- **contrib**: Datos del propietario.
- **ubicacion**: Domicilio del predio.

## Stored Procedures
- `sp_get_predio_data`: Devuelve los datos necesarios para la pantalla.
- `sp_registrar_abstencion`: Realiza el registro de la abstención.
- `sp_eliminar_abstencion`: Elimina la abstención.

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` del response.
- El frontend muestra los mensajes al usuario.

## Consideraciones
- El formulario es una página independiente, no usa tabs.
- El usuario debe confirmar la eliminación de la abstención.
- El campo de observaciones se limpia al enfocar.

# Ejemplo de eRequest/eResponse
```json
{
  "action": "registrar_abstencion",
  "payload": {
    "cvecuenta": 12345,
    "axoefec": 2024,
    "bimefec": 2,
    "observacion": "Por solicitud del propietario",
    "usuario": "admin"
  }
}
```

# Ejemplo de respuesta
```json
{
  "success": true,
  "message": "Abstención registrada correctamente.",
  "data": true
}
```
