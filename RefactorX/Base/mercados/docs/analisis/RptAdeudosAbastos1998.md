# Documentación Técnica: Adeudos Abastos 1998

## Descripción General
Este módulo permite consultar el listado de adeudos de mercados del año 1998 para una oficina y periodo determinados. Incluye la lógica de cálculo de meses de adeudo, totales, y desglose de renta E/A y S/D. La solución está compuesta por:

- **Laravel Controller**: expone un endpoint unificado `/api/execute` para recibir eRequest y devolver eResponse.
- **Vue.js Component**: página independiente para consulta y visualización de los adeudos.
- **Stored Procedures PostgreSQL**: encapsulan la lógica de consulta y cálculo en la base de datos.
- **API Unificada**: todas las operaciones se realizan a través de `/api/execute`.

## Arquitectura

- **Frontend**: Vue.js (SPA), cada formulario es una página independiente.
- **Backend**: Laravel, controlador único para el endpoint `/api/execute`.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Datos
1. El usuario accede a la página de Adeudos Abastos 1998.
2. Selecciona año, oficina y periodo.
3. El frontend envía un POST a `/api/execute` con `{ action: 'get_adeudos_abastos_1998', params: { ... } }`.
4. Laravel recibe la petición, despacha al stored procedure correspondiente y retorna los datos.
5. El frontend muestra la tabla y totales.

## Detalles Técnicos
- **Stored Procedures**: encapsulan la lógica de negocio y cálculo de campos derivados (meses, totmeses, renta_ea, renta_sd).
- **API**: utiliza un solo endpoint para todas las operaciones, siguiendo el patrón eRequest/eResponse.
- **Vue.js**: utiliza Axios para consumir la API, muestra mensajes de error y loading.
- **Laravel**: el controlador mapea la acción solicitada a la función correspondiente.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y logging en Laravel.

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el stored procedure correspondiente.

## Ejemplo de eRequest/eResponse

**Request:**
```json
{
  "action": "get_adeudos_abastos_1998",
  "params": {
    "axo": 1998,
    "oficina": 5,
    "periodo": 12
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

## Consideraciones
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página independiente.
- El backend puede ser extendido para otros formularios siguiendo el mismo patrón.
