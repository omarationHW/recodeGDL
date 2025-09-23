# Documentación Técnica: Catálogo de Elaboro Oficio (ElaboroMntto)

## Descripción General
Este módulo permite la administración del catálogo de "Elaboro Oficio" (tabla `ta_17_elaboroficio`), que almacena la relación entre recaudadoras, usuarios titulares y usuarios que elaboran convenios. Incluye operaciones CRUD y consulta de información relacionada para mostrar en el formulario.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Unificada, patrón eRequest/eResponse.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ "eRequest": { "action": "list|show|create|update|delete|titular_info", "params": { ... } } }`
  - Salida: `{ "eResponse": { "success": bool, "message": string, "data": any } }`

## Acciones soportadas
- `list`: Lista todos los registros.
- `show`: Muestra un registro por ID.
- `create`: Crea un nuevo registro.
- `update`: Actualiza un registro existente.
- `delete`: Elimina un registro.
- `titular_info`: Consulta información de titular y elabora para mostrar en el formulario.

## Validaciones
- Todos los campos son obligatorios en `create` y `update`.
- Los IDs deben ser enteros.
- Las iniciales deben ser cadenas de máximo 10 caracteres.

## Stored Procedures
- `sp_elaboro_mntto_create`: Inserta un registro y retorna el ID.
- `sp_elaboro_mntto_update`: Actualiza un registro.
- `sp_elaboro_mntto_delete`: Elimina un registro.
- `sp_elaboro_mntto_titular_info`: Consulta información de titular y elabora.

## Seguridad
- El endpoint debe protegerse con autenticación JWT o similar.
- Validar que el usuario tenga permisos para crear/modificar/eliminar.

## Integración Vue.js
- El componente Vue consume el endpoint `/api/execute` usando fetch/AJAX.
- El formulario es reactivo y muestra los datos de titular/elabora al ingresar los IDs.
- La tabla muestra todos los registros y permite editar/eliminar.

## Errores comunes
- Si falta algún campo, el backend responde con error y mensaje descriptivo.
- Si se intenta eliminar un registro inexistente, retorna error.

## Ejemplo de request para crear:
```json
{
  "eRequest": {
    "action": "create",
    "params": {
      "id_rec": 1,
      "id_usu_titular": 10,
      "iniciales_titular": "JSM",
      "id_usu_elaboro": 12,
      "iniciales_elaboro": "MGA"
    }
  }
}
```

## Ejemplo de response:
```json
{
  "eResponse": {
    "success": true,
    "message": "Registro creado",
    "data": 123
  }
}
```

# Esquema de tabla (PostgreSQL)
```sql
CREATE TABLE ta_17_elaboroficio (
    id_control serial PRIMARY KEY,
    id_rec integer NOT NULL,
    id_usu_titular integer NOT NULL,
    iniciales_titular varchar(10) NOT NULL,
    id_usu_elaboro integer NOT NULL,
    iniciales_elaboro varchar(10) NOT NULL
);
```

# Notas
- El frontend debe validar que los campos no estén vacíos antes de enviar.
- El endpoint es único y multipropósito, todas las acciones pasan por `/api/execute`.
- Los stored procedures encapsulan toda la lógica de negocio y validación de integridad.
