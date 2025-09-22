-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DescMultaReqDifTrans (Descuentos Multa Requerimiento Diferencia Transmisiones)
-- Generado: 2025-08-27 00:14:47
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_descmultadiftransm_buscar_folio
-- Tipo: Report
-- Descripción: Busca descuentos de multa de requerimiento de transmisión por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_buscar_folio(p_folio INTEGER)
RETURNS TABLE(
    id_descmulta INTEGER,
    foliot INTEGER,
    porcentaje INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR,
    estado VARCHAR,
    cvepago INTEGER,
    folio INTEGER,
    autoriza INTEGER,
    cvedepto INTEGER,
    autoriza_nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_descmulta, a.foliot, a.porcentaje, a.fecalta, a.captalta, 
        a.fecbaja, a.captbaja, a.estado, a.cvepago, a.folio, a.autoriza, 
        a.cvedepto, c.nombre as autoriza_nombre, c.descripcion
    FROM public.descmultadiftransm a
    LEFT JOIN public.c_autdescmul c ON a.autoriza = c.cveautoriza
    WHERE a.foliot = p_folio AND a.estado = 'V'
    ORDER BY a.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_descmultadiftransm_buscar_diferencia
-- Tipo: Report
-- Descripción: Busca diferencias de transmisión con multa vigente por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_buscar_diferencia(p_folio INTEGER)
RETURNS TABLE(
    id_descmulta INTEGER,
    foliot INTEGER,
    porcentaje INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR,
    estado VARCHAR,
    cvepago INTEGER,
    folio INTEGER,
    autoriza INTEGER,
    cvedepto INTEGER,
    autoriza_nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_descmulta, a.foliot, a.porcentaje, a.fecalta, a.captalta, 
        a.fecbaja, a.captbaja, a.estado, a.cvepago, a.folio, a.autoriza, 
        a.cvedepto, c.nombre as autoriza_nombre, c.descripcion
    FROM public.descmultadiftransm a
    LEFT JOIN public.c_autdescmul c ON a.autoriza = c.cveautoriza
    WHERE a.foliot = p_folio AND a.estado = 'V'
    ORDER BY a.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_descmultadiftransm_alta
-- Tipo: CRUD
-- Descripción: Da de alta un descuento de multa de requerimiento de transmisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_alta(
    p_folio INTEGER,
    p_porcentaje INTEGER,
    p_usuario VARCHAR,
    p_autoriza INTEGER,
    p_cvedepto INTEGER
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe un descuento vigente para este folio
    SELECT COUNT(*) INTO v_exists 
    FROM public.descmultadiftransm 
    WHERE foliot = p_folio AND estado = 'V';
    
    IF v_exists > 0 THEN
        -- Cancelar descuentos anteriores vigentes
        UPDATE public.descmultadiftransm 
        SET estado = 'C', 
            fecbaja = CURRENT_DATE, 
            captbaja = p_usuario
        WHERE foliot = p_folio AND estado = 'V';
    END IF;
    
    -- Insertar nuevo descuento
    INSERT INTO public.descmultadiftransm (
        foliot, porcentaje, fecalta, captalta, fecbaja, captbaja, 
        estado, cvepago, folio, autoriza, cvedepto
    )
    VALUES (
        p_folio, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 
        'V', NULL, NULL, p_autoriza, p_cvedepto
    )
    RETURNING id_descmulta INTO v_id;
    
    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_descmultadiftransm_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento de multa de requerimiento de transmisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_cancelar(
    p_folio INTEGER,
    p_id_descmulta INTEGER,
    p_usuario VARCHAR
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descmultadiftransm
    SET estado = 'C', 
        fecbaja = CURRENT_DATE, 
        captbaja = p_usuario
    WHERE foliot = p_folio 
      AND id_descmulta = p_id_descmulta
      AND estado = 'V'; -- Solo cancelar si está vigente
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con folio % e ID %', p_folio, p_id_descmulta;
    END IF;
    
    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_descmultadiftransm_autorizadores
-- Tipo: Catalog
-- Descripción: Obtiene lista de autorizadores de descuentos de multa para el usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_autorizadores(p_usuario VARCHAR)
RETURNS TABLE(
    cveautoriza INTEGER,
    descripcion VARCHAR,
    nombre VARCHAR,
    porcentajetope INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.cveautoriza, 
        c.descripcion, 
        c.nombre, 
        c.porcentajetope
    FROM public.c_autdescmul c
    WHERE c.vigencia = 'V'
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================