# DOCTOSFRM - Gestión de Documentos de Trámites

## Descripción General

El componente **doctosfrm** gestiona los documentos requeridos para los trámites de licencias en el módulo de padrón de licencias. Permite catalogar, registrar y administrar la documentación asociada a cada trámite mediante un sistema de selección múltiple y campos de observaciones.

## Información Técnica

- **Módulo**: padron_licencias
- **Schema**: public
- **Base de Datos**: padron_licencias
- **Total SPs**: 5
- **Fecha Implementación**: 2025-11-20
- **Lenguaje**: PL/pgSQL

## Archivos del Componente

1. **DOCTOSFRM_all_procedures_IMPLEMENTED.sql** - Stored procedures implementados
2. **DOCTOSFRM_table_definition.sql** - Definición de tabla auxiliar
3. **DOCTOSFRM_test_procedures.sql** - Suite de pruebas
4. **DOCTOSFRM_README.md** - Esta documentación

## Tabla Principal

### doctosfrm_tramite

Tabla auxiliar para almacenar los documentos asociados a cada trámite.

```sql
CREATE TABLE public.doctosfrm_tramite (
    id SERIAL PRIMARY KEY,
    tramite_id INTEGER NOT NULL UNIQUE,
    documentos TEXT[] DEFAULT ARRAY[]::TEXT[],
    otro TEXT,
    fecalt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecmod TIMESTAMP,
    capturo INTEGER,
    modifico INTEGER
);
```

**Campos:**
- `id`: Identificador único del registro
- `tramite_id`: ID del trámite asociado (único)
- `documentos`: Array de códigos de documentos seleccionados
- `otro`: Campo de texto libre para observaciones
- `fecalt`: Fecha de creación
- `fecmod`: Fecha de modificación (actualizada automáticamente)
- `capturo`: ID del usuario que capturó
- `modifico`: ID del usuario que modificó

## Stored Procedures

### 1. sp_doctosfrm_catalog()

Retorna el catálogo completo de tipos de documentos disponibles.

**Tipo**: Catálogo (STABLE)

**Parámetros**: Ninguno

**Retorna**:
```sql
TABLE(codigo TEXT, descripcion TEXT)
```

**Uso**:
```sql
SELECT * FROM sp_doctosfrm_catalog();
```

**Ejemplo de Resultado**:
```
codigo              | descripcion
--------------------+------------------------------------------
fotofachada         | Fotografías de la fachada
recibopredial       | Recibo de predial
ident_titular       | Identificación del titular
...
```

**Documentos del Catálogo** (19 tipos):
1. fotofachada - Fotografías de la fachada
2. recibopredial - Recibo de predial
3. ident_titular - Identificación del titular
4. ident_dueno_finca - Identificación del dueño de la finca
5. ident_r1 - Identificación R1 (alta de Hacienda)
6. contrato_arrend - Contrato de arrendamiento
7. solic_lic_usosuelo - Solicitud de licencia y uso de suelo
8. solic_mod_padron - Solicitud de modificación al padrón y uso de suelo
9. licencia_vigente - Licencia original vigente
10. carta_policia - Carta de policía
11. carta_poder - Carta de poder simple
12. memoria_calculo - Memoria de cálculo
13. poliza_responsabilidad - Póliza vigente de responsabilidad civil del anuncio
14. acta_constitutiva - Acta constitutiva
15. poder_notarial - Poder notarial
16. asignacion_numeros - Asignación de números oficiales
17. copia_licencia - Copia de licencia
18. solic_lic_anuncio - Solicitud de licencia de anuncio
19. solic_dictamen_anuncio - Solicitud de dictamen de anuncio

---

### 2. sp_doctosfrm_get(p_tramite_id)

Obtiene los documentos registrados para un trámite específico.

**Tipo**: Consulta (STABLE)

**Parámetros**:
- `p_tramite_id` INTEGER - ID del trámite (obligatorio, > 0)

**Retorna**:
```sql
TABLE(documentos TEXT[], otro TEXT)
```

**Validaciones**:
- p_tramite_id no puede ser NULL
- p_tramite_id debe ser mayor a 0
- Si no existe el trámite, retorna array vacío

**Uso**:
```sql
SELECT * FROM sp_doctosfrm_get(123);
```

**Ejemplo de Resultado**:
```
documentos                                    | otro
----------------------------------------------+-------------------------
{fotofachada,recibopredial,ident_titular}    | Documentos completos
```

---

### 3. sp_doctosfrm_save(p_tramite_id, p_documentos, p_otro)

Guarda o actualiza los documentos de un trámite (UPSERT).

**Tipo**: CRUD (Create/Update)

**Parámetros**:
- `p_tramite_id` INTEGER - ID del trámite (obligatorio, > 0)
- `p_documentos` JSON - Array de códigos de documentos (opcional, default: [])
- `p_otro` TEXT - Observaciones adicionales (opcional, default: NULL)

**Retorna**:
```sql
TABLE(success BOOLEAN, message TEXT)
```

