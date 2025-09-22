# Documentación Técnica: Reporte de Pagos Locales (RptPagosLocales)

## Descripción General
Este módulo permite consultar y reportar los pagos realizados por locales en mercados municipales, filtrando por rango de fechas y recaudadora. Incluye la integración de backend (Laravel), frontend (Vue.js), lógica de negocio en stored procedures PostgreSQL y una API unificada bajo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Unificada, recibe `{ action, params }` y responde `{ success, data, message }`.

## Flujo de Datos
1. El usuario accede a la página de "Reporte de Pagos Locales".
2. Selecciona rango de fechas y recaudadora.
3. El frontend envía una petición POST a `/api/execute` con `action: 'getPagosLocalesReport'` y los parámetros.
4. El backend valida y llama al stored procedure `sp_rpt_pagos_locales`.
5. El resultado se devuelve al frontend y se muestra en una tabla.

## Endpoints
- **POST /api/execute**
  - **Body:** `{ action: string, params: object }`
  - **Acciones soportadas:**
    - `getPagosLocalesReport`: Obtiene el reporte de pagos locales.
    - `getRecaudadoras`: Devuelve lista de recaudadoras para combos.

## Stored Procedures
- `sp_rpt_pagos_locales(fecha_desde, fecha_hasta, oficina)`
- `sp_get_recaudadoras()`

## Validaciones
- Fechas requeridas y válidas.
- Oficina (recaudadora) requerida y válida.

## Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o session según la política de la aplicación.
- Validar que el usuario tenga permisos para consultar la recaudadora seleccionada.

## Manejo de Errores
- Los errores de validación y de ejecución se devuelven en el campo `message` de la respuesta JSON.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para soportar otras acciones relacionadas con pagos locales o reportes.

## Consideraciones de Rendimiento
- El stored procedure está optimizado para devolver solo los registros requeridos por los filtros.
- Se recomienda paginar los resultados si el volumen de datos es muy grande.

## Integración Frontend
- El componente Vue.js es autónomo y puede ser enlazado a una ruta como `/reportes/pagos-locales`.
- Utiliza Bootstrap para estilos, pero puede adaptarse a cualquier framework CSS.

## Ejemplo de Request
```json
{
  "action": "getPagosLocalesReport",
  "params": {
    "fecha_desde": "2024-06-01",
    "fecha_hasta": "2024-06-30",
    "oficina": 2
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    {
      "id_pago_local": 123,
      "datoslocal": "2 5 1 SS 101 A 1",
      "fecha_pago": "2024-06-15",
      ...
    }
  ],
  "message": ""
}
```
