-- =====================================================
-- IMPLEMENTACIÓN COMPLETA: bloqueoRFCfrm
-- Módulo: Padrón de Licencias
-- Descripción: Bloqueo de RFC para prevenir nuevos trámites
-- Fecha: 2025-11-20
-- =====================================================

-- =====================================================
-- SP 1/4: sp_bloqueo_rfc_list
-- Descripción: Lista todos los bloqueos de RFC activos
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_list()
RETURNS TABLE(
    rfc VARCHAR,
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR,
    observacion VARCHAR,
    capturista VARCHAR
) AS $$
BEGIN
    -- Retorna todos los bloqueos de RFC ordenados por RFC
    RETURN QUERY
    SELECT
        br.rfc,
        br.id_tramite,
        br.licencia,
        br.hora,
        br.vig,
        br.observacion,
        br.capturista
    FROM public.bloqueo_rfc_lic br
    ORDER BY br.rfc;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_rfc_list() IS
'Lista todos los bloqueos de RFC (vigentes y cancelados). Usado por el grid principal del formulario bloqueoRFCfrm.';


-- =====================================================
-- SP 2/4: sp_bloqueo_rfc_buscar_tramite
-- Descripción: Busca información del trámite por ID
-- Retorna: Datos del trámite incluyendo RFC, licencia, propietario y actividad
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_buscar_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR,
    actividad VARCHAR,
    propietarionvo VARCHAR,
    esta_bloqueado BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_esta_bloqueado BOOLEAN := FALSE;
    v_motivo_bloqueo TEXT := NULL;
BEGIN
    -- Validar parámetro
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'El ID de trámite es requerido y debe ser mayor a 0';
    END IF;

    -- Verificar si el RFC del trámite está bloqueado
    SELECT
        TRUE,
        br.observacion
    INTO
        v_esta_bloqueado,
        v_motivo_bloqueo
    FROM public.lic_autoev a
    JOIN public.tramites t ON t.id_tramite = a.id_tramite
    LEFT JOIN public.bloqueo_rfc_lic br ON br.rfc = t.rfc AND br.vig = 'V'
    WHERE a.id_tramite = p_id_tramite
    LIMIT 1;

    -- Retornar información del trámite
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.id_licencia,
        t.rfc,
        t.actividad,
        TRIM(TRIM(COALESCE(t.primer_ap, '')) || ' ' || TRIM(COALESCE(t.segundo_ap, '')) || ' ' || TRIM(t.propietario)) AS propietarionvo,
        COALESCE(v_esta_bloqueado, FALSE) AS esta_bloqueado,
        v_motivo_bloqueo
    FROM public.lic_autoev a
    JOIN public.tramites t ON t.id_tramite = a.id_tramite
    WHERE a.id_tramite = p_id_tramite;

    -- Validar que existe el trámite
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el trámite con ID: %', p_id_tramite;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_rfc_buscar_tramite(INTEGER) IS
'Busca información del trámite por ID. Retorna RFC, licencia, propietario, actividad y estado de bloqueo. Usado en el botón "Buscar" del formulario bloqueoRFCfrm.';


