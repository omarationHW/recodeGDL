# ConsultaGeneral

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - ConsultaGeneral

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Local Existente

**Descripción:** El usuario busca un local existente ingresando todos los parámetros requeridos.

**Precondiciones:**
El local existe en la base de datos con los parámetros proporcionados.

**Pasos a seguir:**
1. El usuario ingresa los datos de recaudadora, mercado, categoría, sección, local, letra y bloque.
2. Presiona el botón 'Buscar'.
3. El sistema envía la petición a /api/execute con eRequest 'buscar_local'.
4. El backend retorna el local encontrado.

**Resultado esperado:**
El local aparece en la tabla de resultados y puede consultarse su detalle.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "SS", "local": 5, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de Detalle de Local

**Descripción:** El usuario selecciona un local de la lista y consulta su detalle.

**Precondiciones:**
El local fue previamente encontrado en la búsqueda.

**Pasos a seguir:**
1. El usuario hace clic en 'Detalle' de un local.
2. El sistema envía la petición a /api/execute con eRequest 'detalle_local' y el id_local.
3. El backend retorna los datos completos del local.

**Resultado esperado:**
Se muestra la información completa del local, incluyendo mercado, nombre, arrendatario, domicilio, sector, zona, descripción, superficie, giro, fechas, vigencia, usuario y renta.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 3: Visualización de Adeudos, Pagos y Requerimientos

**Descripción:** El usuario navega entre las pestañas de Adeudos, Pagos y Requerimientos para un local.

**Precondiciones:**
El usuario está visualizando el detalle de un local.

**Pasos a seguir:**
1. El usuario selecciona la pestaña 'Adeudos'.
2. El sistema solicita los adeudos vía /api/execute eRequest 'adeudos_local'.
3. El usuario selecciona la pestaña 'Pagos'.
4. El sistema solicita los pagos vía /api/execute eRequest 'pagos_local'.
5. El usuario selecciona la pestaña 'Requerimientos'.
6. El sistema solicita los requerimientos vía /api/execute eRequest 'requerimientos_local'.

**Resultado esperado:**
Se muestran correctamente los datos de cada sección.

**Datos de prueba:**
{ "id_local": 123 }

---



## Casos de Prueba

# Casos de Prueba: Consulta General de Locales

## Caso 1: Búsqueda de Local Existente
- **Entrada:**
  - oficina: 1
  - num_mercado: 10
  - categoria: 2
  - seccion: 'SS'
  - local: 5
  - letra_local: null
  - bloque: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: {...} }
- **Esperado:**
  - success: true
  - data: lista con al menos un local
  - message: 'Local encontrado'

## Caso 2: Búsqueda de Local Inexistente
- **Entrada:**
  - oficina: 1
  - num_mercado: 99
  - categoria: 9
  - seccion: 'ZZ'
  - local: 999
  - letra_local: null
  - bloque: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: {...} }
- **Esperado:**
  - success: true
  - data: []
  - message: 'No existe el local digitado'

## Caso 3: Consulta de Detalle de Local
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'detalle_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: objeto con detalle del local
  - message: 'Detalle encontrado'

## Caso 4: Consulta de Adeudos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'adeudos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de adeudos
  - message: 'Adeudos obtenidos'

## Caso 5: Consulta de Pagos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'pagos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de pagos
  - message: 'Pagos obtenidos'

## Caso 6: Consulta de Requerimientos
- **Entrada:**
  - id_local: 123
- **Acción:** POST /api/execute { eRequest: 'requerimientos_local', params: { id_local: 123 } }
- **Esperado:**
  - success: true
  - data: lista de requerimientos
  - message: 'Requerimientos obtenidos'

## Caso 7: Validación de Parámetros Faltantes
- **Entrada:**
  - oficina: null
- **Acción:** POST /api/execute { eRequest: 'buscar_local', params: { oficina: null } }
- **Esperado:**
  - success: false
  - message: 'The oficina field is required.'



