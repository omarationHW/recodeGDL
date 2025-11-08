# Documentación Técnica: Migración de Formulario GAdeudos_OpcMult

## Descripción General
Este módulo permite la gestión de adeudos múltiples para concesiones, permitiendo operaciones como dar de pagado, condonar, cancelar o prescribir adeudos. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## Flujo de Trabajo
1. El usuario accede a la página de Opción Múltiple de Adeudos.
2. Selecciona el tipo de búsqueda (por expediente o local) y realiza la búsqueda.
3. El sistema consulta los datos generales de la concesión y muestra los adeudos vigentes.
4. El usuario selecciona los adeudos a procesar y la opción a realizar (pagado, condonar, cancelar, prescribir).
5. Al ejecutar, se llama al stored procedure correspondiente para procesar la operación.
6. El usuario puede consultar los pagos realizados (pagados).

## API (Laravel)
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
  - `getCajas`
  - `getEtiquetas`
  - `getTablas`
  - `buscarConcesion`
  - `buscarAdeudos`
  - `buscarPagados`
  - `ejecutarOpcion`

## Stored Procedures
- **cob34_gdatosg_02:** Devuelve los datos generales de la concesión/control.
- **cob34_gdetade_01:** Devuelve el detalle de adeudos para un control, año y mes.
- **upd34_gen_adeudos_ind:** Procesa la opción seleccionada sobre un adeudo individual (pago, condonación, cancelación, prescripción).

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo, validación de campos.
- Tabla de adeudos con selección múltiple.
- Botón para ejecutar la opción seleccionada.
- Visualización de pagos realizados.

## Seguridad
- Validación de parámetros en backend y frontend.
- Uso de transacciones en stored procedures para garantizar atomicidad.
- El usuario debe estar autenticado para registrar operaciones (par_usuario).

## Consideraciones
- El endpoint es único y recibe la acción a ejecutar.
- Los stored procedures encapsulan toda la lógica de negocio.
- El frontend es desacoplado y consume la API vía Axios.

