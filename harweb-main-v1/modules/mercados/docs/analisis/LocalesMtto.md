# Documentación Técnica: Migración Formulario LocalesMtto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 (Composition API), componente de página independiente, navegación por rutas
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores centralizado

## Flujo de Trabajo
1. **Carga de Catálogos:**
   - Al cargar la página, el frontend solicita `/api/execute` con `action: get_catalogs`.
   - El backend ejecuta los SPs de catálogo y retorna los datos para recaudadoras, secciones, zonas y cuotas.

2. **Búsqueda de Local:**
   - El usuario llena los campos clave y presiona "Buscar".
   - Se envía `action: buscar_local` con los parámetros.
   - El backend ejecuta el SP `buscar_local` y retorna si existe el local.

3. **Alta de Local:**
   - Si el local no existe, se habilita el formulario de alta.
   - Al enviar, se valida en frontend y backend.
   - Se ejecuta el SP `alta_local`, que:
     - Inserta en `ta_11_locales`.
     - Inserta en `ta_11_movimientos`.
     - Genera adeudos en `ta_11_adeudo_local` desde la fecha de alta hasta la fecha actual.

4. **Respuesta:**
   - El backend responde con éxito o error detallado.
   - El frontend muestra mensajes y limpia el formulario si corresponde.

## API: Endpoint Único
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## Validaciones
- Todos los campos requeridos se validan en frontend y backend.
- Fechas válidas, números positivos, campos obligatorios.
- No se permite alta si el local ya existe.
- No se permite alta con fecha anterior a 2003.

## Stored Procedures
- Toda la lógica de inserción, generación de adeudos y consultas está en SPs.
- Los SPs devuelven errores con `RAISE EXCEPTION` si ocurre algún problema.

## Seguridad
- El endpoint requiere autenticación (no implementado aquí, pero debe usarse JWT o sesión Laravel).
- El `id_usuario` debe provenir del usuario autenticado.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo, mensajes de error y éxito.
- Catálogos cargados al inicio.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser reutilizados por otros módulos.

# Notas de Migración
- Los nombres de tablas y campos se mantienen fieles al modelo original.
- Se asume que los triggers de auditoría y restricciones de integridad existen en la BD.
- El SP `alta_local` es atómico: si falla algo, hace rollback.

# Pruebas y Debug
- Todos los errores de SPs se devuelven como mensaje en el JSON.
- El frontend muestra los mensajes de error y éxito.
