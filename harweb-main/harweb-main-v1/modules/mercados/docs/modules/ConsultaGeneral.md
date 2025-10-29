# Documentación Técnica: Consulta General de Locales

## Arquitectura General
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente (no tabs), navegación tipo breadcrumb.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante POST a `/api/execute` con un JSON que contiene `eRequest` y `params`.

## Flujo de la Aplicación
1. El usuario accede a la página de Consulta General.
2. Selecciona los parámetros de búsqueda (recaudadora, mercado, categoría, sección, local, letra, bloque).
3. Al buscar, se llama a `/api/execute` con `eRequest: 'buscar_local'` y los parámetros.
4. El backend ejecuta el stored procedure correspondiente y retorna los locales encontrados.
5. El usuario puede ver el detalle de un local, lo que dispara nuevas llamadas a `/api/execute` para obtener detalle, adeudos, pagos y requerimientos.
6. Toda la lógica de negocio y cálculos reside en los stored procedures.

## API: eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "buscar_local",
    "params": {
      "oficina": 1,
      "num_mercado": 10,
      "categoria": 2,
      "seccion": "SS",
      "local": 5,
      "letra_local": null,
      "bloque": null
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": "Local encontrado"
  }
  ```

## Stored Procedures
- Todos los procedimientos están en el esquema público y devuelven TABLE.
- Los cálculos de recargos, renta, etc., se realizan en SQL.
- Los procedimientos pueden ser llamados desde cualquier lenguaje compatible con PostgreSQL.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- No se exponen queries directos, todo pasa por SP.
- El endpoint puede ser protegido con middleware de autenticación si se requiere.

## Extensibilidad
- Para agregar nuevas operaciones, basta con agregar un nuevo case en el controlador y el SP correspondiente.
- El frontend puede consumir cualquier operación agregando el eRequest adecuado.

## Estructura de Carpetas
- `app/Http/Controllers/ConsultaGeneralController.php`
- `resources/js/pages/ConsultaGeneralPage.vue`
- `database/migrations/` y `database/functions/` para los SP.

# Notas de Migración
- Los tabs de Delphi se migran a páginas independientes en Vue.js (cada funcionalidad puede ser una ruta distinta si se desea).
- Los cálculos de recargos y renta se hacen en SQL, no en el frontend.
- El frontend es desacoplado y sólo consume la API.

# Ejemplo de Llamada desde Frontend
```js
fetch('/api/execute', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    eRequest: 'detalle_local',
    params: { id_local: 123 }
  })
})
.then(r => r.json())
.then(data => console.log(data));
```
