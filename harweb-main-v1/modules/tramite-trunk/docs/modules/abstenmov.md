# Documentación Técnica: Abstención de Movimientos

## Descripción General
Este módulo permite registrar y eliminar abstenciones de movimientos sobre cuentas catastrales. La abstención impide realizar movimientos sobre la cuenta hasta que sea eliminada. El proceso está compuesto por:

- Un endpoint API unificado `/api/execute` que recibe eRequest/eResponse.
- Un controlador Laravel que orquesta la lógica y llama a stored procedures en PostgreSQL.
- Un componente Vue.js que representa la página de abstención.
- Stored procedures en PostgreSQL para la lógica de negocio y validación.

## Arquitectura
- **Backend:** Laravel (PHP), PostgreSQL
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Unificada, patrón eRequest/eResponse

## Flujo de Datos
1. El usuario accede a la página de abstención de movimientos para una cuenta específica.
2. El frontend solicita los datos del predio y propietario vía `/api/execute` con `action: get_predio_data`.
3. El usuario puede registrar una abstención (si no existe) o eliminarla (si existe).
4. El frontend envía la acción correspondiente (`registrar_abstencion` o `eliminar_abstencion`) al endpoint.
5. El backend valida y ejecuta la lógica mediante stored procedures.
6. El resultado se retorna en formato eResponse.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## Acciones soportadas
- `get_predio_data`: Obtiene datos del predio, ubicación y propietario.
- `registrar_abstencion`: Registra la abstención de movimientos.
- `eliminar_abstencion`: Elimina la abstención de movimientos.

## Validaciones
- El año debe ser >= 1900 y <= 2100.
- El bimestre debe ser entre 1 y 6.
- No se puede registrar abstención si ya existe una activa.
- No se puede eliminar abstención si no existe una activa.
- No se puede operar si la cuenta está cancelada.

## Seguridad
- El usuario autenticado debe ser enviado en el payload (`usuario`).
- El backend valida los permisos y la integridad de los datos.

## Integración Vue.js
- El componente es una página independiente, sin tabs.
- Navegación por rutas (ejemplo: `/abstenmov/:cvecuenta`).
- El estado de la abstención se refleja dinámicamente.

## Integración con PostgreSQL
- Toda la lógica de negocio y validación crítica se realiza en stored procedures.
- El controlador Laravel sólo orquesta y maneja errores.

## Ejemplo de llamada API
```json
{
  "action": "registrar_abstencion",
  "payload": {
    "cvecuenta": 12345,
    "axoefec": 2024,
    "bimefec": 2,
    "observacion": "Por solicitud del propietario.",
    "usuario": "admin"
  }
}
```

## Manejo de errores
- Los errores de validación y de negocio se retornan en el campo `message` y `success: false`.

## Consideraciones
- El frontend debe deshabilitar los campos y botones según el estado de la abstención.
- El backend es responsable de la integridad transaccional.

