# Documentación Técnica: Migración Formulario Consulta Predial (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs), navegación por rutas.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures (SPs) en el esquema `basephp`.

## Flujo de Datos
1. **El usuario accede a la página de Consulta Predial.**
2. **Ingresa los datos de cuenta:** recaudadora, tipo (U/R), número de cuenta.
3. **Vue.js envía una petición POST a `/api/execute`** con `{ action: 'getCuenta', params: { ... } }`.
4. **Laravel Controller** recibe la petición, ejecuta el SP correspondiente y retorna los datos.
5. **Vue.js** muestra los datos y permite navegar a otras vistas (saldos, recibos, requerimientos, etc.), cada una usando su propio action.
6. **Para el visor cartográfico**, Vue.js solicita la URL mediante `getGraficoUrl` y la muestra en un iframe.

## API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:** `{ action: 'nombreAccion', params: { ... } }`
- **Respuesta:** `{ success: true|false, data: [...], message: '' }`

### Ejemplo de llamada
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ action: 'getCuenta', params: { recaud: '1', urbrus: 'U', cuenta: '123456' } })
})
```

## Stored Procedures
- Todos los SPs están en el esquema `basephp`.
- Cada SP encapsula una consulta o proceso de negocio.
- Los SPs devuelven tablas (RETURNS TABLE) para facilitar el consumo desde Laravel.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o sesión Laravel.
- Validar y sanitizar todos los parámetros recibidos.

## Frontend (Vue.js)
- Cada formulario es una página independiente (NO tabs).
- Navegación por rutas (`/consulta-predial`, `/consulta-predial/saldos`, etc. si se desea separar).
- Uso de componentes reutilizables para tablas y formularios.
- Breadcrumb para navegación contextual.
- Uso de fetch API para comunicación con backend.

## Consideraciones de Migración
- Todos los queries Delphi se migran a SPs PostgreSQL.
- La lógica de filtrado, paginación y ordenamiento se realiza en los SPs.
- El frontend no debe contener lógica de negocio, sólo presentación y llamadas API.
- El visor cartográfico se integra como iframe con la URL generada por backend.

## Extensibilidad
- Para agregar nuevos formularios, crear nuevos SPs y métodos en el controlador.
- El frontend puede agregar nuevas rutas y componentes independientes.

## Ejemplo de flujo para Consulta Predial
1. Usuario ingresa datos de cuenta y busca.
2. Se muestran datos generales de la cuenta.
3. El usuario puede ver saldos, recibos, requerimientos, régimen de propiedad, valores, ubicación, y el visor cartográfico.
4. Cada sección es una tabla o panel independiente.

## Manejo de Errores
- Todos los errores de SPs o de la API se devuelven en el campo `message` del response.
- El frontend muestra alertas o mensajes de error amigables.

## Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend debe manejar correctamente estados de carga, error y datos vacíos.
