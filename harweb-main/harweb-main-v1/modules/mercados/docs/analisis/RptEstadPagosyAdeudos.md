# Documentación Técnica: Estadística de Pagos y Adeudos de Mercados

## Descripción General
Este módulo permite consultar la estadística de pagos, capturas y adeudos de los mercados municipales, agrupados por recaudadora y mercado, para un periodo y rango de fechas determinado. Incluye:
- Backend en Laravel (API RESTful, endpoint unificado)
- Frontend en Vue.js (página independiente)
- Lógica de negocio y reportes en stored procedures PostgreSQL
- Comunicación vía eRequest/eResponse con endpoint único `/api/execute`

## Arquitectura
- **Backend:** Laravel Controller con endpoint `/api/execute` que recibe un objeto JSON con los campos `action` y `params`.
- **Frontend:** Componente Vue.js que implementa la UI y consume el endpoint vía Axios.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures.

## Flujo de Datos
1. El usuario accede a la página de "Estadística de Pagos y Adeudos".
2. Selecciona recaudadora, mercado, año, mes y rango de fechas.
3. El frontend envía un POST a `/api/execute` con la acción y parámetros.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos en formato JSON.
5. El frontend muestra la tabla resumen.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getEstadisticaPagosyAdeudos",
    "params": {
      "id_rec": 1,
      "axo": 2024,
      "mes": 6,
      "fec3": "2024-06-01",
      "fec4": "2024-06-30"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Stored Procedures
- **sp_estad_pagosyadeudos:** Devuelve la estadística detallada por mercado.
- **sp_estad_pagosyadeudos_resumen:** Devuelve el resumen global por tipo (pagados, capturados, adeudos).

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar y sanitizar todos los parámetros recibidos.

## Consideraciones de Migración
- Todas las consultas SQL y lógica de agregación se trasladan a stored procedures.
- El frontend no debe tener lógica de negocio, solo presentación y validación básica.
- El backend solo expone el endpoint unificado y delega la lógica a los SP.

## Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` para otros reportes o catálogos.
- El frontend puede ser extendido para exportar a Excel o PDF usando bibliotecas JS.

## Estructura de Carpetas
- `app/Http/Controllers/EstadPagosyAdeudosController.php`
- `resources/js/pages/EstadPagosyAdeudosPage.vue`
- `database/migrations/` y `database/procedures/` para los SP

#
