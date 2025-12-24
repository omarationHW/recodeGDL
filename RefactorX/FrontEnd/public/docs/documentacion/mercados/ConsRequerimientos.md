# ConsRequerimientos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario ConsRequerimientos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint unificado `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibiendo `{ success, data, message }`.

## Flujo de la Página ConsRequerimientos
1. **Carga inicial**: El componente Vue solicita la lista de mercados (`getMercados`).
2. **Búsqueda de Local**: El usuario selecciona un mercado y llena los campos de sección, local, letra, bloque. Al enviar, se llama a `getLocalesByMercado`.
3. **Selección de Local**: Se muestran los locales encontrados. Al seleccionar uno, se llama a `getRequerimientosByLocal`.
4. **Visualización de Requerimientos**: Se listan los requerimientos del local. Al seleccionar uno, se llama a `getPeriodosByRequerimiento` para ver los periodos asociados.
5. **Claves y ejecutores**: Si se requiere mostrar información de claves o ejecutores, se usan los SPs correspondientes.

## API Backend
- **Endpoint**: `/api/execute` (POST)
- **Request**: `{ action: string, params: object }`
- **Response**: `{ success: bool, data: any, message: string }`
- **Acciones soportadas**:
  - `getMercados`
  - `getLocalesByMercado`
  - `getRequerimientosByLocal`
  - `getPeriodosByRequerimiento`
  - `getEjecutorById`
  - `getClaveByVigencia`
  - `getClaveByDiligencia`
  - `getClaveByPracticado`

## Stored Procedures
- Todos los SPs están en el esquema público y devuelven TABLE.
- Los SPs encapsulan la lógica de joins y filtros.
- Los nombres de los SPs siguen el patrón `sp_get_*`.

## Frontend Vue.js
- Página independiente, sin tabs.
- Navegación breadcrumb.
- Formularios reactivos y validación básica.
- Llamadas a la API usando Axios.
- Manejo de errores y mensajes de usuario.
- Visualización de tablas para locales, requerimientos y periodos.

## Seguridad
- Validación de parámetros en el backend (Laravel Validator).
- Sanitización de entradas.
- El endpoint puede protegerse con middleware de autenticación si es necesario.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden evolucionar sin cambiar la API.

# Estructura de la Base de Datos
- Tablas principales: `ta_11_mercados`, `ta_11_locales`, `ta_15_apremios`, `ta_15_periodos`, `ta_15_claves`, `ta_15_ejecutores`, `ta_12_passwords`.
- Todos los SPs usan estas tablas y devuelven los campos necesarios para la UI.

# Despliegue
- Los SPs deben crearse en la base de datos PostgreSQL.
- El controlador Laravel debe estar registrado en `routes/api.php`:
  ```php
  Route::post('/execute', [ConsRequerimientosController::class, 'execute']);
  ```
- El frontend debe tener configurado Axios para apuntar a `/api/execute`.

# Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint con diferentes acciones y parámetros.
- El frontend puede ser probado con datos reales y casos de error.

# Notas de Migración
- Los nombres de campos y lógica de joins se han adaptado a PostgreSQL y a la estructura relacional.
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página.
- El endpoint es unificado y extensible.


## Casos de Uso

# Casos de Uso - ConsRequerimientos

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos de un Local Existente

**Descripción:** El usuario desea consultar los requerimientos asociados a un local específico en un mercado.

**Precondiciones:**
El usuario tiene acceso al sistema y existen mercados y locales cargados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Selecciona un mercado de la lista desplegable.
3. Ingresa la sección, número de local, letra y bloque (si aplica).
4. Presiona 'Buscar'.
5. Selecciona el local de la lista de resultados.
6. Visualiza los requerimientos asociados al local.

**Resultado esperado:**
Se muestran los requerimientos del local seleccionado, incluyendo folio, fecha de emisión, vigencia, diligencia, importes y acciones.

**Datos de prueba:**
Mercado: 1-5-2-ABASTOS
Sección: SS
Local: 123
Letra: A
Bloque: 1

---

## Caso de Uso 2: Visualización de Periodos de un Requerimiento

**Descripción:** El usuario desea ver los periodos asociados a un requerimiento específico.

**Precondiciones:**
El usuario ya ha consultado los requerimientos de un local.

**Pasos a seguir:**
1. En la tabla de requerimientos, el usuario presiona 'Ver Periodos' en el requerimiento deseado.
2. El sistema muestra una tabla con los periodos, importes y recargos.

**Resultado esperado:**
Se listan los periodos asociados al requerimiento, con año, mes, importe y recargos.

**Datos de prueba:**
Requerimiento con folio: 456

---

## Caso de Uso 3: Error al Buscar Local Inexistente

**Descripción:** El usuario intenta buscar un local que no existe en el mercado seleccionado.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona un mercado válido.
2. Ingresa una sección y número de local inexistente.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no existe el local digitado.

**Datos de prueba:**
Mercado: 1-5-2-ABASTOS
Sección: XX
Local: 99999
Letra: Z
Bloque: 9

---



## Casos de Prueba

# Casos de Prueba para ConsRequerimientos

## Caso 1: Consulta exitosa de requerimientos
- **Precondición:** El local existe y tiene requerimientos.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1, "num_mercado": 5, "categoria": 2, "seccion": "SS", "local": 123, "letra_local": "A", "bloque": "1" } }
- **Esperado:** Respuesta success=true, data con al menos un local.

## Caso 2: Consulta de requerimientos por local
- **Precondición:** El local existe y tiene requerimientos.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getRequerimientosByLocal", "params": { "modulo": 11, "control_otr": 12345 } }
- **Esperado:** Respuesta success=true, data con lista de requerimientos.

## Caso 3: Consulta de periodos por requerimiento
- **Precondición:** El requerimiento existe.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getPeriodosByRequerimiento", "params": { "control_otr": 456 } }
- **Esperado:** Respuesta success=true, data con lista de periodos.

## Caso 4: Error por parámetros faltantes
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1 } }
- **Esperado:** success=false, message indicando parámetros faltantes.

## Caso 5: Error por local inexistente
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1, "num_mercado": 5, "categoria": 2, "seccion": "XX", "local": 99999, "letra_local": "Z", "bloque": "9" } }
- **Esperado:** success=true, data vacía.



