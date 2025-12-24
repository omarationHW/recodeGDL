# DocumentaciÃ³n TÃ©cnica: ABC_Cves_Operacion

## AnÃ¡lisis TÃ©cnico

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


## Casos de Prueba

## Casos de Prueba para Catálogo Claves de Operación

### 1. Alta exitosa de clave
- **Entrada:**
  - action: insert
  - data: { "cve_operacion": "Z", "descripcion": "Prueba Z" }
- **Esperado:**
  - success: true
  - message: 'Clave de operación creada correctamente'
  - data: contiene la nueva clave

### 2. Alta duplicada
- **Entrada:**
  - action: insert
  - data: { "cve_operacion": "A", "descripcion": "Duplicada" }
- **Esperado:**
  - success: false
  - message: 'Ya existe una clave con ese valor'

### 3. Eliminación con pagos asociados
- **Entrada:**
  - action: delete
  - data: { "ctrol_operacion": 1 }
- **Esperado:**
  - success: false
  - message: 'No se puede eliminar: existen pagos asociados a esta clave.'

### 4. Eliminación exitosa
- **Entrada:**
  - action: delete
  - data: { "ctrol_operacion": 99 }
- **Esperado:**
  - success: true
  - message: 'Clave de operación eliminada correctamente'

### 5. Edición exitosa
- **Entrada:**
  - action: update
  - data: { "ctrol_operacion": 2, "cve_operacion": "B", "descripcion": "Editada" }
- **Esperado:**
  - success: true
  - message: 'Clave de operación actualizada correctamente'

### 6. Consulta de lista
- **Entrada:**
  - action: list
  - data: {}
- **Esperado:**
  - success: true
  - data: lista de claves


## Casos de Uso

# Casos de Uso - ABC_Cves_Operacion

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de operación

**Descripción:** El usuario desea agregar una nueva clave de operación al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Claves de Operación.
2. Hace clic en 'Agregar Clave'.
3. Llena el formulario con clave 'X' y descripción 'Operación de prueba'.
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "cve_operacion": "X", "descripcion": "Operación de prueba" }

---

## Caso de Uso 2: Intento de eliminar clave con pagos asociados

**Descripción:** El usuario intenta eliminar una clave de operación que ya está referenciada en pagos.

**Precondiciones:**
Existe una clave de operación con pagos asociados.

**Pasos a seguir:**
1. El usuario localiza la clave en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un error: 'No se puede eliminar: existen pagos asociados a esta clave.'

**Datos de prueba:**
{ "ctrol_operacion": 1 }

---

## Caso de Uso 3: Edición de descripción de clave de operación

**Descripción:** El usuario edita la descripción de una clave existente.

**Precondiciones:**
Existe una clave de operación válida.

**Pasos a seguir:**
1. El usuario localiza la clave en la lista.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Nueva descripción'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "ctrol_operacion": 2, "cve_operacion": "A", "descripcion": "Nueva descripción" }

---



---
**Componente:** `ABC_Cves_Operacion.vue`
**MÃ³dulo:** `aseo_contratado`

