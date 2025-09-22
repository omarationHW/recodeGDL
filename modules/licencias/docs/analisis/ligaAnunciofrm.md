# Documentación Técnica: Liga de Anuncios a Licencias

## Descripción General
Este módulo permite ligar (asociar) un anuncio existente a una licencia o empresa, actualizando los datos de ubicación del anuncio y recalculando los saldos correspondientes. La migración se realizó desde Delphi a Laravel (backend) y Vue.js (frontend), usando PostgreSQL y un API unificada.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **API:** Todas las acciones (buscar, ligar, etc.) se ejecutan vía `/api/execute` con parámetros `{ action, params }`.

## Flujo de Trabajo
1. El usuario busca una licencia o empresa (según el checkbox).
2. El usuario busca el anuncio a ligar.
3. El sistema valida la vigencia de los registros.
4. Si el anuncio ya está ligado, solicita confirmación.
5. Al aceptar, ejecuta el stored procedure `sp_ligar_anuncio` que actualiza los datos y recalcula saldos.
6. El frontend muestra mensajes de éxito o error.

## Seguridad y Validaciones
- Solo se permite ligar anuncios y licencias/empresas vigentes.
- Si el anuncio ya está ligado, requiere confirmación explícita.
- Todas las operaciones son transaccionales.

## API: Ejemplo de Request
```json
{
  "action": "ligarAnuncio",
  "params": {
    "anuncio_id": 123,
    "licencia_id": 456,
    "empresa_id": null,
    "isEmpresa": false,
    "user": "usuario_actual"
  }
}
```

## API: Ejemplo de Response
```json
{
  "success": true,
  "message": "Anuncio ligado correctamente"
}
```

## Stored Procedures
- `sp_ligar_anuncio`: Lógica principal de ligadura.
- `calc_sdosl`: Recalcula saldos (debe implementarse según reglas de negocio).

## Frontend
- Página Vue.js independiente, sin tabs.
- Permite buscar por licencia o empresa, buscar anuncio, y ligar.
- Mensajes claros de error/éxito.
- Solicita confirmación si el anuncio ya está ligado.

## Pruebas y Casos de Uso
- Incluye validaciones de campos, confirmaciones y mensajes de error.

## Extensibilidad
- El endpoint `/api/execute` puede ser usado para otras acciones relacionadas.
- Los stored procedures pueden ampliarse para lógica adicional.
