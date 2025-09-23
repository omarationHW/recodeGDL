# Documentación Técnica: Migración Formulario busque (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (cada búsqueda es una página independiente, navegación por rutas)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón API:** eRequest/eResponse (entrada: `{action, params}`; salida: `{status, data, message}`)

## Endpoints
- **POST /api/execute**
  - Entrada: `{ action: string, params: object }`
  - Salida: `{ status: 'success'|'error', data: array|null, message: string }`

## Acciones soportadas
- `searchByName` — Búsqueda por nombre de propietario
- `searchByLocation` — Búsqueda por ubicación (calle y número exterior)
- `searchByClaveCatastral` — Búsqueda por clave catastral (zona, manzana, predio, subpredio)
- `searchByRFC` — Búsqueda por RFC del propietario
- `searchByCuenta` — Búsqueda por recaudadora, urbrus y cuenta

## Flujo de Datos
1. El usuario accede a la página de búsqueda y selecciona el tipo de búsqueda.
2. El formulario correspondiente se muestra como página independiente.
3. Al enviar el formulario, Vue.js realiza un POST a `/api/execute` con el action y los parámetros.
4. Laravel recibe la petición, valida los parámetros y ejecuta el stored procedure correspondiente.
5. El resultado se retorna en formato eResponse.
6. Vue.js muestra los resultados en una tabla.

## Validaciones
- Todas las entradas se validan tanto en frontend (Vue) como en backend (Laravel).
- El backend limita los resultados a 300 registros por búsqueda.
- Los stored procedures usan ILIKE para búsquedas flexibles (case-insensitive).

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política del sistema.
- Los parámetros se validan y sanitizan para evitar SQL Injection.

## Extensibilidad
- Para agregar nuevas búsquedas, basta con:
  1. Crear un nuevo stored procedure en PostgreSQL.
  2. Agregar el case correspondiente en el controlador Laravel.
  3. Crear la página Vue.js para el formulario.

## Estructura de Carpetas
- `app/Http/Controllers/BusqueController.php` — Controlador principal
- `resources/js/views/busque/` — Vistas Vue.js para cada búsqueda
- `database/migrations/` y `database/functions/` — Stored procedures y migraciones

## Ejemplo de eRequest/eResponse
### eRequest
```json
{
  "action": "searchByName",
  "params": { "nombre": "JUAN PEREZ" }
}
```
### eResponse
```json
{
  "status": "success",
  "data": [ { ... } ],
  "message": "Resultados por nombre obtenidos"
}
```

# Notas de Migración
- No se usan tabs ni componentes tabulares: cada búsqueda es una página Vue independiente.
- Los reportes de impresión deben implementarse en el backend como endpoints PDF o CSV si se requiere.
- El límite de 300 registros es configurable en los stored procedures.

# Pruebas y Casos de Uso
- Se recomienda usar Postman o Insomnia para pruebas de API.
- Los formularios Vue.js deben ser probados con datos reales y casos límite.
