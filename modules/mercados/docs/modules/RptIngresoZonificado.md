# Documentación Técnica: Migración de RptIngresoZonificado (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de Ingreso Zonificado, que muestra el total de ingresos por zona en un periodo de fechas, sumando tanto ingresos normales como ajustes. El frontend es un componente Vue.js de página completa, el backend es un controlador Laravel que expone un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse, y la lógica de consulta reside en un stored procedure de PostgreSQL.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente, sin tabs. Permite seleccionar fechas y muestra tabla de resultados y total.
- **Backend**: Laravel Controller, endpoint único `/api/execute` que recibe `{action, params}` y responde `{success, data, message}`.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedure `sp_ingreso_zonificado`.

## 3. Flujo de Datos
1. El usuario ingresa fechas y presiona "Consultar".
2. Vue.js envía POST a `/api/execute` con `{ action: 'getIngresoZonificado', params: { fecdesde, fechasta } }`.
3. Laravel Controller ejecuta el stored procedure y retorna los datos.
4. Vue.js muestra la tabla y el total.
5. Para exportar PDF, Vue.js envía `{ action: 'exportIngresoZonificadoPDF', params: { ... } }` y recibe la URL del PDF generado.

## 4. API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "getIngresoZonificado",
    "params": {
      "fecdesde": "2024-01-01",
      "fechasta": "2024-01-31"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [
      { "id_zona": 1, "zona": "CENTRO", "pagado": 12345.67 }, ...
    ],
    "message": ""
  }
  ```

## 5. Stored Procedure (PostgreSQL)
- **Nombre**: `sp_ingreso_zonificado`
- **Parámetros**: `fecdesde DATE`, `fechasta DATE`
- **Retorna**: Tabla con columnas `id_zona`, `zona`, `pagado`
- **Lógica**: Suma ingresos y ajustes por zona en el rango de fechas.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que las fechas sean válidas y que el usuario tenga permisos.

## 7. Consideraciones de Migración
- El frontend NO usa tabs, cada formulario es una página independiente.
- El backend centraliza la lógica en el stored procedure para eficiencia y mantenibilidad.
- El endpoint es unificado para facilitar integración y pruebas automatizadas.

## 8. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón `action/params`.
- El stored procedure puede ser extendido para incluir más filtros si es necesario.

## 9. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+
- (Opcional) barryvdh/laravel-dompdf para exportar PDF

## 10. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.