**Validaciones**:
- p_tramite_id no puede ser NULL
- p_tramite_id debe ser mayor a 0
- p_documentos debe ser JSON válido
- Realiza INSERT si no existe, UPDATE si ya existe

**Uso**:
```sql
-- Crear nuevo registro
SELECT * FROM sp_doctosfrm_save(
    123,
    '["fotofachada", "recibopredial"]'::json,
    'Documentos iniciales'
);

-- Actualizar registro existente
SELECT * FROM sp_doctosfrm_save(
    123,
    '["fotofachada", "recibopredial", "ident_titular"]'::json,
    'Se agregó identificación'
);

-- Guardar sin documentos (solo observaciones)
SELECT * FROM sp_doctosfrm_save(123, NULL, 'Pendiente de entregar');
```

**Ejemplo de Resultado**:
```
success | message
--------+----------------------------------
true    | Documentos guardados correctamente
```

---

### 4. sp_doctosfrm_clear(p_tramite_id)

Limpia la selección de documentos de un trámite.

**Tipo**: CRUD (Update)

**Parámetros**:
- `p_tramite_id` INTEGER - ID del trámite (obligatorio, > 0)

**Retorna**:
```sql
TABLE(success BOOLEAN, message TEXT)
```

**Validaciones**:
- p_tramite_id no puede ser NULL
- p_tramite_id debe ser mayor a 0
- El trámite debe existir en la tabla

**Uso**:
```sql
SELECT * FROM sp_doctosfrm_clear(123);
```

**Resultado**:
- Establece documentos = [] (array vacío)
- Establece otro = NULL
- Actualiza fecmod

**Ejemplo de Resultado**:
```
success | message
--------+-------------------------------------------
true    | Selección de documentos limpiada correctamente
```

---

### 5. sp_doctosfrm_delete(p_tramite_id, p_documento)

Elimina un documento específico de la selección de un trámite.

**Tipo**: CRUD (Update)

**Parámetros**:
- `p_tramite_id` INTEGER - ID del trámite (obligatorio, > 0)
- `p_documento` TEXT - Código del documento a eliminar (obligatorio)

**Retorna**:
```sql
TABLE(success BOOLEAN, message TEXT)
```

**Validaciones**:
- p_tramite_id no puede ser NULL
- p_tramite_id debe ser mayor a 0
- p_documento no puede ser NULL o vacío
- El trámite debe existir
- El documento debe estar en la lista

**Uso**:
```sql
SELECT * FROM sp_doctosfrm_delete(123, 'recibopredial');
```

**Resultado**:
- Elimina el código del documento del array
- Mantiene los demás documentos
- Actualiza fecmod

**Ejemplo de Resultado**:
```
success | message
--------+-----------------------------------------------
true    | Documento eliminado correctamente de la selección
```

## Instalación

### 1. Crear la tabla

```bash
psql -U usuario -d padron_licencias -f DOCTOSFRM_table_definition.sql
```

### 2. Crear los stored procedures

```bash
psql -U usuario -d padron_licencias -f DOCTOSFRM_all_procedures_IMPLEMENTED.sql
```

### 3. Ejecutar pruebas (opcional)

```bash
psql -U usuario -d padron_licencias -f DOCTOSFRM_test_procedures.sql
```

## Ejemplos de Uso Completo

### Caso de Uso 1: Flujo completo de registro

```sql
-- 1. Obtener catálogo de documentos disponibles
SELECT * FROM sp_doctosfrm_catalog();

-- 2. Guardar documentos iniciales del trámite
SELECT * FROM sp_doctosfrm_save(
    1001,
    '["fotofachada", "recibopredial", "ident_titular"]'::json,
    'Documentos entregados en ventanilla'
);

-- 3. Consultar documentos guardados
SELECT * FROM sp_doctosfrm_get(1001);

-- 4. Agregar más documentos (actualizar)
SELECT * FROM sp_doctosfrm_save(
    1001,
    '["fotofachada", "recibopredial", "ident_titular", "licencia_vigente"]'::json,
    'Se agregó licencia vigente'
);

-- 5. Eliminar un documento específico
SELECT * FROM sp_doctosfrm_delete(1001, 'recibopredial');

-- 6. Consultar resultado final
SELECT * FROM sp_doctosfrm_get(1001);
```

### Caso de Uso 2: Validar documentos completos

```sql
-- Consultar trámites con documentación incompleta
SELECT
    t.tramite_id,
    t.documentos,
    array_length(t.documentos, 1) AS num_docs,
    CASE
        WHEN array_length(t.documentos, 1) < 3 THEN 'INCOMPLETO'
        ELSE 'COMPLETO'
    END AS estado_docs
FROM doctosfrm_tramite t
WHERE t.tramite_id IN (SELECT id FROM tramites WHERE estatus = 'EN_PROCESO');
```

### Caso de Uso 3: Limpiar selección

