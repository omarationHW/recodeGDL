-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: observacionfrm
-- Modulo: padron_licencias
-- Schema: comun
-- Generado: 2025-11-21
-- Batch: 13
-- Total SPs: 4
-- ============================================
-- Descripcion: Gestion de observaciones (notes/comments)
-- Tabla principal: observaciones (id BIGSERIAL, observacion TEXT, created_at TIMESTAMP)
-- ============================================

-- ============================================
-- CONFIGURACION DE ESQUEMA
-- ============================================
-- Schema: comun (funcionalidad compartida)
-- Tabla principal: observaciones
-- Columnas:
--   - id: BIGSERIAL (PK, auto-generado)
--   - observacion: TEXT (contenido de la observacion)
--   - created_at: TIMESTAMP (fecha de creacion)
-- ============================================

-- ============================================
-- INDICES RECOMENDADOS (ejecutar si no existen)
-- ============================================
-- CREATE INDEX IF NOT EXISTS idx_observaciones_id ON observaciones(id);
-- CREATE INDEX IF NOT EXISTS idx_observaciones_created_at ON observaciones(created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_observaciones_observacion_upper ON observaciones(UPPER(LEFT(observacion, 100)));
-- ============================================

-- ============================================
-- SP 1/4: sp_observacion_list
-- Tipo: CONSULTA
-- Descripcion: Lista todas las observaciones ordenadas por fecha DESC
-- Parametros: Ninguno
-- Retorna: Lista completa de observaciones (id, observacion, created_at)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_observacion_list()
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.observacion,
        o.created_at
    FROM observaciones o
    ORDER BY o.created_at DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al listar observaciones: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_observacion_list() IS
'Lista todas las observaciones ordenadas por fecha de creacion descendente - observacionfrm';

-- ============================================
-- SP 2/4: sp_observacion_get
-- Tipo: CONSULTA
-- Descripcion: Obtiene una observacion especifica por ID
-- Parametros:
--   p_id: ID de la observacion a consultar (BIGINT)
-- Retorna: Registro de la observacion (id, observacion, created_at)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_observacion_get(
    p_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
DECLARE
    v_observacion_existe BOOLEAN;
BEGIN
    -- Validacion: ID requerido
    IF p_id IS NULL OR p_id <= 0 THEN
        RAISE EXCEPTION 'El ID de la observacion es requerido y debe ser mayor a cero';
    END IF;

    -- Validacion: Verificar que la observacion existe
    SELECT EXISTS (
        SELECT 1 FROM observaciones WHERE observaciones.id = p_id
    ) INTO v_observacion_existe;

    IF NOT v_observacion_existe THEN
        RAISE EXCEPTION 'La observacion con ID % no existe', p_id;
    END IF;

    -- Retornar la observacion solicitada
    RETURN QUERY
    SELECT
        o.id,
        o.observacion,
        o.created_at
    FROM observaciones o
    WHERE o.id = p_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener observacion: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_observacion_get(BIGINT) IS
'Obtiene una observacion especifica por su ID con validacion de existencia - observacionfrm';

-- ============================================
-- SP 3/4: sp_observacion_save
-- Tipo: INSERCION
-- Descripcion: Crea una nueva observacion con normalizacion UPPER
-- Parametros:
--   p_observacion: Texto de la observacion (TEXT)
-- Retorna: success (BOOLEAN), message (TEXT), id (BIGINT), observacion (TEXT), created_at (TIMESTAMP)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_observacion_save(
    p_observacion TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
DECLARE
    v_new_id BIGINT;
    v_observacion_normalizada TEXT;
    v_created_at TIMESTAMP;
BEGIN
    -- Validacion: Observacion requerida
    IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
        RETURN QUERY SELECT
            FALSE,
            'El texto de la observacion es requerido'::TEXT,
            NULL::BIGINT,
            NULL::TEXT,
            NULL::TIMESTAMP;
        RETURN;
    END IF;

    -- Normalizar observacion (UPPER y TRIM)
    v_observacion_normalizada := UPPER(TRIM(p_observacion));

    -- Establecer timestamp actual
    v_created_at := NOW();

    -- Insertar la nueva observacion usando RETURNING para obtener el ID
    INSERT INTO observaciones (observacion, created_at)
    VALUES (v_observacion_normalizada, v_created_at)
    RETURNING observaciones.id INTO v_new_id;

    -- Retorno exitoso con datos del registro creado
    RETURN QUERY SELECT
        TRUE,
        'Observacion creada exitosamente'::TEXT,
        v_new_id,
        v_observacion_normalizada,
        v_created_at;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT
            FALSE,
            'Error: Ya existe una observacion con ese ID'::TEXT,
            NULL::BIGINT,
            NULL::TEXT,
            NULL::TIMESTAMP;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error al crear observacion: ' || SQLERRM)::TEXT,
            NULL::BIGINT,
            NULL::TEXT,
            NULL::TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_observacion_save(TEXT) IS
'Crea una nueva observacion con texto normalizado (UPPER) y timestamp automatico - observacionfrm';

-- ============================================
-- SP 4/4: sp_observacion_delete
-- Tipo: ELIMINACION
-- Descripcion: Elimina una observacion por ID
-- Parametros:
--   p_id: ID de la observacion a eliminar (BIGINT)
-- Retorna: success (BOOLEAN), message (TEXT), deleted_id (BIGINT), deleted_observacion (TEXT)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_observacion_delete(
    p_id BIGINT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    deleted_id BIGINT,
    deleted_observacion TEXT
) AS $$
DECLARE
    v_observacion_existe BOOLEAN;
    v_observacion_anterior TEXT;
    v_rows_affected INTEGER;
BEGIN
    -- Validacion: ID requerido
    IF p_id IS NULL OR p_id <= 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El ID de la observacion es requerido y debe ser mayor a cero'::TEXT,
            NULL::BIGINT,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Validacion: Verificar que la observacion existe
    SELECT EXISTS (
        SELECT 1 FROM observaciones WHERE observaciones.id = p_id
    ) INTO v_observacion_existe;

    IF NOT v_observacion_existe THEN
        RETURN QUERY SELECT
            FALSE,
            ('La observacion con ID ' || p_id || ' no existe')::TEXT,
            NULL::BIGINT,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Obtener la observacion antes de eliminar (para el log/retorno)
    SELECT o.observacion INTO v_observacion_anterior
    FROM observaciones o WHERE o.id = p_id;

    -- Eliminar la observacion
    DELETE FROM observaciones WHERE observaciones.id = p_id;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Retorno exitoso
    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE,
            'Observacion eliminada exitosamente'::TEXT,
            p_id,
            v_observacion_anterior;
    ELSE
        RETURN QUERY SELECT
            FALSE,
            'No se pudo eliminar la observacion'::TEXT,
            NULL::BIGINT,
            NULL::TEXT;
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN QUERY SELECT
            FALSE,
            'No se puede eliminar: la observacion esta referenciada por otros registros'::TEXT,
            NULL::BIGINT,
            NULL::TEXT;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error al eliminar observacion: ' || SQLERRM)::TEXT,
            NULL::BIGINT,
            NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_observacion_delete(BIGINT) IS
'Elimina una observacion del sistema con validacion de existencia - observacionfrm';

-- ============================================
-- ALIAS PARA COMPATIBILIDAD LEGACY
-- Creando alias con nombres usados en archivos de referencia
-- ============================================

-- Alias sp_save_observacion (nombre legacy)
CREATE OR REPLACE FUNCTION comun.sp_save_observacion(
    p_observacion TEXT
)
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
DECLARE
    v_result RECORD;
BEGIN
    -- Llamar a la funcion principal
    SELECT * INTO v_result
    FROM comun.sp_observacion_save(p_observacion);

    -- Si fue exitoso, retornar los datos
    IF v_result.success THEN
        RETURN QUERY SELECT
            v_result.id,
            v_result.observacion,
            v_result.created_at;
    ELSE
        RAISE EXCEPTION '%', v_result.message;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_save_observacion(TEXT) IS
'Alias de sp_observacion_save() para compatibilidad con codigo legacy - observacionfrm';

-- Alias sp_get_observaciones (nombre legacy)
CREATE OR REPLACE FUNCTION comun.sp_get_observaciones()
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM comun.sp_observacion_list();
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_get_observaciones() IS
'Alias de sp_observacion_list() para compatibilidad con codigo legacy - observacionfrm';

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================

-- ============================================
-- RESUMEN DE IMPLEMENTACION
-- ============================================
-- Total SPs implementados: 4 (+ 2 alias legacy)
--
-- Lista de SPs:
-- 1. sp_observacion_list   - CONSULTA     - Lista observaciones (ORDER BY created_at DESC)
-- 2. sp_observacion_get    - CONSULTA     - Obtiene observacion por ID (validacion existencia)
-- 3. sp_observacion_save   - INSERCION    - Crea nueva observacion (UPPER, RETURNING)
-- 4. sp_observacion_delete - ELIMINACION  - Elimina observacion por ID (validacion existencia)
--
-- Alias Legacy:
-- - sp_save_observacion    - Alias de sp_observacion_save
-- - sp_get_observaciones   - Alias de sp_observacion_list
--
-- Schema: comun
--
-- Tablas utilizadas:
-- - observaciones (principal)
--
-- Caracteristicas implementadas:
-- [x] Nomenclatura estandar (p_ para parametros, v_ para variables)
-- [x] Validaciones completas de parametros requeridos
-- [x] RAISE EXCEPTION descriptivos para consultas
-- [x] Retorno estructurado (success, message, data) para CRUD
-- [x] RETURNING para obtener ID del nuevo registro
-- [x] Normalizacion de entrada con UPPER(TRIM())
-- [x] Validacion de existencia para get/delete
-- [x] Manejo robusto de errores con EXCEPTION
-- [x] Comentarios descriptivos en cada funcion
-- [x] Indices recomendados documentados
-- [x] Alias para compatibilidad legacy
-- [x] Order by created_at DESC en listado
-- ============================================

-- ============================================
-- SCRIPT DE PRUEBA (comentado para referencia)
-- ============================================
-- -- Test 1: Listar todas las observaciones
-- SELECT * FROM comun.sp_observacion_list();
--
-- -- Test 2: Obtener observacion por ID
-- SELECT * FROM comun.sp_observacion_get(1);
--
-- -- Test 3: Crear nueva observacion
-- SELECT * FROM comun.sp_observacion_save('Esta es una nueva observacion de prueba');
--
-- -- Test 4: Eliminar observacion
-- SELECT * FROM comun.sp_observacion_delete(1);
--
-- -- Test 5: Usando alias legacy para listar
-- SELECT * FROM comun.sp_get_observaciones();
--
-- -- Test 6: Usando alias legacy para guardar
-- SELECT * FROM comun.sp_save_observacion('Observacion con alias legacy');
-- ============================================

-- ============================================
-- ESTRUCTURA DE TABLA REQUERIDA (referencia)
-- ============================================
/*
CREATE TABLE IF NOT EXISTS observaciones (
    id BIGSERIAL PRIMARY KEY,
    observacion TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indices recomendados
CREATE INDEX IF NOT EXISTS idx_observaciones_created_at ON observaciones(created_at DESC);
*/
-- ============================================

-- ============================================
-- INTEGRACION CON LARAVEL API
-- ============================================
/*
Endpoints del controlador Laravel:
----------------------------------
1. GET /api/execute (eRequest: "sp_observacion_list")
   - Lista todas las observaciones

2. GET /api/execute (eRequest: "sp_observacion_get", params: {id: 1})
   - Obtiene observacion por ID

3. POST /api/execute (eRequest: "sp_observacion_save", params: {observacion: "texto"})
   - Crea nueva observacion

4. DELETE /api/execute (eRequest: "sp_observacion_delete", params: {id: 1})
   - Elimina observacion

Uso en Vue.js:
--------------
// Listar observaciones
axios.post('/api/execute', {
  eRequest: 'sp_observacion_list'
})

// Guardar observacion
axios.post('/api/execute', {
  eRequest: 'sp_observacion_save',
  params: { observacion: 'Nueva observacion' }
})

// Eliminar observacion
axios.post('/api/execute', {
  eRequest: 'sp_observacion_delete',
  params: { id: 1 }
})
*/
-- ============================================

-- ============================================
-- FIN DE ARCHIVO - OBSERVACIONFRM
-- Total funciones: 6 (4 principales + 2 alias)
-- Schema: comun
-- Tabla principal: observaciones
-- ============================================
