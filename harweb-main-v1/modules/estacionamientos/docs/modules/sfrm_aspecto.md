# Documentación Técnica: Migración Formulario Aspecto (sfrm_aspecto) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite a los usuarios seleccionar y cambiar el aspecto visual (skin/theme) de la aplicación. La migración implementa:
- Un endpoint API unificado (`/api/execute`) bajo el patrón eRequest/eResponse.
- Un controlador Laravel que enruta operaciones a stored procedures PostgreSQL.
- Un componente Vue.js como página independiente para la selección de aspecto.
- Stored procedures en PostgreSQL para obtener y establecer el aspecto.

## 2. API Backend
- **Ruta:** `POST /api/execute`
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "operation": "getAspectos|setAspecto|getCurrentAspecto",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

### Operaciones soportadas
- `getAspectos`: Devuelve lista de aspectos disponibles.
- `setAspecto`: Cambia el aspecto actual. Requiere parámetro `aspecto`.
- `getCurrentAspecto`: Devuelve el aspecto actualmente seleccionado.

## 3. Stored Procedures PostgreSQL
- **get_aspectos()**: Devuelve lista de aspectos (simulado, puede leer de tabla o directorio real).
- **set_aspecto(p_nombre TEXT)**: Cambia el aspecto actual (simulado, debe persistir en tabla de configuración en producción).
- **get_current_aspecto()**: Devuelve el aspecto actual (simulado).

## 4. Frontend Vue.js
- Página independiente `/aspecto`.
- Carga lista de aspectos vía API.
- Permite seleccionar y cambiar el aspecto.
- Muestra el aspecto actual.
- Mensajes de éxito/error y estado de carga.

## 5. Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política de la aplicación.
- El cambio de aspecto puede ser global o por usuario según la lógica de negocio.

## 6. Extensibilidad
- Para soportar aspectos por usuario, crear tabla `configuracion_usuario (usuario_id, aspecto)` y modificar los SPs.
- Para cargar aspectos dinámicamente, leer de tabla o filesystem.

## 7. Integración
- El frontend debe usar Axios o fetch para consumir `/api/execute`.
- El backend enruta todas las operaciones relacionadas con aspecto a los SPs correspondientes.

## 8. Ejemplo de llamada API
```json
{
  "eRequest": {
    "operation": "setAspecto",
    "params": { "aspecto": "SkinDark" }
  }
}
```

## 9. Consideraciones
- El cambio de aspecto puede requerir recarga de la página o actualización dinámica del CSS/theme.
- El sistema puede ser extendido para soportar múltiples configuraciones visuales por usuario, rol, o sistema.
