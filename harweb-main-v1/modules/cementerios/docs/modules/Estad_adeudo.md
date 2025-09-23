# Documentación Técnica: Estadísticos y Listados de Adeudos

## Descripción General
Este módulo permite consultar y exportar estadísticas y listados de adeudos de cementerios, mostrando tanto un resumen por cementerio y año como un listado detallado de registros con adeudos mayores a un número de años especificado.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API
### Endpoint Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "eRequest": {
      "action": "getResumen|getListado",
      "params": { ... }
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

### Acciones soportadas
- `getResumen`: Devuelve el resumen de adeudos por cementerio y año.
- `getListado`: Devuelve el listado de registros con adeudos mayores o iguales al parámetro `axop` (años de adeudo).

## Stored Procedures
- `sp_estad_adeudo_resumen()`: Devuelve resumen de adeudos.
- `sp_estad_adeudo_listado(axop INTEGER)`: Devuelve listado filtrado por años de adeudo.

## Frontend
- Página Vue.js independiente, sin tabs.
- Permite seleccionar tipo de reporte (resumen o listado) y, para listado, el filtro de años de adeudo.
- Muestra resultados en tablas responsivas.
- Botón de procesar y botón de salir.

## Seguridad
- Validación de parámetros en backend.
- El endpoint requiere autenticación (debe integrarse con middleware de autenticación de Laravel si es necesario).

## Consideraciones
- El frontend asume que el backend responde en el formato eRequest/eResponse.
- Para exportación PDF, se recomienda implementar endpoints adicionales o usar bibliotecas de generación de PDF en backend.

## Integración
- El controlador debe ser registrado en `routes/api.php`:
  ```php
  Route::post('/execute', [EstadAdeudoController::class, 'execute']);
  ```
- El componente Vue debe ser registrado en el router de la SPA con su propia ruta.

## Migración de Datos
- Se asume que las tablas `ta_13_datosrcm`, `tc_13_cementerios`, y `ta_12_passwords` existen y están migradas a PostgreSQL.

## Pruebas
- Ver sección de casos de uso y casos de prueba para ejemplos detallados.
