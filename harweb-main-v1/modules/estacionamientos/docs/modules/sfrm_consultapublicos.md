# Documentación Técnica: Migración de sfrm_consultapublicos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y `params`.
- **Frontend:** Vue.js SPA con rutas independientes para cada formulario (Lista, Adeudos, Multas, Licencia).
- **Base de Datos:** PostgreSQL con stored procedures para encapsular la lógica de negocio y consultas.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getPublicParkingList", // o cualquier otro eRequest soportado
    "params": { ... } // parámetros específicos según el eRequest
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

### eRequest soportados
- `getPublicParkingList`: Lista de estacionamientos públicos
- `getPublicParkingDebts`: Adeudos de un estacionamiento (`pubid`)
- `getPublicParkingFines`: Multas de un estacionamiento (`numlicencia`)
- `getLicenseGeneral`: Datos generales de licencia (`numlicencia`)
- `getLicenseTotals`: Totales de licencia (`id_licencia`, `tipo_l`, `redon`)

## Stored Procedures
- Cada consulta compleja o lógica de negocio se implementa como una función en PostgreSQL.
- Los SPs devuelven tablas para facilitar la integración con Laravel.

## Frontend (Vue.js)
- Cada formulario/tab de Delphi es ahora una página independiente:
  - `/public-parking/list` (Lista)
  - `/public-parking/debts/:pubid` (Adeudos)
  - `/public-parking/fines/:numlicencia` (Multas)
  - `/public-parking/license/:numlicencia` (Licencia)
- Navegación entre páginas mediante `<router-link>`.
- Cada página hace su propia llamada a `/api/execute` con el eRequest correspondiente.

## Backend (Laravel)
- Un solo controlador maneja todas las peticiones y despacha según el valor de `eRequest`.
- Cada caso llama al SP correspondiente usando DB::select.
- Manejo de errores y validación de parámetros.

## Seguridad
- Se recomienda proteger el endpoint con autenticación y validación de parámetros.

## Extensibilidad
- Para agregar nuevas vistas o lógica, basta con:
  1. Crear un nuevo SP en PostgreSQL.
  2. Agregar el caso en el controlador Laravel.
  3. Crear la página Vue correspondiente.

## Notas
- Los nombres de las tablas y vistas deben existir en la base de datos destino.
- Los SPs pueden adaptarse según la estructura real de la base de datos.
