# Documentación Técnica: Descuento en Multa de Impuesto Transmisión (DescMultaTrans)

## Descripción General
Este módulo permite la gestión de descuentos en multas de impuesto por transmisión patrimonial. Incluye la consulta de folios, registro de descuentos, cancelación y consulta de historial, todo a través de un API unificada y una interfaz Vue.js.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio.
- **API:** Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Trabajo
1. El usuario ingresa un folio de transmisión y consulta si existe multa pendiente.
2. Si existe, puede consultar si hay descuentos vigentes o registrar uno nuevo.
3. El sistema valida el porcentaje máximo permitido según el autorizador.
4. El usuario puede cancelar descuentos vigentes.
5. Todas las acciones quedan registradas con usuario y fecha.

## Seguridad
- El usuario debe estar autenticado y su nombre de usuario se envía en cada petición.
- Los permisos para autorizar descuentos se consultan según el usuario.
- Validación de porcentaje máximo permitido por autorizador.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Entrada:**
  ```json
  {
    "action": "searchFolio|searchDiferencia|getDescuentos|altaDescuento|cancelarDescuento|autorizaList|calcDescuento",
    "params": { ... },
    "user": { "username": "usuario" }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": { ... },
    "message": "...",
    "errors": [ ... ]
  }
  ```

## Stored Procedures
- Toda la lógica de inserción, actualización y cálculo se realiza en stored procedures PostgreSQL.

## Validaciones
- El porcentaje de descuento no puede exceder el tope del autorizador.
- Solo puede haber un descuento vigente por folio.
- Solo se permite cancelar descuentos vigentes.

## Navegación
- Cada formulario es una página independiente (no tabs).
- Breadcrumbs para navegación contextual.

## Consideraciones
- El frontend debe manejar los estados de error y éxito.
- El backend debe registrar todas las acciones con usuario y fecha.