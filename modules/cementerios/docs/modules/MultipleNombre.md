# Documentación Técnica: Consulta Múltiple por Nombre

## Descripción General
Este módulo permite consultar registros de fosas por nombre, con paginación y filtro por cementerio. Incluye:
- Endpoint API unificado `/api/execute` (eRequest/eResponse)
- Stored Procedures en PostgreSQL para búsqueda y catálogo
- Componente Vue.js como página independiente
- Controlador Laravel para orquestar la lógica

## Arquitectura
- **Frontend:** Vue.js (Single Page Component)
- **Backend:** Laravel Controller (API REST)
- **Base de Datos:** PostgreSQL (Stored Procedures)
- **API:** Patrón eRequest/eResponse, endpoint único `/api/execute`

## Flujo de Datos
1. El usuario ingresa un nombre y selecciona si busca en todos los cementerios o uno específico.
2. El frontend envía una petición POST a `/api/execute` con `eRequest.action` y parámetros.
3. El backend ejecuta el stored procedure correspondiente y retorna los resultados en `eResponse`.
4. El frontend muestra los resultados en tabla y permite continuar la búsqueda (paginación).

## Detalle de API
### Endpoint
`POST /api/execute`

#### Request
```json
{
  "eRequest": {
    "action": "searchByName", // o "cemeteriesList", "nextPageByName"
    "params": {
      "nombre": "%JUAN%",
      "cuenta": 0,
      "cem1": "A",
      "cem2": "Z",
      "limit": 100
    }
  }
}
```

#### Response
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
- `sp_multiple_nombre_search`: Busca registros por nombre, cementerio y control_rcm (paginado)
- `sp_cementerios_list`: Devuelve el catálogo de cementerios

## Seguridad
- Validación de parámetros en backend
- Escapado de parámetros en SQL (uso de funciones y variables)

## Consideraciones
- El frontend asume que la API responde en formato eRequest/eResponse
- El backend puede ser extendido para agregar más acciones en el futuro
- El stored procedure implementa paginación por control_rcm

## Extensibilidad
- Se pueden agregar más filtros (por ejemplo, por año, sección, etc.)
- El endpoint puede ser usado por otros formularios siguiendo el mismo patrón
