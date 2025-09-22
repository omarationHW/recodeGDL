# Documentación Técnica: PadronLocales (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica SQL migrada a stored procedures
- **Comunicación:** JSON, todos los errores y respuestas siguen el patrón `{ success, data, message }`

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "getPadronLocales", // o 'exportPadronLocales', 'getRecaudadoras', etc
    "params": { ... } // parámetros específicos
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## Controlador Laravel
- Un solo controlador (`PadronLocalesController`) maneja todas las acciones relacionadas con el padrón de locales.
- Métodos principales:
  - `getPadronLocales`: Llama al SP y retorna el padrón filtrado por recaudadora.
  - `exportPadronLocales`: Llama al SP y prepara datos para exportar (Excel/TXT).
  - `getRecaudadoras`: Devuelve lista de recaudadoras para el filtro.
- Todas las acciones se enrutan por el campo `action` del request.

## Componente Vue.js
- Página independiente `/padron-locales`.
- Permite seleccionar recaudadora y mostrar el padrón en tabla.
- Botones para exportar a Excel/TXT (simulado, requiere implementación backend real para descarga).
- Manejo de errores y loading.
- Filtros y navegación breadcrumb.

## Stored Procedure PostgreSQL
- `sp_get_padron_locales(p_recaudadora INTEGER)`
  - Devuelve todos los locales activos de la recaudadora, con cálculo de renta según reglas de negocio.
  - Utiliza JOINs para obtener nombre de mercado y cuota vigente.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros.
- (Opcional) Autenticación JWT o session para producción.

## Extensibilidad
- El endpoint `/api/execute` puede crecer para soportar más acciones (CRUD, reportes, procesos).
- Los stored procedures pueden ser versionados y ampliados.

## Notas de Migración
- El cálculo de renta se realiza en el SP, siguiendo la lógica Delphi.
- La exportación a Excel/TXT debe implementarse en backend para descarga real.
- El frontend NO usa tabs ni componentes tabulares: cada formulario es una página.

## Estructura de Carpetas
- `app/Http/Controllers/PadronLocalesController.php`
- `resources/js/pages/PadronLocalesPage.vue`
- `database/migrations/` y `database/functions/sp_get_padron_locales.sql`

## Ejemplo de llamada API
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'getPadronLocales',
    params: { recaudadora: 1 }
  })
})
```

## Requerimientos de Infraestructura
- PHP 8+, Laravel 10+, PostgreSQL 13+, Node.js 16+ para frontend.
- Configuración de CORS si frontend y backend están en dominios distintos.

