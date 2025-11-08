# Documentación Técnica: Migración de Formulario cargadatosfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend:** Vue.js 3 (Composition API), Axios para llamadas API
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## Flujo de Datos
1. **Frontend** solicita datos (por ejemplo, consulta de clave catastral) vía POST `/api/execute` con `{ action: 'getCargadatos', params: { cvecatnva: '...' } }`.
2. **Laravel Controller** recibe la petición, despacha según `action` y llama el stored procedure correspondiente vía DB::select.
3. **Stored Procedure** ejecuta la lógica y retorna los datos en formato JSON o tabla.
4. **Frontend** muestra los datos en la página, permitiendo navegación entre secciones (ubicación, avalúos, construcciones, etc).

## API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getCargadatos",
    "params": { "cvecatnva": "D65J1345001" }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "",
    "data": { ... }
  }
  ```

## Stored Procedures
- Toda la lógica de consulta y actualización se realiza en funciones/stored procedures de PostgreSQL.
- Los procedimientos devuelven datos en formato tabla o JSON.
- Ejemplo: `get_cargadatos`, `get_avaluos`, `get_construcciones`, `get_area_carto`, `save_cargadatos`.

## Frontend (Vue.js)
- Cada formulario es una página independiente (no tabs).
- El usuario ingresa la clave catastral y consulta los datos.
- Se muestran las secciones: Ubicación, Avalúos, Construcciones, Área Cartográfica, Observaciones, Usos de Suelo.
- Navegación entre páginas mediante rutas (ejemplo: `/cargadatos`).
- Manejo de errores y loading.

## Backend (Laravel)
- Controlador único (`CargaDatosController`) con método `execute`.
- Despacha la acción recibida y llama el stored procedure adecuado.
- Validación de parámetros y manejo de errores.
- Retorno de respuesta estándar eResponse.

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend.
- Sanitización de entradas.

## Extensibilidad
- Para agregar nuevas acciones, basta con añadir el case en el controlador y el stored procedure correspondiente.
- El frontend puede consumir cualquier acción nueva sin cambios estructurales.

## Consideraciones de Migración
- Los tabs de Delphi se convierten en páginas independientes.
- Los DataSource y Query de Delphi se reemplazan por llamadas a stored procedures.
- Los eventos de cierre/apertura de queries se simulan en backend (no necesarios en Laravel).
- Los campos y lógica de negocio se mantienen equivalentes.

## Ejemplo de Navegación
- `/cargadatos` → Página de consulta de datos catastrales
- `/avaluos/:cvecatnva` → Página de avalúos de una cuenta
- `/construcciones/:cveavaluo` → Página de construcciones de un avalúo

## Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint `/api/execute`.
- El frontend debe manejar todos los estados (loading, error, success).

