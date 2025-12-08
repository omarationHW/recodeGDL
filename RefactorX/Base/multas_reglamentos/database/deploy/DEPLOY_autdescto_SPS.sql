-- =====================================================
-- STORED PROCEDURES PARA autdescto.vue
-- Módulo: Multas y Reglamentos
-- Componente: Autorización de Descuento Predial
-- Tablas: descpred, c_descpred
-- =====================================================

-- 1. SP para obtener catálogo de tipos de descuento
-- =====================================================
DROP FUNCTION IF EXISTS public.autdescto_sp_get_tipos_descuento(jsonb);

CREATE OR REPLACE FUNCTION public.autdescto_sp_get_tipos_descuento(
    p_params jsonb DEFAULT '{}'::jsonb
)
RETURNS TABLE (
    cvedescuento INTEGER,
    descripcion TEXT,
    porcentaje NUMERIC
) AS $$
BEGIN
    -- Obtener de tabla c_descpred (catálogo de descuentos prediales)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'c_descpred' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            cd.cvedescuento::INTEGER,
            COALESCE(cd.descripcion, 'Tipo ' || cd.cvedescuento)::TEXT,
            COALESCE(cd.porcentaje, 0)::NUMERIC
        FROM c_descpred cd
        ORDER BY cd.descripcion;
    ELSE
        -- Devolver catálogo por defecto si no existe la tabla
        RETURN QUERY
        SELECT * FROM (VALUES
            (1, 'Jubilado/Pensionado', 50.00::NUMERIC),
            (2, 'Adulto Mayor (60+)', 50.00::NUMERIC),
            (3, 'Discapacidad', 50.00::NUMERIC),
            (4, 'Viuda', 50.00::NUMERIC),
            (5, 'Pronto Pago', 15.00::NUMERIC),
            (6, 'Descuento Especial', 0.00::NUMERIC)
        ) AS t(cvedescuento, descripcion, porcentaje);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. SP para listar descuentos por cuenta (versión JSON)
-- =====================================================
DROP FUNCTION IF EXISTS public.sp_autdescto_list(jsonb);

CREATE OR REPLACE FUNCTION public.sp_autdescto_list(
    p_params jsonb DEFAULT '{}'::jsonb
)
RETURNS TABLE (
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    descripcion TEXT,
    foliodesc INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    solicitante TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion INTEGER,
    observaciones TEXT,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    status TEXT
) AS $$
DECLARE
    v_cvecuenta INTEGER := (p_params->>'cvecuenta')::INTEGER;
BEGIN
    RETURN QUERY
    SELECT
        d.id::INTEGER,
        d.cvecuenta::INTEGER,
        d.cvedescuento::INTEGER,
        COALESCE(c.descripcion, 'Tipo ' || d.cvedescuento)::TEXT as descripcion,
        d.foliodesc::INTEGER,
        d.bimini::INTEGER,
        d.bimfin::INTEGER,
        d.solicitante::TEXT,
        d.identificacion::TEXT,
        d.fecnac::DATE,
        d.institucion::INTEGER,
        d.observaciones::TEXT,
        d.fecalta::DATE,
        d.captalta::TEXT,
        d.fecbaja::DATE,
        d.captbaja::TEXT,
        d.status::TEXT
    FROM descpred d
    LEFT JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = v_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para crear nuevo descuento (versión JSON)
-- =====================================================
DROP FUNCTION IF EXISTS public.sp_autdescto_create(jsonb);

CREATE OR REPLACE FUNCTION public.sp_autdescto_create(
    p_params jsonb DEFAULT '{}'::jsonb
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id INTEGER,
    foliodesc INTEGER
) AS $$
DECLARE
    v_cvecuenta INTEGER := (p_params->>'cvecuenta')::INTEGER;
    v_cvedescuento INTEGER := (p_params->>'cvedescuento')::INTEGER;
    v_bimini INTEGER := COALESCE((p_params->>'bimini')::INTEGER, 1);
    v_bimfin INTEGER := COALESCE((p_params->>'bimfin')::INTEGER, 6);
    v_solicitante TEXT := p_params->>'solicitante';
    v_identificacion TEXT := p_params->>'identificacion';
    v_fecnac DATE := NULLIF(p_params->>'fecnac', '')::DATE;
    v_institucion INTEGER := NULLIF(p_params->>'institucion', '')::INTEGER;
    v_observaciones TEXT := p_params->>'observaciones';
    v_usuario TEXT := COALESCE(p_params->>'usuario', 'SISTEMA');
    v_new_id INTEGER;
    v_folio INTEGER;
    v_recaud INTEGER;
