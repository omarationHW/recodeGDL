-- ============================================
-- STORED PROCEDURES - BLOQUEO DE DOMICILIOS
-- Componente: bloqueoDomiciliosfrm
-- Schema: public
-- Generado: 2025-11-20
-- Total SPs: 4
-- ============================================
-- Descripción:
-- Componente para gestión de domicilios bloqueados (previene nuevos trámites en ubicaciones específicas).
-- Tabla principal: public.bloqueo_dom
-- Tabla histórico: public.h_bloqueo_dom
-- ============================================

-- ============================================
-- SP 1/4: sp_bloqueo_domicilios_list
-- Tipo: CONSULTA
-- Descripción: Lista todos los bloqueos de domicilios activos con filtros opcionales
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_list(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    folio INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha DATE,
    hora TIMESTAMP,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        bd.folio,
        bd.cvecalle,
        bd.calle,
        bd.num_ext,
        bd.let_ext,
        bd.num_int,
        bd.let_int,
        bd.observacion,
        bd.capturista,
        bd.fecha,
        bd.hora,
        bd.vig AS vigente
    FROM public.bloqueo_dom bd
    WHERE bd.vig = 'V'
      AND (p_filtro IS NULL OR
           UPPER(TRIM(bd.calle)) LIKE '%' || UPPER(TRIM(p_filtro)) || '%' OR
           CAST(bd.num_ext AS VARCHAR) LIKE '%' || TRIM(p_filtro) || '%' OR
           UPPER(TRIM(bd.observacion)) LIKE '%' || UPPER(TRIM(p_filtro)) || '%')
    ORDER BY bd.fecha DESC, bd.hora DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_domicilios_list(VARCHAR) IS
'Lista domicilios bloqueados activos con búsqueda por calle, número o observación';

-- ============================================
-- SP 2/4: sp_bloqueo_domicilios_create
-- Tipo: INSERCIÓN
-- Descripción: Crea un nuevo bloqueo de domicilio con validaciones
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_create(
    p_cvecalle INTEGER,
    p_calle VARCHAR,
    p_num_ext INTEGER,
    p_let_ext VARCHAR DEFAULT NULL,
    p_num_int INTEGER DEFAULT NULL,
    p_let_int VARCHAR DEFAULT NULL,
    p_observacion VARCHAR,
    p_capturista VARCHAR,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    folio INTEGER
) AS $$
DECLARE
    v_folio INTEGER;
    v_calle_norm VARCHAR;
    v_duplicado INTEGER;
BEGIN
    -- Validación: Calle no puede estar vacía
    IF p_calle IS NULL OR TRIM(p_calle) = '' THEN
        RETURN QUERY SELECT FALSE, 'La calle es obligatoria'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación: Observación/motivo obligatorio
    IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo del bloqueo es obligatorio'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación: Usuario registrado
    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario capturista es obligatorio'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Normalización de calle
    v_calle_norm := UPPER(TRIM(p_calle));

    -- Validación: Prevenir duplicados (misma calle + num_ext + num_int + let_ext + let_int)
    SELECT COUNT(*)
    INTO v_duplicado
    FROM public.bloqueo_dom
    WHERE UPPER(TRIM(calle)) = v_calle_norm
      AND COALESCE(num_ext, 0) = COALESCE(p_num_ext, 0)
      AND COALESCE(UPPER(TRIM(let_ext)), '') = COALESCE(UPPER(TRIM(p_let_ext)), '')
      AND COALESCE(num_int, 0) = COALESCE(p_num_int, 0)
      AND COALESCE(UPPER(TRIM(let_int)), '') = COALESCE(UPPER(TRIM(p_let_int)), '')
      AND vig = 'V';

    IF v_duplicado > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe un bloqueo activo para este domicilio'::VARCHAR,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Inserción del nuevo bloqueo
    INSERT INTO public.bloqueo_dom (
        cvecalle,
        calle,
        num_ext,
        let_ext,
        num_int,
        let_int,
        observacion,
        capturista,
        fecha,
        hora,
        vig
    )
    VALUES (
        p_cvecalle,
        v_calle_norm,
        p_num_ext,
        CASE WHEN p_let_ext IS NOT NULL THEN UPPER(TRIM(p_let_ext)) ELSE NULL END,
        p_num_int,
        CASE WHEN p_let_int IS NOT NULL THEN UPPER(TRIM(p_let_int)) ELSE NULL END,
        TRIM(p_observacion),
        TRIM(p_capturista),
        p_fecha,
        CURRENT_TIMESTAMP,
        'V'
    )
    RETURNING bloqueo_dom.folio INTO v_folio;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Bloqueo de domicilio creado exitosamente'::VARCHAR,
        v_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_domicilios_create(INTEGER, VARCHAR, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, DATE) IS
'Crea un nuevo bloqueo de domicilio con validaciones de duplicados y campos obligatorios';

-- ============================================
-- SP 3/4: sp_bloqueo_domicilios_update
-- Tipo: ACTUALIZACIÓN
-- Descripción: Actualiza un bloqueo de domicilio existente
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_update(
    p_folio INTEGER,
    p_cvecalle INTEGER,
    p_calle VARCHAR,
    p_num_ext INTEGER,
    p_let_ext VARCHAR DEFAULT NULL,
    p_num_int INTEGER DEFAULT NULL,
    p_let_int VARCHAR DEFAULT NULL,
    p_observacion VARCHAR,
    p_capturista VARCHAR,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    rows_affected INTEGER
) AS $$
DECLARE
    v_calle_norm VARCHAR;
    v_exists INTEGER;
    v_duplicado INTEGER;
    v_rows INTEGER;
BEGIN
    -- Validación: Folio debe existir y estar vigente
    SELECT COUNT(*)
    INTO v_exists
    FROM public.bloqueo_dom
    WHERE folio = p_folio AND vig = 'V';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El bloqueo no existe o ya fue cancelado'::VARCHAR,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación: Calle no puede estar vacía
    IF p_calle IS NULL OR TRIM(p_calle) = '' THEN
        RETURN QUERY SELECT FALSE, 'La calle es obligatoria'::VARCHAR, 0::INTEGER;
        RETURN;
    END IF;

    -- Validación: Observación/motivo obligatorio
    IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo del bloqueo es obligatorio'::VARCHAR, 0::INTEGER;
        RETURN;
    END IF;

    -- Validación: Usuario registrado
    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario capturista es obligatorio'::VARCHAR, 0::INTEGER;
        RETURN;
    END IF;

    -- Normalización de calle
    v_calle_norm := UPPER(TRIM(p_calle));

    -- Validación: Prevenir duplicados (excepto el mismo registro)
    SELECT COUNT(*)
    INTO v_duplicado
    FROM public.bloqueo_dom
    WHERE UPPER(TRIM(calle)) = v_calle_norm
      AND COALESCE(num_ext, 0) = COALESCE(p_num_ext, 0)
      AND COALESCE(UPPER(TRIM(let_ext)), '') = COALESCE(UPPER(TRIM(p_let_ext)), '')
      AND COALESCE(num_int, 0) = COALESCE(p_num_int, 0)
      AND COALESCE(UPPER(TRIM(let_int)), '') = COALESCE(UPPER(TRIM(p_let_int)), '')
      AND vig = 'V'
      AND folio <> p_folio;

    IF v_duplicado > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe otro bloqueo activo para este domicilio'::VARCHAR,
            0::INTEGER;
        RETURN;
    END IF;

    -- Actualización del bloqueo
    UPDATE public.bloqueo_dom
    SET cvecalle = p_cvecalle,
        calle = v_calle_norm,
        num_ext = p_num_ext,
        let_ext = CASE WHEN p_let_ext IS NOT NULL THEN UPPER(TRIM(p_let_ext)) ELSE NULL END,
        num_int = p_num_int,
        let_int = CASE WHEN p_let_int IS NOT NULL THEN UPPER(TRIM(p_let_int)) ELSE NULL END,
        observacion = TRIM(p_observacion),
        capturista = TRIM(p_capturista),
        fecha = p_fecha,
        hora = CURRENT_TIMESTAMP
    WHERE folio = p_folio
      AND vig = 'V';

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Bloqueo de domicilio actualizado exitosamente'::VARCHAR,
        v_rows;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_domicilios_update(INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, DATE) IS
'Actualiza un bloqueo de domicilio existente con validaciones';

-- ============================================
-- SP 4/4: sp_bloqueo_domicilios_cancel
-- Tipo: CANCELACIÓN (SOFT DELETE)
-- Descripción: Cancela un bloqueo de domicilio (vigente='C') y guarda histórico
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_cancel(
    p_folio INTEGER,
    p_motivo VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    rows_affected INTEGER
) AS $$
DECLARE
    v_exists INTEGER;
    v_rows INTEGER;
BEGIN
    -- Validación: Folio debe existir y estar vigente
    SELECT COUNT(*)
    INTO v_exists
    FROM public.bloqueo_dom
    WHERE folio = p_folio AND vig = 'V';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El bloqueo no existe o ya fue cancelado'::VARCHAR,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación: Motivo obligatorio
    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT
            FALSE,
            'El motivo de cancelación es obligatorio'::VARCHAR,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación: Usuario obligatorio
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            FALSE,
            'El usuario es obligatorio'::VARCHAR,
            0::INTEGER;
        RETURN;
    END IF;

    -- Guardar histórico antes de cancelar
    INSERT INTO public.h_bloqueo_dom (
        folio,
        cvecalle,
        calle,
        num_ext,
        let_ext,
        num_int,
        let_int,
        observacion,
        capturista,
        fecha,
        hora,
        vig,
        fecha_movimiento,
        motivo_movimiento,
        tipo_movimiento,
        usuario_movimiento
    )
    SELECT
        bd.folio,
        bd.cvecalle,
        bd.calle,
        bd.num_ext,
        bd.let_ext,
        bd.num_int,
        bd.let_int,
        bd.observacion,
        bd.capturista,
        bd.fecha,
        bd.hora,
        bd.vig,
        CURRENT_TIMESTAMP,
        TRIM(p_motivo),
        'ED',
        TRIM(p_usuario)
    FROM public.bloqueo_dom bd
    WHERE bd.folio = p_folio;

    -- Cancelar el bloqueo (soft delete)
    UPDATE public.bloqueo_dom
    SET vig = 'C',
        hora = CURRENT_TIMESTAMP
    WHERE folio = p_folio
      AND vig = 'V';

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Bloqueo de domicilio cancelado exitosamente'::VARCHAR,
        v_rows;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_domicilios_cancel(INTEGER, VARCHAR, VARCHAR) IS
'Cancela un bloqueo de domicilio (soft delete) y registra el movimiento en histórico';

-- ============================================
-- FIN DE STORED PROCEDURES - BLOQUEO DE DOMICILIOS
-- ============================================