-- =====================================================
-- SP 3/4: sp_bloqueo_rfc_create
-- Descripción: Crea un nuevo bloqueo de RFC
-- Validaciones:
--   - RFC normalizado (UPPER, sin espacios)
--   - No permite duplicados del mismo RFC vigente
--   - Motivo obligatorio
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_create(
    p_rfc VARCHAR,
    p_id_tramite INTEGER,
    p_licencia INTEGER,
    p_observacion VARCHAR,
    p_capturista VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_exists INTEGER;
    v_rfc_normalizado VARCHAR;
BEGIN
    -- Validaciones de parámetros
    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RAISE EXCEPTION 'El RFC es obligatorio';
    END IF;

    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'El ID de trámite es obligatorio y debe ser mayor a 0';
    END IF;

    IF p_licencia IS NULL OR p_licencia <= 0 THEN
        RAISE EXCEPTION 'La licencia es obligatoria y debe ser mayor a 0';
    END IF;

    IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
        RAISE EXCEPTION 'El motivo del bloqueo es obligatorio';
    END IF;

    -- Normalizar RFC (UPPER y sin espacios)
    v_rfc_normalizado := UPPER(TRIM(p_rfc));

    -- Validar formato de RFC (12-13 caracteres alfanuméricos)
    IF LENGTH(v_rfc_normalizado) < 12 OR LENGTH(v_rfc_normalizado) > 13 THEN
        RAISE EXCEPTION 'El RFC debe tener entre 12 y 13 caracteres';
    END IF;

    IF v_rfc_normalizado !~ '^[A-Z0-9]+$' THEN
        RAISE EXCEPTION 'El RFC solo puede contener letras y números';
    END IF;

    -- Verificar si ya existe un bloqueo vigente para este RFC
    SELECT 1
    INTO v_exists
    FROM public.bloqueo_rfc_lic
    WHERE rfc = v_rfc_normalizado
      AND vig = 'V'
    LIMIT 1;

    IF v_exists IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un bloqueo vigente para el RFC: %', v_rfc_normalizado;
    END IF;

    -- Insertar nuevo bloqueo
    INSERT INTO public.bloqueo_rfc_lic (
        rfc,
        id_tramite,
        licencia,
        hora,
        vig,
        observacion,
        capturista
    )
    VALUES (
        v_rfc_normalizado,
        p_id_tramite,
        p_licencia,
        NOW(),
        'V',
        TRIM(p_observacion),
        COALESCE(p_capturista, CURRENT_USER)
    );

    RAISE NOTICE 'Bloqueo de RFC creado exitosamente: %', v_rfc_normalizado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_rfc_create(VARCHAR, INTEGER, INTEGER, VARCHAR, VARCHAR) IS
'Crea un nuevo bloqueo de RFC. Normaliza el RFC (UPPER), valida formato (12-13 caracteres), previene duplicados vigentes y requiere motivo. Usado en el botón "Aceptar" del modo Agregar.';


-- =====================================================
-- SP 4/4: sp_bloqueo_rfc_desbloquear
-- Descripción: Desbloquea un RFC (soft delete: cambia vig de 'V' a 'C')
-- Nota: No elimina el registro, solo cambia el estado para mantener historial
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_desbloquear(
    p_rfc VARCHAR,
    p_observacion VARCHAR,
    p_capturista VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_rfc_normalizado VARCHAR;
    v_affected_rows INTEGER;
BEGIN
    -- Validaciones de parámetros
    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RAISE EXCEPTION 'El RFC es obligatorio';
    END IF;

    IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
        RAISE EXCEPTION 'El motivo del desbloqueo es obligatorio';
    END IF;

    -- Normalizar RFC
    v_rfc_normalizado := UPPER(TRIM(p_rfc));

    -- Actualizar registro: cambiar estado de 'V' a 'C' (soft delete)
    UPDATE public.bloqueo_rfc_lic
    SET
        observacion = TRIM(p_observacion),
        vig = 'C',
        hora = NOW(),
        capturista = COALESCE(p_capturista, CURRENT_USER)
    WHERE
        rfc = v_rfc_normalizado
        AND vig = 'V';

    -- Obtener número de filas afectadas
    GET DIAGNOSTICS v_affected_rows = ROW_COUNT;

    -- Validar que se encontró el bloqueo
    IF v_affected_rows = 0 THEN
        RAISE EXCEPTION 'No se encontró un bloqueo vigente para el RFC: %', v_rfc_normalizado;
    END IF;

    RAISE NOTICE 'RFC desbloqueado exitosamente: % (% registros actualizados)', v_rfc_normalizado, v_affected_rows;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_bloqueo_rfc_desbloquear(VARCHAR, VARCHAR, VARCHAR) IS
'Desbloquea un RFC cambiando el estado de V (Vigente) a C (Cancelado). No elimina el registro para mantener historial. Usado en el botón "Desbloquear" del formulario bloqueoRFCfrm.';


-- =====================================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'STORED PROCEDURES INSTALADOS CORRECTAMENTE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Módulo: bloqueoRFCfrm';
    RAISE NOTICE 'Total de SPs: 4';
    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE '1. sp_bloqueo_rfc_list()';
    RAISE NOTICE '2. sp_bloqueo_rfc_buscar_tramite(p_id_tramite)';
    RAISE NOTICE '3. sp_bloqueo_rfc_create(p_rfc, p_id_tramite, p_licencia, p_observacion, p_capturista)';
    RAISE NOTICE '4. sp_bloqueo_rfc_desbloquear(p_rfc, p_observacion, p_capturista)';
    RAISE NOTICE '========================================';
END $$;
