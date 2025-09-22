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
