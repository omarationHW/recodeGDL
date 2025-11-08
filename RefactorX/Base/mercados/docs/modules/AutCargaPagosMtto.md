# Documentación Técnica: Migración de Formulario AutCargaPagosMtto

## Descripción General
Este módulo permite la autorización y bloqueo de fechas de ingreso para la carga masiva de pagos de mantenimiento en mercados. Incluye la gestión de permisos, usuarios autorizados y comentarios de auditoría.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL con lógica encapsulada en stored procedures.

## Flujo de Datos
1. El frontend solicita la lista de usuarios con permiso para autorizar fechas en la oficina del usuario.
2. El usuario puede registrar o modificar una fecha de ingreso, indicando si se autoriza o bloquea, la fecha límite, el usuario que otorga el permiso y un comentario.
3. El backend ejecuta el stored procedure correspondiente para insertar o actualizar el registro.
4. El frontend muestra la lista de fechas autorizadas/bloqueadas y permite editar registros existentes.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `get_users_with_permission`: Devuelve usuarios con permiso para autorizar fechas.
  - `get_autcargapag_by_fecha`: Devuelve registro por fecha de ingreso.
  - `insert_autcargapag`: Inserta nuevo registro.
  - `update_autcargapag`: Actualiza registro existente.
  - `list_autcargapag`: Lista todas las fechas para una oficina.

## Validaciones
- Todos los campos son obligatorios excepto comentarios.
- No se permite registrar dos veces la misma fecha de ingreso para la misma oficina.
- Solo usuarios con permiso pueden autorizar fechas.

## Seguridad
- El endpoint requiere autenticación JWT o session.
- El id_usuario se toma del usuario autenticado.
- Los stored procedures validan la existencia de la oficina y usuario.

## Manejo de Errores
- Los errores de validación y de base de datos se devuelven en el campo `message` del eResponse.
- El frontend muestra mensajes de error y éxito.

## Integración
- El componente Vue.js se integra en el router principal como página independiente.
- El backend puede ser extendido para auditar cambios en una tabla de logs si se requiere.

## Ejemplo de eRequest/eResponse
```json
{
  "action": "insert_autcargapag",
  "params": {
    "fecha_ingreso": "2024-06-01",
    "oficina": 2,
    "autorizar": "S",
    "fecha_limite": "2024-06-10",
    "id_usupermiso": 5,
    "comentarios": "AUTORIZADO POR AUDITORIA",
    "actualizacion": "2024-06-01T12:00:00Z"
  }
}
```

## Notas
- El frontend asume que la oficina del usuario autenticado es la que se usa para filtrar y registrar fechas.
- El campo `comentarios` se almacena en mayúsculas.
- El campo `autorizar` es 'S' para autorizar, 'N' para bloquear.
