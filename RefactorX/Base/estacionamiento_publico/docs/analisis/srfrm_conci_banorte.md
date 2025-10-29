# Documentación Técnica: Migración de Formulario srfrm_conci_banorte a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 2/3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón API:** eRequest/eResponse (peticiones y respuestas estructuradas)

## Endpoints
### /api/execute (POST)
- **Entrada:**
  - `eRequest`: string (nombre de la operación)
  - `params`: objeto (parámetros de la operación)
- **Salida:**
  - `eResponse`: objeto `{ success, data, message, errors }`

### eRequest soportados
- `getMaxAxo`: Obtiene el año máximo de captura
- `searchConciliadosByFolio`: Busca conciliados por año y folio
- `searchConciliadosByFecha`: Busca conciliados por fecha de afectación
- `getHistoByAxoFolio`: Obtiene historial por año y folio
- `cambiarPlaca`: Cambia la placa capturada por banco
- `cambiarFolio`: Cambia el folio (opción 2: existe, opción 3: no existe)

## Stored Procedures
- **sp_conciliados_by_folio(axo, folio):** Devuelve registros de conciliación por año y folio
- **sp_conciliados_by_fecha(fecha):** Devuelve registros de conciliación por fecha
- **sp_histo_by_axo_folio(axo, folio):** Devuelve historial de folios
- **spd_chg_conci(control, idbanco, axo, folio, placa, id_usuario, opcion):** Realiza cambios de placa o folio

## Frontend (Vue.js)
- Cada formulario es una página independiente:
  - Consulta por Folio
  - Consulta por Fecha
  - Cambio de Placa
  - Cambio de Folio
- Navegación mediante rutas y breadcrumbs
- Llamadas a la API usando Axios
- Manejo de errores y mensajes de éxito

## Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado)
- El id_usuario se toma del usuario autenticado o de los parámetros

## Validaciones
- Todos los parámetros requeridos son validados en el backend
- El frontend valida campos obligatorios antes de enviar

## Consideraciones
- Los stored procedures devuelven siempre un registro (clave=0 éxito, clave!=0 error)
- El frontend muestra mensajes según el resultado de la operación

## Migración de lógica Delphi
- Todas las consultas y operaciones del formulario original están cubiertas por los stored procedures y métodos del controlador
- El flujo de la UI se mantiene, pero cada formulario es una página separada
