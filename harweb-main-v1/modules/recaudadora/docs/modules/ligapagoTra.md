# Documentación Técnica: Migración Formulario Liga Pago Diverso a Transmisión Patrimonial

## Descripción General
Este módulo permite ligar pagos diversos (pagos de caja) a transmisiones patrimoniales (actostransm), incluyendo la posibilidad de ligar diferencias (diferencias_glosa). El proceso se realiza mediante un endpoint API unificado y stored procedures en PostgreSQL, con una interfaz Vue.js como página independiente.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe eRequest (action, params) y responde eResponse (status, data, message).
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y formularios independientes.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones usan el endpoint `/api/execute`.

## Flujo de Trabajo
1. **Búsqueda de Pago**: El usuario ingresa fecha, recaudadora, caja y folio. El sistema busca el pago en la tabla `pagos`.
2. **Búsqueda de Transmisión**: El usuario ingresa el folio de transmisión. El sistema busca en `actostransm`.
3. **Liga de Pago**: El usuario selecciona el tipo de liga (Completo, Convenio, Diferencia) y ejecuta la liga. El sistema llama el SP `sp_ligar_pago_transmision`.
4. **Diferencias**: Si el tipo es diferencia, se actualiza también la tabla `diferencias_glosa`.

## Seguridad
- Validación de parámetros en backend y frontend.
- Solo usuarios autenticados pueden ejecutar la acción de liga (en producción, el usuario se toma del contexto de sesión).

## API eRequest/eResponse
- **eRequest**: `{ action: string, params: object }`
- **eResponse**: `{ status: 'ok'|'error', data: any, message: string }`

## Stored Procedures
- Toda la lógica de negocio y validación crítica reside en SPs de PostgreSQL.

## Componentes Vue.js
- Página independiente, sin tabs.
- Breadcrumb para navegación.
- Formularios validados y mensajes claros.

## Integración
- El frontend llama a `/api/execute` con la acción y parámetros correspondientes.
- El backend enruta la acción al método y SP adecuado.

## Ejemplo de llamada API
```json
{
  "action": "ligarPagoTransmision",
  "params": {
    "cvepago": 12345,
    "cvecta": 67890,
    "usuario": "usuario_actual",
    "tipo": 22,
    "fecha": "2024-06-01",
    "folio_transmision": 5555
  }
}
```

## Validaciones
- El pago debe existir y ser de tipo diverso (cveconcepto=4).
- El folio de transmisión debe existir.
- No se puede ligar si la cuenta está exenta o cancelada.
- Si es diferencia, debe existir en diferencias_glosa.

## Mensajes de Error
- "No existe el pago a ligar"
- "No existe el folio de transmisión"
- "Pago ligado correctamente"

## Consideraciones
- El usuario debe ser autenticado y autorizado.
- El SP maneja la lógica de actualización de diferencias y transmisión.
- El frontend muestra mensajes claros y actualiza el estado de la UI.

