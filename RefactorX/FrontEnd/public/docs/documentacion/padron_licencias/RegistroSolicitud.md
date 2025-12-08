# Documentación Técnica: RegistroSolicitud

## Análisis Técnico

# Documentación Técnica: Migración de RegistroSolicitudForm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (no tabs)
- **Base de Datos:** PostgreSQL, lógica de negocio crítica en stored procedures
- **Autenticación:** JWT o session Laravel (no incluido aquí, pero recomendado)

## Flujo de Solicitud
1. **Carga de Formulario:**
   - El frontend solicita `/api/execute` con `action: getFormData` para obtener catálogos (giros, calles, colonias, fabricantes).
2. **Registro de Solicitud:**
   - El usuario llena el formulario y envía `/api/execute` con `action: submitSolicitud` y los datos del formulario.
   - El backend valida y llama al SP `sp_registro_solicitud`.
   - El SP inserta el trámite, genera folio y devuelve el ID y mensaje.
3. **Inspecciones y Documentos:**
   - El usuario puede agregar inspecciones (`addInspeccion`) y documentos (`addDocumento`), ambos llaman SPs.
4. **Consulta de Solicitud:**
   - Se puede consultar el trámite y sus documentos/inspecciones con `getSolicitud`.

## API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## Seguridad
- Todas las operaciones requieren autenticación.
- El usuario se obtiene de la sesión o JWT y se pasa a los SPs para auditoría.

## Validaciones
- Validaciones de frontend (campos requeridos, email, etc.)
- Validaciones de backend (Laravel Validator y dentro de los SPs)

## Manejo de Errores
- Los errores de validación y de SP se devuelven en el campo `message` de la respuesta JSON.

## Navegación
- Cada formulario es una página Vue.js independiente (no tabs, no componentes tabulares).
- Breadcrumbs opcionales para navegación.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y nuevos SPs sin romper el contrato API.

## Ejemplo de llamada desde frontend
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ action: 'submitSolicitud', params: { ... } })
})
.then(res => res.json())
.then(data => { /* ... */ })
```

# Estructura de la Base de Datos
- **tramites**: almacena los trámites/solicitudes
- **revisiones**: inspecciones asociadas
- **tramitedocs**: documentos asociados
- **c_giros, c_calles, cp_correos, c_fabricantes**: catálogos

# Notas de Migración
- Todas las reglas de negocio críticas (validaciones, generación de folio, etc.) están en los SPs.
- El frontend Vue.js es desacoplado y sólo consume el API.
- El endpoint es único y flexible.

# Pruebas y Auditoría
- Todas las acciones relevantes registran usuario y fecha/hora.
- Los SPs pueden ser auditados y versionados.

