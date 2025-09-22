# Documentación Técnica: Estadísticas de Contratos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo implementa la funcionalidad de consulta y reporte de estadísticas de pagos de contratos de obra pública, migrando la lógica desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y stored procedures).

## Arquitectura
- **Backend:** Laravel 10+, controlador unificado (`EstadisticasContratosController`) con endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 3 SPA, componente de página independiente (`EstadisticasContratosPage.vue`), sin tabs ni pestañas.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedures (`spd_17_cta_publica`).
- **API Unificada:** Todas las operaciones se realizan vía POST `/api/execute` con un objeto `eRequest` que indica la operación y parámetros.

## Flujo de Datos
1. El usuario accede a la página de estadísticas.
2. Selecciona año de obra y fondo/programa.
3. El frontend envía un eRequest con operación `getEstadisticasContratos` y los parámetros seleccionados.
4. El backend ejecuta el stored procedure `spd_17_cta_publica` y retorna los datos en eResponse.
5. El frontend muestra la tabla de resultados y permite exportar los datos.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getEstadisticasContratos",
      "params": {
        "year": 2023,
        "fondo": 16
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## Stored Procedures
- **spd_17_cta_publica:** Devuelve el resumen de pagos, saldos y convenios por colonia, año y fondo.
- **get_fondos:** Devuelve el catálogo de fondos/programas.
- **get_anios_obra:** Devuelve los años de obra disponibles.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política de la aplicación.
- Validar que los parámetros recibidos sean válidos y sanitizados.

## Consideraciones de Migración
- Los cálculos de porcentajes y totales se realizan en el frontend para mayor flexibilidad visual.
- El reporte puede ser exportado a Excel/CSV desde el frontend, o el backend puede generar el archivo y devolver la URL.
- El frontend es una página independiente, sin tabs ni componentes compartidos.

## Extensibilidad
- Se pueden agregar nuevas operaciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser extendidos para incluir más métricas o filtros.

## Dependencias
- Laravel 10+
- Vue.js 3+
- PostgreSQL 13+
- Axios (frontend)

## Ejemplo de Uso
1. El usuario selecciona año 2023 y fondo "Ramo 33".
2. El frontend envía:
   ```json
   { "eRequest": { "operation": "getEstadisticasContratos", "params": { "year": 2023, "fondo": 16 } } }
   ```
3. El backend ejecuta:
   ```sql
   CALL spd_17_cta_publica(2023, 16);
   ```
4. El frontend muestra la tabla de resultados.

## Errores Comunes
- Si no hay datos para el año/fondo, el backend retorna un array vacío.
- Si ocurre un error de SQL, el mensaje se retorna en `eResponse.message`.

## Exportación
- El botón "Exportar" puede llamar a la operación `exportEstadisticasContratos` para obtener los datos en formato descargable.

