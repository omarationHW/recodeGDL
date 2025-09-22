# Documentación Técnica: Migración de Formulario pagalicfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite marcar licencias o anuncios como pagados, actualizando los adeudos correspondientes y recalculando los saldos mediante procedimientos almacenados. La migración incluye:
- Un endpoint API unificado (`/api/execute`) bajo el patrón eRequest/eResponse.
- Un controlador Laravel que maneja toda la lógica de negocio y acceso a datos.
- Un componente Vue.js que representa la página completa del formulario.
- Procedimientos almacenados en PostgreSQL para el recálculo de saldos.

## Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3+, Bootstrap 5 (opcional para estilos)
- **API:** Endpoint único `/api/execute` que recibe `{action, params}` y responde `{success, data, message}`

## Flujo de Trabajo
1. El usuario selecciona si desea trabajar con Licencia o Anuncio.
2. Ingresa el número y año, y presiona Buscar.
3. El sistema consulta la existencia y adeudos pendientes.
4. Si existen adeudos, se muestran en una tabla.
5. El usuario puede marcar como pagado, lo que actualiza los registros y ejecuta el procedimiento almacenado de recálculo.

## Detalle de Acciones API
- **buscar_licencia**: Busca una licencia vigente y sus adeudos pendientes para el año dado.
- **buscar_anuncio**: Busca un anuncio vigente y sus adeudos pendientes para el año dado.
- **marcar_pagado**: Marca los adeudos como pagados (cvepago=999999999) y ejecuta el procedimiento almacenado de recálculo.

## Seguridad
- Se recomienda proteger el endpoint con autenticación y autorización según el contexto de la aplicación.
- Validar siempre los parámetros recibidos.

## Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los de la base de datos destino.
- Los procedimientos almacenados deben adaptarse a la lógica de negocio real.
- El frontend es una página independiente, sin tabs ni componentes compartidos.

## Ejemplo de Request/Response
### Buscar Licencia
```json
POST /api/execute
{
  "action": "buscar_licencia",
  "params": {
    "numero": 1234,
    "axo": 2024
  }
}
```

### Marcar como Pagado
```json
POST /api/execute
{
  "action": "marcar_pagado",
  "params": {
    "tipo": "licencia",
    "numero": 1234,
    "axo": 2024
  }
}
```

## Manejo de Errores
- Si no existe el número, se retorna `success: false` y un mensaje descriptivo.
- Si no hay adeudos, se informa al usuario.
- Si ocurre un error de base de datos, se retorna el mensaje de error.

## Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
