# Reporte de Actualización: ABC_Recaudadoras.vue

**Fecha:** 2025-11-26
**Módulo:** aseo_contratado
**Componente:** ABC_Recaudadoras.vue
**Tipo de Cambio:** Actualización de llamadas a Stored Procedures

---

## Resumen Ejecutivo

Se actualizó el componente Vue `ABC_Recaudadoras.vue` para utilizar los nombres correctos de los stored procedures en minúsculas, siguiendo la convención de nomenclatura de PostgreSQL. Además, se crearon dos nuevos stored procedures necesarios para el funcionamiento completo del módulo.

---

## Cambios Realizados

### 1. Archivo Vue Actualizado

**Archivo:** `RefactorX/FrontEnd/src/views/modules/aseo_contratado/ABC_Recaudadoras.vue`

#### Cambios en las Llamadas a Stored Procedures:

| Operación | SP Anterior (Incorrecto) | SP Actualizado (Correcto) |
|-----------|--------------------------|---------------------------|
| Listar | `SP_ASEO_RECAUDADORAS_LIST` | `sp_list_recaudadoras` |
| Crear | `SP_ASEO_RECAUDADORAS_CREATE` | `sp_insert_recaudadora` |
| Actualizar | `SP_ASEO_RECAUDADORAS_UPDATE` | `sp_update_recaudadora` |
| Eliminar | `SP_ASEO_RECAUDADORAS_DELETE` | `sp_delete_recaudadora` |
| Obtener Siguiente Número | N/A (nuevo) | `sp_get_next_num_recaudadora` |

#### Cambios Específicos:

##### 1. Método `loadRecaudadoras()`
**ANTES:**
```javascript
const response = await execute(
  'SP_ASEO_RECAUDADORAS_LIST',
  'aseo_contratado',
  {
    p_page: currentPage.value,
    p_limit: itemsPerPage.value,
    p_search: searchQuery.value || null
  }
)
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_list_recaudadoras',
  'aseo_contratado',
  {
    p_search: searchQuery.value || null
  }
)
```

**Cambios:**
- Nombre del SP en minúsculas
- Eliminados parámetros de paginación (p_page, p_limit) ya que el SP retorna todos los registros
- La paginación se maneja ahora en el frontend

##### 2. Método `createRecaudadora()`
**ANTES:**
```javascript
const response = await execute(
  'SP_ASEO_RECAUDADORAS_CREATE',
  'aseo_contratado',
  {
    p_descripcion: formData.value.descripcion.trim()
  }
)
```

**DESPUÉS:**
```javascript
// Primero obtener el siguiente número de recaudadora
const nextNumResponse = await execute(
  'sp_get_next_num_recaudadora',
  'aseo_contratado',
  {}
)

const nextNum = nextNumResponse.data[0].next_num

// Ahora crear la recaudadora
const response = await execute(
  'sp_insert_recaudadora',
  'aseo_contratado',
  {
    p_num_rec: nextNum,
    p_descripcion: formData.value.descripcion.trim()
  }
)
```

**Cambios:**
- Nombre del SP en minúsculas: `sp_insert_recaudadora`
- Agregada llamada previa a `sp_get_next_num_recaudadora` para obtener el siguiente número disponible
- Agregado parámetro `p_num_rec` requerido por el SP

##### 3. Método `updateRecaudadora()`
**ANTES:**
```javascript
const response = await execute(
  'SP_ASEO_RECAUDADORAS_UPDATE',
  'aseo_contratado',
  {
    p_num_rec: formData.value.num_rec,
    p_descripcion: formData.value.descripcion.trim()
  }
)
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_update_recaudadora',
  'aseo_contratado',
  {
    p_num_rec: formData.value.num_rec,
    p_descripcion: formData.value.descripcion.trim()
  }
)
```

**Cambios:**
- Nombre del SP en minúsculas: `sp_update_recaudadora`
- Parámetros sin cambios

##### 4. Método `deleteRecaudadora()`
**ANTES:**
```javascript
const response = await execute(
  'SP_ASEO_RECAUDADORAS_DELETE',
  'aseo_contratado',
  {
    p_num_rec: num_rec
  }
)
```

