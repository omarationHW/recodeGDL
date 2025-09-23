-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: LIGAANUNCIOFRM (EXACTO del archivo original)
-- Archivo: 75_SP_LICENCIAS_LIGAANUNCIOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_ligar_anuncio
-- Tipo: CRUD
-- Descripción: Liga un anuncio a una licencia o empresa, actualiza datos y recalcula saldos.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_ligar_anuncio(
    p_anuncio_id INTEGER,
    p_licencia_id INTEGER,
    p_empresa_id INTEGER,
    p_is_empresa BOOLEAN,
    p_user TEXT,
    OUT p_success BOOLEAN,
    OUT p_message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_anuncio RECORD;
    v_licencia RECORD;
    v_empresa RECORD;
BEGIN
    p_success := FALSE;
    p_message := '';
    SELECT * INTO v_anuncio FROM anuncios WHERE id_anuncio = p_anuncio_id;
    IF NOT FOUND THEN
        p_message := 'Anuncio no encontrado';
        RETURN;
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        p_message := 'No se puede ligar un anuncio cancelado.';
        RETURN;
    END IF;
    IF p_is_empresa THEN
        SELECT * INTO v_empresa FROM public WHERE id_licencia = p_empresa_id;
        IF NOT FOUND THEN
            p_message := 'Empresa no encontrada';
            RETURN;
        END IF;
        IF v_empresa.vigente <> 'V' THEN
            p_message := 'No se puede ligar a una empresa cancelada.';
            RETURN;
        END IF;
        UPDATE anuncios SET id_licencia = p_empresa_id WHERE id_anuncio = p_anuncio_id;
        UPDATE detsal_lic SET id_licencia = p_empresa_id WHERE id_anuncio = p_anuncio_id;
        PERFORM calc_sdosl(p_empresa_id);
    ELSE
        SELECT * INTO v_licencia FROM public WHERE id_licencia = p_licencia_id;
        IF NOT FOUND THEN
            p_message := 'Licencia no encontrada';
            RETURN;
        END IF;
        IF v_licencia.vigente <> 'V' THEN
            p_message := 'No se puede ligar a una licencia cancelada.';
            RETURN;
        END IF;
        UPDATE anuncios SET id_licencia = p_licencia_id,
            zona = v_licencia.zona,
            subzona = v_licencia.subzona,
            cvecalle = v_licencia.cvecalle,
            ubicacion = v_licencia.ubicacion,
            numext_ubic = v_licencia.numext_ubic,
            letraext_ubic = v_licencia.letraext_ubic,
            numint_ubic = v_licencia.numint_ubic,
            letraint_ubic = v_licencia.letraint_ubic
        WHERE id_anuncio = p_anuncio_id;
        UPDATE detsal_lic SET id_licencia = p_licencia_id WHERE id_anuncio = p_anuncio_id;
        PERFORM calc_sdosl(p_licencia_id);
    END IF;
    p_success := TRUE;
    p_message := 'Anuncio ligado correctamente';
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: LIGAANUNCIOFRM (EXACTO del archivo original)
-- Archivo: 75_SP_LICENCIAS_LIGAANUNCIOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

