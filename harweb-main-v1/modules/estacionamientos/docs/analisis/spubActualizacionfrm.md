# Documentación Técnica: Migración de Formulario spubActualizacionfrm a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (Vistas independientes por formulario, navegación por rutas)
- **Base de Datos:** PostgreSQL (Stored Procedures para lógica de negocio)
- **Patrón de Comunicación:** eRequest/eResponse (payload JSON con acción y parámetros)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "nombreAccion",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": { ... },
      "message": "..."
    }
  }
  ```

## Acciones Soportadas
- `getEstacionamiento`: Consulta datos de un estacionamiento
- `updateEstacionamiento`: Modifica datos de un estacionamiento
- `bajaEstacionamiento`: Da de baja un estacionamiento
- `getAdeudos`: Consulta adeudos de un estacionamiento
- `getRecibos`: Consulta recibos de pago
- `getReciboDetalle`: Detalle de un recibo
- `getCategorias`: Consulta categorías disponibles
- `deleteAdeudo`: Elimina adeudos hasta un año/mes
- `insertAdeudo`: Inserta un nuevo adeudo
- `actualizaPubPago`: Aplica pago a un adeudo
- `spPubMovtos`: Incremento/decremento de cajones o cambio de categoría
- `getMultasRelacionadas`: Consulta multas relacionadas

## Stored Procedures
- Toda la lógica de negocio y reportes se implementa en funciones/procedimientos de PostgreSQL.
- Los procedimientos devuelven tablas o mensajes de resultado.

## Frontend (Vue.js)
- Cada formulario/tab original es ahora una página independiente:
  - Modificación
  - Baja
  - Incrementos/Decrementos
  - Cambio de Categoría
  - Adeudos
  - Pagos
  - Multas
- Navegación por rutas (`/estacionamientos/modificacion`, `/estacionamientos/baja`, etc.)
- Cada página consume el endpoint `/api/execute` usando eRequest/eResponse.
- Breadcrumbs para navegación contextual.

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El controlador obtiene el usuario autenticado para registrar acciones.

## Consideraciones de Migración
- Los componentes visuales Delphi (DBText, DBGrid, etc.) se reemplazan por componentes de formulario y tablas en Vue.js.
- Las operaciones de base de datos (Query, StoredProc) se traducen a funciones/procedimientos PostgreSQL y se invocan desde Laravel.
- El patrón eRequest/eResponse permite desacoplar el frontend del backend y facilita la extensión futura.

## Ejemplo de Flujo
1. El usuario accede a la página de modificación.
2. Ingresa el número de estacionamiento y presiona "Buscar".
3. El frontend envía:
   ```json
   {
     "eRequest": {
       "action": "getEstacionamiento",
       "params": { "numesta": 123 }
     }
   }
   ```
4. El backend responde con los datos del estacionamiento.
5. El usuario edita y presiona "Actualizar".
6. El frontend envía:
   ```json
   {
     "eRequest": {
       "action": "updateEstacionamiento",
       "params": { ...datos... }
     }
   }
   ```
7. El backend ejecuta el SP y responde con éxito o error.

## Extensibilidad
- Para agregar nuevas acciones, basta con implementar el SP y agregar el case correspondiente en el controlador.
- El frontend puede extenderse fácilmente agregando nuevas páginas/rutas.