**DESPUÉS:**
```javascript
const response = await execute(
  'sp_delete_recaudadora',
  'aseo_contratado',
  {
    p_num_rec: num_rec
  }
)
```

**Cambios:**
- Nombre del SP en minúsculas: `sp_delete_recaudadora`
- Parámetros sin cambios

---

### 2. Stored Procedures Creados

Se crearon dos nuevos stored procedures necesarios para el funcionamiento del módulo:

#### SP 1: `sp_list_recaudadoras`

**Archivo:** `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_sp_list_recaudadoras.sql`

**Descripción:** Lista todas las recaudadoras con búsqueda opcional por descripción o número.

**Firma:**
```sql
CREATE OR REPLACE FUNCTION sp_list_recaudadoras(p_search VARCHAR DEFAULT NULL)
RETURNS TABLE(
    num_rec SMALLINT,
    descripcion VARCHAR
)
```

**Parámetros:**
- `p_search` (VARCHAR, opcional): Filtro de búsqueda que se aplica a descripción y número

**Funcionalidad:**
- Si `p_search` es NULL, retorna todas las recaudadoras
- Si `p_search` tiene valor, busca coincidencias en descripción (ILIKE) o número
- Ordena resultados por `num_rec` ascendente

#### SP 2: `sp_get_next_num_recaudadora`

**Archivo:** `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_sp_get_next_num_recaudadora.sql`

**Descripción:** Obtiene el siguiente número disponible para una nueva recaudadora.

**Firma:**
```sql
CREATE OR REPLACE FUNCTION sp_get_next_num_recaudadora()
RETURNS TABLE(next_num SMALLINT)
```

**Parámetros:** Ninguno

**Funcionalidad:**
- Retorna el valor máximo de `num_rec` + 1
- Si no hay registros, retorna 1

---

### 3. Archivos de Base de Datos Actualizados

#### Archivo Consolidado Actualizado:
**Archivo:** `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_all_procedures.sql`

**Cambios:**
- Actualizado de 3 SPs a 5 SPs
- Agregados: `sp_list_recaudadoras` y `sp_get_next_num_recaudadora`
- Actualizada la numeración de los SPs existentes

#### Archivo de Deploy Creado:
**Archivo:** `RefactorX/Base/aseo_contratado/database/deploy/DEPLOY_ABC_RECAUDADORAS_COMPLETO.sql`

**Contenido:**
- Script completo de deployment para PostgreSQL
- Incluye todos los 5 stored procedures
- Mensajes informativos de progreso con `\echo`
- Listo para ejecutar en la base de datos

---

## Stored Procedures Disponibles

### Resumen de SPs del Módulo ABC_Recaudadoras:

| # | Nombre del SP | Tipo | Parámetros | Descripción |
|---|---------------|------|------------|-------------|
| 1 | `sp_list_recaudadoras` | CONSULTA | p_search VARCHAR | Lista recaudadoras con búsqueda opcional |
| 2 | `sp_get_next_num_recaudadora` | UTILIDAD | ninguno | Obtiene el siguiente número disponible |
| 3 | `sp_insert_recaudadora` | CRUD | p_num_rec, p_descripcion | Inserta nueva recaudadora |
| 4 | `sp_update_recaudadora` | CRUD | p_num_rec, p_descripcion | Actualiza recaudadora existente |
| 5 | `sp_delete_recaudadora` | CRUD | p_num_rec | Elimina recaudadora (si no tiene contratos) |

---

## Validaciones Implementadas

### En los Stored Procedures:

1. **sp_insert_recaudadora:**
   - Verifica que no exista ya una recaudadora con el mismo número
   - Retorna mensaje de error si existe

2. **sp_update_recaudadora:**
   - Verifica que la recaudadora exista antes de actualizar
   - Retorna mensaje de error si no existe

3. **sp_delete_recaudadora:**
   - Verifica que no existan contratos asociados antes de eliminar
   - Retorna mensaje de error si hay contratos asociados
   - Verifica que la recaudadora exista

### En el Componente Vue:

1. **Validación de campo requerido:**
   - La descripción no puede estar vacía
   - Se valida antes de enviar al servidor

2. **Confirmación de eliminación:**
   - Se muestra modal de confirmación con SweetAlert2
   - Muestra el nombre de la recaudadora a eliminar

---

