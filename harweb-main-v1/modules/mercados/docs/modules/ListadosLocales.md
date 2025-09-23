# Documentación Técnica - ListadosLocales (Migración Delphi a Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures
- **Comunicación**: El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibe `{ ...data }`

## Flujo de Trabajo
1. El usuario accede a la página de ListadosLocales.
2. Selecciona el tipo de listado (Padrón, Movimientos, Ingreso por Zonas).
3. El frontend solicita los catálogos (recaudadoras, mercados) usando `/api/execute`.
4. Al buscar, el frontend envía la acción y parámetros al backend.
5. El backend ejecuta el stored procedure correspondiente y retorna los datos.
6. El usuario puede exportar a Excel (implementación pendiente).

## Seguridad
- El endpoint `/api/execute` requiere autenticación (token JWT o sesión Laravel).
- Cada acción valida los parámetros y el usuario.
- Los stored procedures sólo exponen la información necesaria.

## Estructura de Carpetas
- `app/Http/Controllers/ListadosLocalesController.php` (controlador principal)
- `resources/js/pages/ListadosLocalesPage.vue` (componente Vue)
- `database/migrations/` y `database/procedures/` (stored procedures)

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ action: string, params: object }`
- **Response**: `{ ...data }` según la acción

## Acciones soportadas
- `getRecaudadoras`: Catálogo de recaudadoras
- `getMercadosByRecaudadora`: Catálogo de mercados por recaudadora
- `getPadronLocales`: Listado de locales para padrón
- `getMovimientosLocales`: Listado de movimientos
- `getPagosLocales`: Listado de pagos
- `getIngresoZonificado`: Ingreso por zonas
- `exportPadronExcel`: Exportación a Excel (pendiente)

## Stored Procedures
- Todos los reportes y listados usan stored procedures PostgreSQL.
- Los SPs devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Validaciones
- El backend valida que los parámetros requeridos estén presentes.
- El frontend valida que los filtros estén completos antes de enviar la petición.

## Exportación a Excel
- La exportación se puede implementar usando Laravel Excel o similar.
- El endpoint `exportPadronExcel` es un placeholder.

## Consideraciones
- No se usan tabs ni componentes tabulares en el frontend.
- Cada formulario es una página independiente y funcional.
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.

# Casos de Uso
