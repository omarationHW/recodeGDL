# AutCargaPagosMtto

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - AutCargaPagosMtto

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva fecha de ingreso autorizada

**Descripción:** Un usuario con permiso desea autorizar una nueva fecha de ingreso para la carga de pagos de mantenimiento.

**Precondiciones:**
El usuario está autenticado y tiene permiso de autorización en su oficina.

**Pasos a seguir:**
1. El usuario accede a la página 'Autorizar Fecha de Ingreso'.
2. Selecciona la fecha de ingreso, la fecha límite y el usuario que otorga el permiso.
3. Escribe un comentario (opcional).
4. Da clic en 'Aceptar'.
5. El sistema valida y registra la fecha como autorizada.

**Resultado esperado:**
La fecha queda registrada y aparece en la lista de fechas autorizadas.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-05",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 7,
  "comentarios": "AUTORIZADO POR AUDITORIA"
}

---

## Caso de Uso 2: Bloquear una fecha de ingreso

**Descripción:** Un usuario con permiso decide bloquear una fecha de ingreso previamente autorizada.

**Precondiciones:**
Existe una fecha de ingreso autorizada y el usuario tiene permiso.

**Pasos a seguir:**
1. El usuario accede a la página y localiza la fecha a bloquear.
2. Da clic en 'Editar'.
3. Cambia el campo 'Permiso' a 'BLOQUEAR FECHA'.
4. Actualiza el comentario.
5. Da clic en 'Aceptar'.

**Resultado esperado:**
La fecha queda marcada como bloqueada y no se permite la carga de pagos en esa fecha.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-05",
  "oficina": 2,
  "autorizar": "N",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 7,
  "comentarios": "BLOQUEADO POR SUPERVISIÓN"
}

---

## Caso de Uso 3: Listar fechas autorizadas y bloqueadas

**Descripción:** Un usuario consulta todas las fechas de ingreso autorizadas y bloqueadas para su oficina.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página.
2. El sistema muestra la tabla con todas las fechas y su estado (autorizada/bloqueada).

**Resultado esperado:**
Se visualizan correctamente todas las fechas con su estado y comentarios.

**Datos de prueba:**
{
  "oficina": 2
}

---



## Casos de Prueba

# Casos de Prueba: AutCargaPagosMtto

## Caso 1: Registro exitoso de fecha autorizada
- **Precondición**: Usuario autenticado con permiso
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='S', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='AUTORIZADO POR AUDITORIA'
- **Acción**: POST /api/execute con action=insert_autcargapag
- **Resultado esperado**: Respuesta success=true, la fecha aparece en la lista

## Caso 2: Bloqueo de fecha existente
- **Precondición**: Fecha ya registrada como autorizada
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='N', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='BLOQUEADO POR SUPERVISIÓN'
- **Acción**: POST /api/execute con action=update_autcargapag
- **Resultado esperado**: Respuesta success=true, la fecha aparece como bloqueada

## Caso 3: Validación de campos obligatorios
- **Precondición**: Usuario autenticado
- **Entrada**: fecha_ingreso='', oficina=2, autorizar='S', fecha_limite='', id_usupermiso='', comentarios=''
- **Acción**: POST /api/execute con action=insert_autcargapag
- **Resultado esperado**: Respuesta success=false, message indica campos obligatorios

## Caso 4: Listado de fechas
- **Precondición**: Fechas registradas para la oficina
- **Entrada**: oficina=2
- **Acción**: POST /api/execute con action=list_autcargapag
- **Resultado esperado**: Respuesta success=true, data contiene arreglo de fechas

## Caso 5: Edición de comentario
- **Precondición**: Fecha existente
- **Entrada**: fecha_ingreso=2024-06-05, oficina=2, autorizar='S', fecha_limite=2024-06-10, id_usupermiso=7, comentarios='ACTUALIZADO POR ADMINISTRADOR'
- **Acción**: POST /api/execute con action=update_autcargapag
- **Resultado esperado**: Respuesta success=true, comentario actualizado en la lista