BEGIN
    -- Validaciones
    IF v_cvecuenta IS NULL THEN
        RETURN QUERY SELECT false, 'La cuenta es requerida'::TEXT, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF v_cvedescuento IS NULL THEN
        RETURN QUERY SELECT false, 'El tipo de descuento es requerido'::TEXT, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación de rango de bimestres
    IF v_bimini > v_bimfin THEN
        RETURN QUERY SELECT false, 'Error en el rango de bimestres'::TEXT, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación de duplicidad
    IF EXISTS (SELECT 1 FROM descpred WHERE cvecuenta = v_cvecuenta AND fecbaja IS NULL
               AND ((bimini BETWEEN v_bimini AND v_bimfin) OR (bimfin BETWEEN v_bimini AND v_bimfin))) THEN
        RETURN QUERY SELECT false, 'Ya existe un descuento vigente sobre este periodo'::TEXT, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Obtener recaudadora
    SELECT recaud INTO v_recaud FROM convcta WHERE cvecuenta = v_cvecuenta LIMIT 1;

    -- Generar folio
    SELECT COALESCE(MAX(foliodesc), 0) + 1 INTO v_folio FROM descpred WHERE recaud = v_recaud;

    -- Insertar registro
    INSERT INTO descpred (
        cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta,
        solicitante, observaciones, recaud, foliodesc, status,
        identificacion, fecnac, institucion
    ) VALUES (
        v_cvecuenta, v_cvedescuento, v_bimini, v_bimfin, CURRENT_DATE, v_usuario,
        v_solicitante, v_observaciones, v_recaud, v_folio, 'V',
        v_identificacion, v_fecnac, v_institucion
    ) RETURNING descpred.id INTO v_new_id;

    RETURN QUERY SELECT true, 'Descuento creado correctamente'::TEXT, v_new_id, v_folio;
END;
$$ LANGUAGE plpgsql;

-- 4. SP para actualizar descuento (versión JSON)
-- =====================================================
DROP FUNCTION IF EXISTS public.sp_autdescto_update(jsonb);

CREATE OR REPLACE FUNCTION public.sp_autdescto_update(
    p_params jsonb DEFAULT '{}'::jsonb
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_id INTEGER := (p_params->>'id')::INTEGER;
    v_bimini INTEGER := (p_params->>'bimini')::INTEGER;
    v_bimfin INTEGER := (p_params->>'bimfin')::INTEGER;
    v_solicitante TEXT := p_params->>'solicitante';
    v_identificacion TEXT := p_params->>'identificacion';
    v_fecnac DATE := NULLIF(p_params->>'fecnac', '')::DATE;
    v_institucion INTEGER := NULLIF(p_params->>'institucion', '')::INTEGER;
    v_observaciones TEXT := p_params->>'observaciones';
    v_usuario TEXT := COALESCE(p_params->>'usuario', 'SISTEMA');
BEGIN
    -- Validar que existe y no está cancelado
    IF NOT EXISTS (SELECT 1 FROM descpred WHERE id = v_id AND fecbaja IS NULL) THEN
        RETURN QUERY SELECT false, 'El descuento no existe o ya fue cancelado'::TEXT;
        RETURN;
    END IF;

    -- Actualizar
    UPDATE descpred SET
        bimini = COALESCE(v_bimini, bimini),
        bimfin = COALESCE(v_bimfin, bimfin),
        solicitante = COALESCE(v_solicitante, solicitante),
        observaciones = COALESCE(v_observaciones, observaciones),
        institucion = COALESCE(v_institucion, institucion),
        identificacion = COALESCE(v_identificacion, identificacion),
        fecnac = COALESCE(v_fecnac, fecnac)
    WHERE id = v_id;

    RETURN QUERY SELECT true, 'Descuento actualizado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 5. SP para cancelar descuento (versión JSON)
-- =====================================================
DROP FUNCTION IF EXISTS public.sp_autdescto_cancel(jsonb);

CREATE OR REPLACE FUNCTION public.sp_autdescto_cancel(
    p_params jsonb DEFAULT '{}'::jsonb
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_id INTEGER := (p_params->>'id')::INTEGER;
    v_usuario TEXT := COALESCE(p_params->>'usuario', 'SISTEMA');
    v_motivo TEXT := COALESCE(p_params->>'motivo', 'Sin motivo especificado');
BEGIN
    -- Validar que existe
    IF NOT EXISTS (SELECT 1 FROM descpred WHERE id = v_id) THEN
        RETURN QUERY SELECT false, 'El descuento no existe'::TEXT;
        RETURN;
    END IF;

    -- Validar que no está cancelado
    IF EXISTS (SELECT 1 FROM descpred WHERE id = v_id AND fecbaja IS NOT NULL) THEN
        RETURN QUERY SELECT false, 'El descuento ya fue cancelado anteriormente'::TEXT;
        RETURN;
    END IF;

    -- Cancelar (baja lógica)
    UPDATE descpred SET
        fecbaja = CURRENT_DATE,
        captbaja = v_usuario,
        status = 'C',
        observaciones = COALESCE(observaciones, '') || E'\nCancelado: ' || v_motivo
    WHERE id = v_id;

    RETURN QUERY SELECT true, 'Descuento cancelado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICACIÓN
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'SPs para autdescto.vue creados:';
    RAISE NOTICE '  - autdescto_sp_get_tipos_descuento (JSON)';
    RAISE NOTICE '  - sp_autdescto_list (JSON)';
    RAISE NOTICE '  - sp_autdescto_create (JSON)';
    RAISE NOTICE '  - sp_autdescto_update (JSON)';
    RAISE NOTICE '  - sp_autdescto_cancel (JSON)';
    RAISE NOTICE 'Tablas utilizadas: descpred, c_descpred';
    RAISE NOTICE '===========================================';
END $$;
