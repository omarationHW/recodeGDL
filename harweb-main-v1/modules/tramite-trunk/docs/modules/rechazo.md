# Documentación Técnica: Rechazo de Transmisión Patrimonial

## Descripción General
Este módulo permite registrar el rechazo de una transmisión patrimonial, almacenando el motivo y actualizando el estado del trámite. Incluye:
- API RESTful unificada (endpoint único `/api/execute`)
- Controlador Laravel para orquestar la lógica
- Componente Vue.js como página independiente
- Stored Procedures en PostgreSQL para lógica de negocio

## Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Proceso
1. El usuario accede a la página de rechazo de transmisión.
2. Ingresa el folio, motivo y usuario.
3. Al enviar, el frontend llama a `/api/execute` con `{ eRequest: { action: 'rechazar_transmision', folio, motivo, usuario } }`.
4. El backend ejecuta el stored procedure `sp_rechazar_transmision`.
5. El resultado se muestra al usuario.
6. Se puede consultar el motivo de rechazo con `{ eRequest: { action: 'get_motivo_rechazo', folio } }`.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: string, ...params } }`
- **Salida**: `{ eResponse: { success: bool, message: string, ... } }`

## Stored Procedures
- `sp_rechazar_transmision(folio, motivo, usuario)`
- `sp_get_motivo_rechazo(folio)`

## Validaciones
- El folio debe existir.
- No se puede rechazar dos veces el mismo folio.
- El motivo es obligatorio.

## Seguridad
- El usuario debe estar autenticado (no incluido aquí, pero el campo usuario es obligatorio).
- El endpoint debe estar protegido por middleware de autenticación en producción.

## Integración
- El frontend y backend se comunican exclusivamente por el endpoint `/api/execute`.
- El backend orquesta la lógica y delega a los stored procedures.

## Migración de Datos
- El campo `documentosotros` de la tabla `actostransm` almacena el motivo del rechazo.
- Se agregan los campos `usuario_rechazo` y `fecha_rechazo` a la tabla `actostransm` si no existen.

## Ejemplo de Request
```json
{
  "eRequest": {
    "action": "rechazar_transmision",
    "folio": 12345,
    "motivo": "DOCUMENTACIÓN INCOMPLETA",
    "usuario": "admin"
  }
}
```

## Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Transmisión rechazada correctamente."
  }
}
```

## Consideraciones
- El frontend fuerza el motivo a mayúsculas.
- El backend valida todos los campos obligatorios.
- El proceso es atómico y seguro.
