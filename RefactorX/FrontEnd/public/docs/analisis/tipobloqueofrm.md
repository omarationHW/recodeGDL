# Documentación Técnica: Migración de Formulario tipobloqueofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de bloqueo de licencias, permitiendo seleccionar un tipo de bloqueo y registrar el motivo. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, componente de página independiente para el formulario de bloqueo.
- **Backend:** Laravel API, controlador unificado para todas las operaciones vía `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

### Operaciones Soportadas
- `get_tipo_bloqueo_catalog`: Devuelve el catálogo de tipos de bloqueo activos.
- `bloquear_licencia`: Registra un bloqueo de licencia con tipo y motivo.

## 4. Stored Procedures
- **get_tipo_bloqueo_catalog:** Devuelve los tipos de bloqueo activos (`sel_cons = 'S'`).
- **bloquear_licencia:** Valida y registra el bloqueo en la tabla `bloqueos_licencia`.

## 5. Estructura de Tablas (Ejemplo)
- **c_tipobloqueo:** Catálogo de tipos de bloqueo (`id`, `descripcion`, `sel_cons`)
- **licencias:** Licencias a bloquear (`id`, ...)
- **bloqueos_licencia:** Historial de bloqueos (`id`, `licencia_id`, `tipo_bloqueo_id`, `motivo`, `usuario_id`, `fecha`)

## 6. Frontend (Vue.js)
- Página independiente con ruta propia.
- Formulario con select para tipo de bloqueo y campo de texto para motivo.
- Botones Aceptar/Cancelar.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 7. Seguridad
- Validación de parámetros en backend y frontend.
- El usuario debe estar autenticado (en ejemplo, `usuario_id` es simulado).
- Validación de existencia de licencia y tipo de bloqueo en el SP.

## 8. Extensibilidad
- Se pueden agregar más operaciones al endpoint `/api/execute` siguiendo el patrón `eRequest`.
- El frontend puede ser reutilizado para otros formularios similares.

## 9. Consideraciones
- El ID de licencia debe ser pasado como prop o parámetro de ruta al componente Vue.
- El usuario autenticado debe ser gestionado por el sistema de autenticación real.

## 10. Errores y Mensajes
- Todos los errores y mensajes se devuelven en el campo `message` de la respuesta.
