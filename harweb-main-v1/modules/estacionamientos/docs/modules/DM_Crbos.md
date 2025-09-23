# Documentación Técnica: Migración Formulario DM_Crbos a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (todas las operaciones de negocio en stored procedures)
- **Patrón API:** eRequest/eResponse (el frontend envía un objeto `eRequest` y parámetros, el backend responde con `eResponse`)

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: 'nombre_operacion', params: { ... } }`
  - Salida: `{ eResponse: { success, data, message } }`

## Controlador Laravel
- Un único controlador (`ExecuteController`) maneja todas las operaciones.
- Cada operación se identifica por el valor de `eRequest`.
- El controlador ejecuta los stored procedures o queries según corresponda.
- Maneja errores y devuelve siempre el objeto `eResponse`.

## Componente Vue.js
- Página completa para gestión de contrarecibos.
- Permite buscar por fecha, ver listado y detalle.
- Usa fetch API para comunicarse con `/api/execute`.
- Calcula el estado del contrarecibo en frontend (lógica migrada de Delphi).
- Incluye breadcrumbs y mensajes de error.

## Stored Procedures
- Toda la lógica de inserción, actualización y borrado se realiza en SPs.
- Los reportes y consultas también se implementan como funciones SQL.
- Los SPs devuelven siempre un resultado estructurado (tabla o valor).

## Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o similar.
- Validar y sanear todos los parámetros recibidos.

## Convenciones
- Todos los nombres de SPs y funciones siguen el prefijo del sistema original (`spd_` para procedimientos, `get_`/`sum_` para reportes).
- Los parámetros de los SPs reflejan los campos de las tablas originales.

## Migración de Lógica Delphi
- Las funciones de cálculo de estado y totales se migran a lógica JS o SQL según corresponda.
- Las validaciones de entrada se implementan en frontend y backend.

## Ejemplo de Llamada API
```js
// Obtener contrarecibos de una fecha
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ eRequest: 'getContrarecibosByDate', params: { fecha: '2024-06-01' } })
})
.then(res => res.json())
.then(data => console.log(data.eResponse));
```

## Flujo de Datos
1. Usuario selecciona fecha y consulta.
2. Vue envía eRequest a Laravel.
3. Laravel ejecuta el SP o query y responde.
4. Vue muestra resultados y permite ver detalle.

## Extensibilidad
- Para agregar nuevas operaciones, solo agregar un nuevo case en el controlador y el SP correspondiente.
- Cada formulario puede tener su propia página Vue y lógica asociada.
