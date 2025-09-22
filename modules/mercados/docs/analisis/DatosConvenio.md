# Documentación Técnica: Módulo DatosConvenio

## Descripción General
El módulo **DatosConvenio** permite consultar y visualizar la información detallada de un convenio de local conveniado, incluyendo sus datos generales, periodos, parcialidades y estado. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa bajo un patrón API unificada (eRequest/eResponse) y stored procedures para lógica de negocio.

## Arquitectura
- **Backend**: Laravel Controller (DatosConvenioController) expone un endpoint único `/api/execute` que recibe acciones y parámetros.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y tabla de parcialidades.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.
- **API**: Comunicación por JSON, patrón eRequest/eResponse.

## Flujo de Datos
1. El frontend solicita `/api/execute` con acción `getConvenioById` y el id del convenio.
2. El backend ejecuta el stored procedure `sp_get_datos_convenio` y retorna los datos generales.
3. El frontend solicita `/api/execute` con acción `getConvenioParciales` para obtener la tabla de parcialidades.
4. El backend ejecuta el stored procedure `sp_get_convenio_parciales` y retorna la lista.

## Endpoints
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "getConvenioById", // o getConvenioParciales, getConvenioResumen
      "params": { "id_conv": 123 }
    }
    ```
  - **Response:**
    ```json
    {
      "success": true,
      "data": { ... },
      "message": ""
    }
    ```

## Stored Procedures
- **sp_get_datos_convenio**: Devuelve todos los campos del convenio, más campos calculados (estado, tipodesc, periodos, peradeudos, convenio).
- **sp_get_convenio_parciales**: Devuelve la lista de pagos parciales con descripción, importe, periodos y datos de pago.
- **sp_get_convenio_resumen**: Devuelve resumen de estado, tipo, periodos, etc.

## Seguridad
- El endpoint requiere autenticación JWT (recomendado, no incluido en este ejemplo).
- Validación de parámetros en el controlador.

## Consideraciones de Migración
- Todos los cálculos de campos (estado, tipodesc, periodos, etc.) se trasladan a los stored procedures.
- El frontend es reactivo y desacoplado, cada página es independiente.
- No se usan tabs ni componentes tabulares.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y nuevos stored procedures para otras vistas o reportes.

## Dependencias
- Laravel 9+
- Vue.js 2/3 + Element UI (o similar)
- PostgreSQL 12+

## Ejemplo de Uso
1. El usuario navega a `/convenios/123`.
2. El componente Vue carga los datos generales y las parcialidades del convenio 123.
3. El usuario puede ver todos los detalles y parcialidades en una sola página.

