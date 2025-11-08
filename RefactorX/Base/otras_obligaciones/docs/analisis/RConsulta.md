# Documentación Técnica: Migración de Formulario RConsulta (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (todas las consultas y lógica encapsuladas en stored procedures)
- **Patrón de integración:** eRequest/eResponse (todas las operaciones pasan por un único endpoint y se identifican por el campo `action`)

## Endpoints
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "nombre_accion",
      "params": { ... }
    }
    ```
  - **Respuesta:**
    ```json
    {
      "success": true|false,
      "data": [...],
      "error": "mensaje de error si aplica"
    }
    ```

## Acciones soportadas (action)
- `get_concesion_by_control`: Busca datos de concesión/local por clave de control
- `get_adeudos_by_concesion`: Obtiene detalle de adeudos por id_34_datos y periodo
- `get_totales_by_concesion`: Obtiene totales de adeudos agrupados por concepto
- `get_pagados_by_concesion`: Obtiene pagos realizados (status P)
- `get_fecha_limite`: Obtiene la fecha límite del periodo actual

## Stored Procedures
- Todas las consultas SQL se migran a funciones de PostgreSQL (ver sección stored_procedures)
- Los procedimientos pueden ser extendidos para lógica adicional (validaciones, reglas de negocio)

## Frontend (Vue.js)
- El componente es una página completa, sin tabs ni subcomponentes
- El usuario ingresa el número y letra del local, y al buscar se muestran los datos, adeudos, totales y pagos realizados
- Validaciones de campos y mensajes de error amigables
- Navegación breadcrumb incluida
- Uso de filtros para formato de moneda y fechas

## Backend (Laravel)
- El controlador `ExecuteController` recibe todas las peticiones y despacha según el campo `action`
- Cada acción llama al stored procedure correspondiente y retorna los datos
- Manejo de errores y validaciones centralizado

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción
- Validar y sanitizar todos los parámetros recibidos

## Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el stored procedure correspondiente
- El frontend puede consumir cualquier acción nueva sin cambios estructurales

## Pruebas
- Se recomienda usar Postman o similar para pruebas de API
- El frontend puede ser probado con Cypress o Jest

## Despliegue
- El backend debe tener acceso a la base de datos PostgreSQL
- El frontend puede ser desplegado como SPA en cualquier servidor web