```sql
-- Limpiar todos los documentos de un trámite
SELECT * FROM sp_doctosfrm_clear(1001);

-- Verificar limpieza
SELECT * FROM sp_doctosfrm_get(1001);
-- Resultado: {}, NULL
```

## Integración con Frontend

### JavaScript/Vue.js Example

```javascript
// 1. Obtener catálogo
async function getDocumentsCatalog() {
  const result = await api.query('SELECT * FROM sp_doctosfrm_catalog()');
  return result.rows;
}

// 2. Guardar documentos seleccionados
async function saveDocuments(tramiteId, selectedDocs, observations) {
  const query = `
    SELECT * FROM sp_doctosfrm_save(
      ${tramiteId},
      '${JSON.stringify(selectedDocs)}'::json,
      '${observations}'
    )
  `;
  const result = await api.query(query);
  return result.rows[0];
}

// 3. Cargar documentos del trámite
async function loadDocuments(tramiteId) {
  const result = await api.query(
    `SELECT * FROM sp_doctosfrm_get(${tramiteId})`
  );
  return result.rows[0];
}

// 4. Eliminar documento
async function removeDocument(tramiteId, docCode) {
  const result = await api.query(
    `SELECT * FROM sp_doctosfrm_delete(${tramiteId}, '${docCode}')`
  );
  return result.rows[0];
}

// 5. Limpiar selección
async function clearDocuments(tramiteId) {
  const result = await api.query(
    `SELECT * FROM sp_doctosfrm_clear(${tramiteId})`
  );
  return result.rows[0];
}
```

### PHP Example

```php
// 1. Obtener catálogo
function getDocumentsCatalog($db) {
    $result = pg_query($db, "SELECT * FROM sp_doctosfrm_catalog()");
    return pg_fetch_all($result);
}

// 2. Guardar documentos
function saveDocuments($db, $tramiteId, $documents, $observations) {
    $docsJson = json_encode($documents);
    $query = "SELECT * FROM sp_doctosfrm_save($1, $2::json, $3)";
    $result = pg_query_params($db, $query, [
        $tramiteId,
        $docsJson,
        $observations
    ]);
    return pg_fetch_assoc($result);
}

// 3. Obtener documentos
function getDocuments($db, $tramiteId) {
    $query = "SELECT * FROM sp_doctosfrm_get($1)";
    $result = pg_query_params($db, $query, [$tramiteId]);
    return pg_fetch_assoc($result);
}
```

## Mantenimiento

### Agregar nuevos tipos de documentos

Para agregar un nuevo tipo de documento al catálogo:

1. Editar el SP `sp_doctosfrm_catalog()`
2. Agregar una nueva fila en el RETURN QUERY VALUES
3. Recrear el SP

```sql
CREATE OR REPLACE FUNCTION public.sp_doctosfrm_catalog()
RETURNS TABLE(codigo TEXT, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY VALUES
        -- ... documentos existentes ...
        ('nuevo_documento'::TEXT, 'Descripción del nuevo documento'::TEXT);
END;
$$ LANGUAGE plpgsql STABLE;
```

### Monitoreo

```sql
-- Estadísticas de uso
SELECT
    COUNT(*) AS total_tramites_con_docs,
    AVG(array_length(documentos, 1)) AS promedio_docs_por_tramite,
    MAX(array_length(documentos, 1)) AS max_docs_tramite,
    COUNT(CASE WHEN otro IS NOT NULL THEN 1 END) AS tramites_con_observaciones
FROM doctosfrm_tramite;

-- Documentos más utilizados
SELECT
    unnest(documentos) AS codigo_documento,
    COUNT(*) AS veces_usado
FROM doctosfrm_tramite
GROUP BY codigo_documento
ORDER BY veces_usado DESC;
```

## Notas Técnicas

### Características Implementadas

- ✅ Uso de FUNCTIONS (no PROCEDURES)
- ✅ Schema público especificado
- ✅ Nomenclatura con prefijos (p_, v_)
- ✅ Validaciones de parámetros completas
- ✅ Manejo de excepciones con RAISE EXCEPTION
- ✅ RETURNS TABLE en todos los SPs
- ✅ Comentarios COMMENT ON para documentación
- ✅ UPSERT automático en sp_save
- ✅ Actualización automática de fecmod con trigger
- ✅ Índices optimizados (GIN para arrays)

### Consideraciones

1. **Arrays en PostgreSQL**: Se usa TEXT[] para almacenar múltiples documentos
2. **JSON Input**: El parámetro p_documentos acepta JSON array para fácil integración
3. **STABLE vs VOLATILE**: Los SP de consulta usan STABLE, los de escritura VOLATILE (default)
4. **Triggers**: El trigger actualiza fecmod automáticamente en cada UPDATE
5. **Índice GIN**: Permite búsquedas rápidas dentro del array de documentos

## Soporte

Para reportar problemas o sugerencias relacionadas con este componente, contactar al equipo de desarrollo de RefactorX.

---

**Última actualización**: 2025-11-20
**Versión**: 1.0.0
**Autor**: Claude Code - RefactorX Team