## Archivos Modificados/Creados

### Archivos Modificados:
1. `RefactorX/FrontEnd/src/views/modules/aseo_contratado/ABC_Recaudadoras.vue`
2. `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_all_procedures.sql`

### Archivos Creados:
1. `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_sp_list_recaudadoras.sql`
2. `RefactorX/Base/aseo_contratado/database/database/ABC_Recaudadoras_sp_get_next_num_recaudadora.sql`
3. `RefactorX/Base/aseo_contratado/database/deploy/DEPLOY_ABC_RECAUDADORAS_COMPLETO.sql`
4. `RefactorX/Base/aseo_contratado/docs/REPORTE_ACTUALIZACION_ABC_RECAUDADORAS_2025-11-26.md` (este archivo)

---

## Instrucciones de Despliegue

### 1. Desplegar Stored Procedures en la Base de Datos:

```bash
# Conectar a la base de datos
psql -U postgres -d guadalajara_db

# Ejecutar el script de deploy
\i RefactorX/Base/aseo_contratado/database/deploy/DEPLOY_ABC_RECAUDADORAS_COMPLETO.sql
```

### 2. Verificar la Instalación:

```sql
-- Verificar que los SPs existan
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%recaudadora%'
ORDER BY routine_name;

-- Debería retornar:
-- sp_delete_recaudadora
-- sp_get_next_num_recaudadora
-- sp_insert_recaudadora
-- sp_list_recaudadoras
-- sp_update_recaudadora
```

### 3. Probar la Funcionalidad:

```sql
-- Listar recaudadoras
SELECT * FROM sp_list_recaudadoras(NULL);

-- Obtener siguiente número
SELECT * FROM sp_get_next_num_recaudadora();

-- Insertar recaudadora de prueba
SELECT * FROM sp_insert_recaudadora(999, 'Recaudadora de Prueba');

-- Actualizar
SELECT * FROM sp_update_recaudadora(999, 'Recaudadora Actualizada');

-- Eliminar
SELECT * FROM sp_delete_recaudadora(999);
```

---

## Próximos Pasos Recomendados

1. **Testing:**
   - Probar el módulo completo en el frontend
   - Verificar crear, editar, eliminar y buscar recaudadoras
   - Validar mensajes de error y éxito

2. **Documentación:**
   - Actualizar manual de usuario si existe
   - Documentar casos de uso especiales

3. **Optimización:**
   - Considerar agregar índices si la tabla crece mucho
   - Evaluar si se necesita paginación en el backend

4. **Seguridad:**
   - Verificar permisos de ejecución de los SPs
   - Validar que solo usuarios autorizados puedan modificar el catálogo

---

## Notas Técnicas

### Diferencias con el Enfoque Anterior:

1. **Paginación:**
   - **Antes:** Paginación en el backend (p_page, p_limit)
   - **Ahora:** Paginación en el frontend (todos los registros se cargan)
   - **Razón:** Simplifica el SP y para catálogos pequeños es más eficiente

2. **Auto-incremento del Número:**
   - **Antes:** No estaba claro cómo se generaba el número
   - **Ahora:** Se usa `sp_get_next_num_recaudadora()` explícitamente
   - **Razón:** Mayor control y transparencia en la asignación de números

3. **Nombres de SPs:**
   - **Antes:** MAYÚSCULAS con prefijo extenso (SP_ASEO_RECAUDADORAS_*)
   - **Ahora:** minúsculas con prefijo simple (sp_*)
   - **Razón:** Convención de PostgreSQL y mejor legibilidad

---

## Conclusiones

La actualización se completó exitosamente. El módulo ABC_Recaudadoras ahora utiliza los stored procedures correctos con nombres en minúsculas y tiene toda la funcionalidad necesaria implementada:

- ✅ Listar recaudadoras con búsqueda
- ✅ Crear nuevas recaudadoras con auto-incremento
- ✅ Actualizar recaudadoras existentes
- ✅ Eliminar recaudadoras (con validación de contratos)
- ✅ Manejo de errores apropiado
- ✅ Mensajes de usuario claros

El código está listo para despliegue y pruebas.

---

**Elaborado por:** Claude Code (Anthropic)
**Fecha:** 2025-11-26
**Versión:** 1.0
