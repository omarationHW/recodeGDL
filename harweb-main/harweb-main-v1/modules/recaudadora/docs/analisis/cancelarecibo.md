# Documentación Técnica: Cancelación de Recibos de Cobro

## Descripción General
Este módulo permite la cancelación de recibos de cobro a través de una interfaz web desarrollada en Vue.js, con backend en Laravel y lógica de negocio centralizada en stored procedures de PostgreSQL. Toda la comunicación entre frontend y backend se realiza mediante un endpoint unificado `/api/execute` siguiendo el patrón eRequest/eResponse.

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente para cancelación de recibos.
- **Backend:** Laravel Controller (ExecuteController) con endpoint `/api/execute`.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse, un solo endpoint para múltiples operaciones.

## Flujo de Operación
1. **Búsqueda de Recibo:**
   - El usuario ingresa recaudadora, caja, folio, importe y (si aplica) fecha.
   - El frontend envía un eRequest `buscar_recibo_pago` con los parámetros.
   - El backend ejecuta el SP `buscar_recibo_pago` y retorna los datos del recibo.
2. **Validación de Cancelación:**
   - Si el recibo es de concepto predial (cveconcepto=1), se verifica que no existan certificados de no adeudo posteriores usando el SP `verificar_no_adeudo`.
3. **Cancelación:**
   - Si es válido, el frontend envía un eRequest `cancelar_recibo_pago`.
   - El backend ejecuta el SP `cancelar_recibo_pago`, que realiza la lógica de negocio y registra la cancelación.

## Detalle de Stored Procedures
- **buscar_recibo_pago:** Busca el recibo con los parámetros dados, considerando la lógica de usuario 'proceso' para la fecha.
- **verificar_no_adeudo:** Verifica si existen certificados de no adeudo posteriores al pago.
- **cancelar_recibo_pago:** Ejecuta la cancelación, actualizando tablas relacionadas según el tipo de concepto.

## Endpoint API
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "eRequest": "nombre_operacion",
      "params": { ... }
    }
    ```
  - **eRequest posibles:**
    - buscar_recibo_pago
    - verificar_no_adeudo
    - cancelar_recibo_pago
  - **Respuesta:**
    ```json
    {
      "eResponse": [ ... ]
    }
    ```

## Seguridad
- El usuario debe estar autenticado o enviar el nombre de usuario en los parámetros.
- Las operaciones de cancelación deben ser auditadas y sólo accesibles a usuarios autorizados.

## Manejo de Errores
- Los stored procedures retornan mensajes de error en el campo `message`.
- El frontend muestra mensajes claros al usuario.

## Consideraciones
- El SP `canc_plicencia` debe existir en PostgreSQL para la cancelación de licencias.
- El campo `cvecanc` en la tabla `pagos` debe actualizarse tras la cancelación.
- El frontend debe manejar el flujo de foco y validaciones como en la versión Delphi.

# Estructura de Tablas Relevantes
- **pagos:** Recibos de pago.
- **pagoscan:** Registro de cancelaciones.
- **gastmult, imprectp:** Relacionadas para mostrar detalles del recibo.
- **noadeudo:** Certificados de no adeudo.

# Ejemplo de Llamada API
```json
{
  "eRequest": "cancelar_recibo_pago",
  "params": {
    "cvepago": 1234,
    "cvecuenta": 5678,
    "cveconcepto": 1,
    "user_name": "admin",
    "fecha_cancelacion": "2024-06-10"
  }
}
```
