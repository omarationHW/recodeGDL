-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TIPOBLOQUEOFRM
-- Descripción: Catálogo de tipos de bloqueo para licencias/anuncios/trámites
-- Generado: 2025-11-21
-- Total SPs: 4
-- Schema: comun
-- ============================================

-- ============================================
-- TABLA: c_tipobloqueo
-- Crear tabla si no existe
-- ============================================

CREATE TABLE IF NOT EXISTS comun.c_tipobloqueo (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(200) NOT NULL,
    sel_cons CHAR(1) DEFAULT 'S',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Crear índice para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_tipobloqueo_sel_cons ON comun.c_tipobloqueo(sel_cons);

-- ============================================

-- SP 1/4: sp_tipo_bloqueo_list
-- Tipo: SELECT/LIST
-- Descripción: Lista todos los tipos de bloqueo. Si p_solo_activos=TRUE, filtra por sel_cons='S'
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_tipo_bloqueo_list(
    p_solo_activos BOOLEAN DEFAULT TRUE
)
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR(200),
    sel_cons CHAR(1),
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons,
        (t.sel_cons = 'S')::BOOLEAN AS activo
    FROM comun.c_tipobloqueo t
    WHERE (NOT p_solo_activos OR t.sel_cons = 'S')
    ORDER BY t.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_tipo_bloqueo_list(BOOLEAN) IS 'Lista tipos de bloqueo. Si p_solo_activos=TRUE solo muestra activos (sel_cons=S)';

-- ============================================

-- SP 2/4: sp_tipo_bloqueo_get
-- Tipo: SELECT/GET
-- Descripción: Obtiene un tipo de bloqueo por su ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_tipo_bloqueo_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR(200),
    sel_cons CHAR(1),
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons,
        t.created_at
    FROM comun.c_tipobloqueo t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_tipo_bloqueo_get(INTEGER) IS 'Obtiene un tipo de bloqueo por su ID';

-- ============================================

-- SP 3/4: sp_tipo_bloqueo_create
-- Tipo: INSERT/CREATE
-- Descripción: Crea un nuevo tipo de bloqueo. Valida descripción no vacía y no duplicada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_tipo_bloqueo_create(
    p_descripcion VARCHAR(200),
    p_sel_cons CHAR(1) DEFAULT 'S'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    v_id INTEGER;
    v_descripcion_trim VARCHAR(200);
    v_existe INTEGER;
BEGIN
    -- Limpiar espacios en blanco
    v_descripcion_trim := TRIM(p_descripcion);

    -- Validar que la descripción no esté vacía
    IF v_descripcion_trim IS NULL OR v_descripcion_trim = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida y no puede estar vacía'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que la descripción no exista ya
    SELECT COUNT(*) INTO v_existe
    FROM comun.c_tipobloqueo
    WHERE UPPER(TRIM(descripcion)) = UPPER(v_descripcion_trim);

    IF v_existe > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un tipo de bloqueo con esa descripción'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar sel_cons
    IF p_sel_cons NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT FALSE, 'El valor de sel_cons debe ser S o N'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo registro
    INSERT INTO comun.c_tipobloqueo (descripcion, sel_cons, created_at)
    VALUES (v_descripcion_trim, COALESCE(p_sel_cons, 'S'), NOW())
    RETURNING comun.c_tipobloqueo.id INTO v_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo creado exitosamente'::TEXT, v_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear tipo de bloqueo: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_tipo_bloqueo_create(VARCHAR, CHAR) IS 'Crea un nuevo tipo de bloqueo validando descripción única y no vacía';

-- ============================================

-- SP 4/4: sp_tipo_bloqueo_update
-- Tipo: UPDATE
-- Descripción: Actualiza un tipo de bloqueo existente. Valida que el tipo exista.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_tipo_bloqueo_update(
    p_id INTEGER,
    p_descripcion VARCHAR(200),
    p_sel_cons CHAR(1)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_existe INTEGER;
    v_descripcion_trim VARCHAR(200);
    v_duplicado INTEGER;
BEGIN
    -- Validar que el ID no sea nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validar que el tipo de bloqueo exista
    SELECT COUNT(*) INTO v_existe
    FROM comun.c_tipobloqueo
    WHERE id = p_id;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe un tipo de bloqueo con el ID especificado'::TEXT;
        RETURN;
    END IF;

    -- Limpiar espacios en blanco
    v_descripcion_trim := TRIM(p_descripcion);

    -- Validar que la descripción no esté vacía
    IF v_descripcion_trim IS NULL OR v_descripcion_trim = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida y no puede estar vacía'::TEXT;
        RETURN;
    END IF;

    -- Validar que la descripción no esté duplicada (excluyendo el registro actual)
    SELECT COUNT(*) INTO v_duplicado
    FROM comun.c_tipobloqueo
    WHERE UPPER(TRIM(descripcion)) = UPPER(v_descripcion_trim)
      AND id != p_id;

    IF v_duplicado > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe otro tipo de bloqueo con esa descripción'::TEXT;
        RETURN;
    END IF;

    -- Validar sel_cons
    IF p_sel_cons NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT FALSE, 'El valor de sel_cons debe ser S o N'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el registro
    UPDATE comun.c_tipobloqueo
    SET descripcion = v_descripcion_trim,
        sel_cons = p_sel_cons
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo actualizado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar tipo de bloqueo: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_tipo_bloqueo_update(INTEGER, VARCHAR, CHAR) IS 'Actualiza un tipo de bloqueo existente validando que exista y descripción única';

-- ============================================
-- FIN DE STORED PROCEDURES TIPOBLOQUEOFRM
-- ============================================

-- ============================================
-- EJEMPLOS DE USO
-- ============================================
/*
-- Listar todos los tipos de bloqueo activos:
SELECT * FROM comun.sp_tipo_bloqueo_list(TRUE);

-- Listar todos los tipos de bloqueo (activos e inactivos):
SELECT * FROM comun.sp_tipo_bloqueo_list(FALSE);

-- Obtener un tipo de bloqueo por ID:
SELECT * FROM comun.sp_tipo_bloqueo_get(1);

-- Crear un nuevo tipo de bloqueo:
SELECT * FROM comun.sp_tipo_bloqueo_create('Bloqueo por adeudo fiscal', 'S');

-- Actualizar un tipo de bloqueo:
SELECT * FROM comun.sp_tipo_bloqueo_update(1, 'Bloqueo por adeudo fiscal actualizado', 'S');

-- Desactivar un tipo de bloqueo (soft delete):
SELECT * FROM comun.sp_tipo_bloqueo_update(1, 'Bloqueo por adeudo fiscal', 'N');
*/
