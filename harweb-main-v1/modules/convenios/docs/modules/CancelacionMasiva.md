# Cancelación Masiva de Convenios

## Descripción General
Este módulo permite la cancelación automática de convenios de pago que han incumplido el pago de un número configurable de parcialidades vencidas, excluyendo ciertos tipos (por ejemplo, licencias de construcción). La funcionalidad incluye:
- Listado de convenios cancelados en el día.
- Ejecución de la cancelación masiva según reglas de negocio.
- Registro de usuario y fecha de la operación.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API
### Endpoint Unificado
- **POST /api/execute**
- **Body:**
  - `action`: string (ej: 'cancelacion_masiva_listar', 'cancelacion_masiva_ejecutar')
  - `params`: objeto con parámetros específicos

#### Acciones soportadas
- `cancelacion_masiva_listar`: Lista convenios cancelados hoy.
- `cancelacion_masiva_ejecutar`: Ejecuta la cancelación masiva.

### Ejemplo de Request
```json
{
  "action": "cancelacion_masiva_ejecutar",
  "params": {
    "vencidas": 2
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "message": "SE CANCELARON 12 CONVENIOS",
  "data": {
    "totbajas": 12,
    "estado": 0,
    "mensaje": "SE CANCELARON 12 CONVENIOS"
  }
}
```

## Stored Procedures
- **sp_cancelacionmasiva_listar**: Devuelve los convenios cancelados hoy.
- **sp_cancelacionmasiva_ejecutar**: Ejecuta la lógica de cancelación masiva.

## Seguridad
- El endpoint requiere autenticación JWT.
- El usuario autenticado se registra en la operación.
- El SP valida el usuario y fecha.

## Frontend
- Página Vue.js independiente.
- Permite configurar el número de parcialidades vencidas.
- Muestra la lista de convenios cancelados.
- Botón para ejecutar la cancelación masiva.
- Mensajes de éxito/error.

## Integración
- El frontend se comunica con el backend vía `/api/execute`.
- El backend invoca los stored procedures y retorna el resultado.

## Consideraciones
- El SP excluye licencias de construcción (tipo=4) de la cancelación masiva.
- El número de parcialidades vencidas es configurable.
- El proceso es auditable (usuario, fecha).
