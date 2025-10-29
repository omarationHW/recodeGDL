# Documentación Técnica: Catálogo Claves de Operación (ABC_Cves_Operacion)

## Descripción General
Este módulo permite la administración (alta, baja, consulta y modificación) del catálogo de claves de operación (`ta_16_operacion`). Es un catálogo fundamental para la gestión de operaciones en el sistema de recolección de residuos.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación tipo breadcrumb.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **API:** Patrón unificado eRequest/eResponse.

## API
### Endpoint
`POST /api/execute`

#### Entrada
```json
{
  "eRequest": {
    "action": "list|get|insert|update|delete",
    "data": { ... }
  }
}
```

#### Salida
```json
{
  "eResponse": {
    "success": true|false,
    "message": "...",
    "data": [ ... ]
  }
}
```

### Acciones Soportadas
- `list`: Lista todas las claves de operación.
- `get`: Obtiene una clave por ID.
- `insert`: Inserta una nueva clave.
- `update`: Modifica una clave existente.
- `delete`: Elimina una clave (si no tiene pagos asociados).

## Stored Procedures
- `sp_cves_operacion_list()`: Lista todas las claves.
- `sp_cves_operacion_get(p_ctrol_operacion)`: Obtiene una clave por ID.
- `sp_cves_operacion_insert(p_cve_operacion, p_descripcion)`: Inserta una clave.
- `sp_cves_operacion_update(p_ctrol_operacion, p_cve_operacion, p_descripcion)`: Actualiza una clave.
- `sp_cves_operacion_delete(p_ctrol_operacion)`: Elimina una clave (con validación de integridad).

## Validaciones
- No se permite insertar claves duplicadas.
- No se puede eliminar una clave si existen pagos asociados.
- Todos los campos son obligatorios.

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o similar.
- Todas las operaciones quedan auditadas en logs de Laravel.

## Frontend
- Página independiente, sin tabs.
- Tabla con paginación y acciones de editar/eliminar.
- Formularios modales para alta y edición.
- Mensajes de éxito/error visibles.

## Navegación
- Breadcrumb: Inicio > Catálogo Claves de Operación

## Errores Comunes
- "Ya existe una clave con ese valor": al intentar duplicar clave.
- "No se puede eliminar: existen pagos asociados a esta clave.": al intentar borrar una clave usada.

## Pruebas
- Ver sección de casos de uso y casos de prueba.
