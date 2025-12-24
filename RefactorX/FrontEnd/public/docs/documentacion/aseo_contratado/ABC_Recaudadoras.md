# DocumentaciÃ³n TÃ©cnica: ABC_Recaudadoras

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de ABC_Recaudadoras (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.

## Flujo de Solicitudes
1. **Frontend** envía un POST a `/api/execute` con `{ action: '...', params: {...} }`.
2. **Laravel Controller** recibe la petición, despacha según `action` y llama el stored procedure correspondiente.
3. **Stored Procedure** ejecuta la lógica y retorna resultado estructurado.
4. **Controller** retorna JSON `{ success, data, message }`.
5. **Vue Component** actualiza la UI según respuesta.

## Endpoints y Acciones
- `getRecaudadoras`: Lista todas las recaudadoras.
- `insertRecaudadora`: Inserta una recaudadora (requiere `num_rec`, `descripcion`).
- `updateRecaudadora`: Actualiza descripción (requiere `num_rec`, `descripcion`).
- `deleteRecaudadora`: Elimina recaudadora (requiere `num_rec`).

## Validaciones y Seguridad
- Todas las operaciones de inserción/actualización/eliminación se validan en el SP.
- No se permite eliminar recaudadoras con contratos asociados.
- El frontend valida campos requeridos y tipos.

## Manejo de Errores
- Los SP retornan `success` y `message`.
- El controlador propaga errores de SP o de base de datos.
- El frontend muestra mensajes amigables.

## Estructura de la Tabla
```sql
CREATE TABLE ta_16_recaudadoras (
    num_rec SMALLINT PRIMARY KEY,
    descripcion VARCHAR(80) NOT NULL
);
```

## Ejemplo de eRequest/eResponse
```json
{
  "action": "insertRecaudadora",
  "params": {
    "num_rec": 5,
    "descripcion": "Recaudadora Centro"
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": null,
  "message": "Recaudadora agregada correctamente."
}
```

## Navegación y UI
- Cada formulario es una página Vue.js independiente.
- Breadcrumbs para navegación contextual.
- Modales para alta/edición.
- Tabla con acciones de editar/eliminar.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SP pueden ser versionados y auditados.

## Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o similar en producción.

# Notas de Migración
- El formulario Delphi usaba DataSource y Query; ahora todo es API REST + SP.
- El control de errores y mensajes amigables se traslada al SP y frontend.
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página.


## Casos de Prueba

## Casos de Prueba para ABC_Recaudadoras

### 1. Alta de recaudadora válida
- **Entrada:** num_rec=20, descripcion='Recaudadora Sur'
- **Acción:** insertRecaudadora
- **Esperado:** success=true, message='Recaudadora agregada correctamente.'

### 2. Alta de recaudadora duplicada
- **Entrada:** num_rec=20, descripcion='Otra'
- **Acción:** insertRecaudadora
- **Esperado:** success=false, message='Ya existe una recaudadora con ese número.'

### 3. Edición de recaudadora existente
- **Entrada:** num_rec=20, descripcion='Recaudadora Sur Editada'
- **Acción:** updateRecaudadora
- **Esperado:** success=true, message='Recaudadora actualizada correctamente.'

### 4. Edición de recaudadora inexistente
- **Entrada:** num_rec=99, descripcion='No existe'
- **Acción:** updateRecaudadora
- **Esperado:** success=false, message='No existe la recaudadora.'

### 5. Eliminación de recaudadora sin contratos
- **Entrada:** num_rec=20
- **Acción:** deleteRecaudadora
- **Esperado:** success=true, message='Recaudadora eliminada correctamente.'

### 6. Eliminación de recaudadora con contratos asociados
- **Entrada:** num_rec=1 (asumiendo que tiene contratos)
- **Acción:** deleteRecaudadora
- **Esperado:** success=false, message='No se puede eliminar: existen contratos asociados.'

### 7. Listado de recaudadoras
- **Acción:** getRecaudadoras
- **Esperado:** success=true, data=[...], message=''


## Casos de Uso

# Casos de Uso - ABC_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Alta de Recaudadora

**Descripción:** El usuario desea agregar una nueva recaudadora al catálogo.

**Precondiciones:**
El usuario tiene acceso a la página de recaudadoras y permisos de alta.

**Pasos a seguir:**
1. El usuario hace clic en 'Agregar Recaudadora'.
2. Ingresa el número (ej: 10) y la descripción (ej: 'Recaudadora Norte').
3. Hace clic en 'Guardar'.
4. El sistema envía la petición a /api/execute con action 'insertRecaudadora'.
5. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La recaudadora aparece en la lista y se muestra el mensaje 'Recaudadora agregada correctamente.'

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Norte" }

---

## Caso de Uso 2: Edición de Recaudadora

**Descripción:** El usuario desea modificar la descripción de una recaudadora existente.

**Precondiciones:**
Existe una recaudadora con num_rec=10.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en la fila de la recaudadora 10.
2. Cambia la descripción a 'Recaudadora Norte Modificada'.
3. Hace clic en 'Actualizar'.
4. El sistema envía la petición a /api/execute con action 'updateRecaudadora'.
5. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La descripción se actualiza en la lista y se muestra el mensaje 'Recaudadora actualizada correctamente.'

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Norte Modificada" }

---

## Caso de Uso 3: Eliminación de Recaudadora sin contratos asociados

**Descripción:** El usuario desea eliminar una recaudadora que no tiene contratos asociados.

**Precondiciones:**
Existe una recaudadora con num_rec=11 y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario hace clic en 'Eliminar' en la fila de la recaudadora 11.
2. Confirma la eliminación.
3. El sistema envía la petición a /api/execute con action 'deleteRecaudadora'.
4. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La recaudadora desaparece de la lista y se muestra el mensaje 'Recaudadora eliminada correctamente.'

**Datos de prueba:**
{ "num_rec": 11 }

---



---
**Componente:** `ABC_Recaudadoras.vue`
**MÃ³dulo:** `aseo_contratado`

