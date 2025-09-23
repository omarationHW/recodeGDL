# EstadxFolio - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
El formulario EstadxFolio permite consultar estadísticas agrupadas de folios por módulo, recaudadora y rango de folios, mostrando totales por vigencia y clave de practicado. La migración implementa:

- **Backend**: Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos**: Lógica SQL migrada a stored procedures en PostgreSQL.
- **API**: Todas las operaciones se realizan a través de un único endpoint, con acciones diferenciadas por el campo `eRequest.action`.

## Arquitectura
- **API Endpoint**: `/api/execute` (POST)
- **Acciones soportadas**:
    - `estadxfolio.getRecaudadoras`: Devuelve catálogo de recaudadoras.
    - `estadxfolio.getStats`: Devuelve estadísticas agrupadas por vigencia y clave_practicado.
    - `estadxfolio.exportExcel`: (Demo) Devuelve los mismos datos, en una implementación real generaría un archivo Excel.

## Flujo de Datos
1. El usuario accede a la página EstadxFolio.
2. El frontend solicita el catálogo de recaudadoras.
3. El usuario selecciona módulo, recaudadora y rango de folios.
4. Al enviar el formulario, el frontend llama a `/api/execute` con acción `estadxfolio.getStats` y los parámetros.
5. El backend ejecuta el stored procedure `estadxfolio_stats` y retorna los datos agrupados.
6. El usuario puede exportar los resultados a Excel (demo: alerta, real: descarga).

## Seguridad
- El endpoint requiere autenticación (middleware Laravel `auth:api` recomendado).
- Validación de parámetros en backend.
- El frontend valida que el folio final sea mayor o igual al inicial.

## Estructura de la Base de Datos
- **ta_15_apremios**: Tabla principal de folios.
- **ta_12_recaudadoras**: Catálogo de recaudadoras.

## Stored Procedures
- **estadxfolio_stats**: Devuelve los totales agrupados por vigencia y clave_practicado, con etiquetas legibles.
- **estadxfolio_recaudadoras**: Devuelve el catálogo de recaudadoras.

## Integración Vue.js
- El componente es una página completa, sin tabs.
- Usa Axios para consumir el endpoint `/api/execute`.
- Muestra errores y loading.
- Permite exportar a Excel (demo).

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para incluir más métricas.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

## Consideraciones
- El export a Excel debe implementarse en backend para producción.
- El endpoint puede ser protegido por roles/permisos si se requiere.
