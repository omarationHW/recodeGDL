# Documentación Técnica: Consulta Individual de Requerimientos (DatosRequerimientos)

## Descripción General
Este módulo permite consultar los datos completos de un requerimiento fiscal por folio, mostrando información del local, mercado, requerimiento y periodos asociados. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe eRequest/eResponse y delega a stored procedures en PostgreSQL.
- **Frontend Vue.js**: Un componente de página completa que permite la consulta interactiva.
- **Stored Procedures PostgreSQL**: Toda la lógica de consulta reside en SPs para eficiencia y seguridad.
- **API Unificada**: Todas las operaciones se realizan a través de `/api/execute` con un campo `action` y parámetros.

## Arquitectura
- **API**: `/api/execute` (POST)
  - Body: `{ action: string, params: object }`
  - Respuesta: `{ success: bool, data: array/object, message?: string }`
- **Frontend**: Página Vue.js independiente, sin tabs, con navegación breadcrumb.
- **Backend**: Controlador Laravel que despacha según `action`.
- **DB**: Stored procedures para cada consulta.

## Flujo de Consulta
1. Usuario ingresa ID Local, Módulo y Folio.
2. Se consulta el local (`sp_get_locales`).
3. Se consulta el mercado asociado (`sp_get_mercado`).
4. Se consulta el requerimiento por folio (`sp_get_requerimientos`).
5. Se consultan los periodos asociados (`sp_get_periodos`).
6. Se muestran todos los datos en la página.

## Seguridad
- Todas las consultas requieren autenticación JWT (middleware Laravel).
- Validación de parámetros en backend.
- Los SPs sólo retornan datos permitidos.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y SPs sin modificar el endpoint.
- El frontend puede consumir nuevas acciones simplemente cambiando el `action`.

## Ejemplo de eRequest/eResponse
```json
{
  "action": "getRequerimientos",
  "params": {
    "modulo": 11,
    "folio": 12345,
    "control_otr": 6789
  }
}
```

## Manejo de Errores
- Si falta un parámetro, se retorna HTTP 422 con mensaje.
- Si no hay datos, se retorna success: false y mensaje.
- Todos los errores son capturados y devueltos en formato JSON.

## Frontend
- El componente Vue.js es una página completa, no usa tabs.
- Incluye navegación breadcrumb.
- Muestra todos los datos relevantes en tablas.
- Usa filtros para formato de moneda.
- Maneja loading y errores.

## Backend
- El controlador Laravel es delgado y sólo despacha a SPs.
- Toda la lógica de negocio y SQL está en los SPs.
- El endpoint es único y flexible.

## Base de Datos
- Todas las consultas usan SPs en PostgreSQL.
- Los SPs están optimizados para retornar sólo los campos necesarios.

## Pruebas
- Se proveen casos de uso y pruebas para asegurar la funcionalidad.
