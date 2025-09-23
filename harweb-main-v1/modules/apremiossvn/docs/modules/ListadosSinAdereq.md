# ListadosSinAdereq - Documentación Técnica

## Descripción General
Este módulo permite consultar y listar los locales de mercados (y otros módulos) que no tienen adeudos vigentes, para la emisión de requerimientos sin adeudo. Incluye filtros por recaudadora, mercado, sección y rango de locales. Permite consultar bloqueos y el último movimiento de cada local.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA (Single Page Application), cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `getRecaudadoras`
  - `getMercados`
  - `getSecciones`
  - `getListadosSinAdereq`
  - `getBloqueos`
  - `getUltimoMovimiento`

## Stored Procedures
- Toda la lógica de consulta y cálculo reside en SPs de PostgreSQL.
- Los SPs devuelven tablas completas para ser consumidas por el frontend.

## Vue.js
- El componente es una página completa, sin tabs.
- Permite seleccionar filtros y muestra resultados en tabla.
- Permite ver detalles de bloqueos y último movimiento por local.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, si aplica).
- Los parámetros son validados en backend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden ser extendidos para nuevos filtros o módulos.

## Ejemplo de Request
```json
{
  "action": "getListadosSinAdereq",
  "params": {
    "tipo": "mercado",
    "id_rec": 1,
    "num_mercado": 2,
    "seccion": "A",
    "local1": 1,
    "local2": 99
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ]
}
```

## Manejo de Errores
- Respuesta HTTP 400 para acciones no soportadas
- Respuesta HTTP 500 para errores internos
- Mensaje de error en campo `error` del JSON

## Integración
- El frontend Vue.js consume el endpoint vía Axios
- El backend ejecuta el SP correspondiente y retorna los datos

## Pruebas
- Se recomienda usar Postman para pruebas de API
- El frontend puede ser probado con Jest o Cypress
