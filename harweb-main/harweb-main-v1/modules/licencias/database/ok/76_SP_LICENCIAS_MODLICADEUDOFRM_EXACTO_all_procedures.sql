-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: MODLICADEUDOFRM (EXACTO del archivo original)
-- Archivo: 76_SP_LICENCIAS_MODLICADEUDOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: calc_sdoslsr
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de la licencia en la tabla saldos_lic, sumando los valores de detsal_lic.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE calc_sdoslsr(IN p_id_licencia INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_forma NUMERIC := 0;
    v_derechos NUMERIC := 0;
    v_derechos2 NUMERIC := 0;
    v_recargos NUMERIC := 0;
    v_anuncios NUMERIC := 0;
    v_gastos NUMERIC := 0;
    v_multas NUMERIC := 0;
    v_formas NUMERIC := 0;
    v_total NUMERIC := 0;
    v_base NUMERIC := 0;
    v_desc_derechos NUMERIC := 0;
    v_desc_recargos NUMERIC := 0;
BEGIN
    -- Suma de licencias (sin anuncios)
    SELECT COALESCE(SUM(forma),0), COALESCE(SUM(derechos),0), COALESCE(SUM(derechos2),0), COALESCE(SUM(recargos),0),
           COALESCE(SUM(desc_derechos),0), COALESCE(SUM(desc_recargos),0)
      INTO v_forma, v_derechos, v_derechos2, v_recargos, v_desc_derechos, v_desc_recargos
      FROM detsal_lic
     WHERE id_licencia = p_id_licencia
       AND (id_anuncio IS NULL OR id_anuncio = 0)
       AND (cvepago IS NULL OR cvepago = 0);

    -- Suma de anuncios
    SELECT COALESCE(SUM(forma),0), COALESCE(SUM(derechos),0), COALESCE(SUM(recargos),0)
      INTO v_formas, v_anuncios, v_recargos
      FROM detsal_lic
     WHERE id_licencia = p_id_licencia
       AND (id_anuncio > 0)
       AND (cvepago IS NULL OR cvepago = 0);

    -- Gastos y multas pueden ser calculados de otras tablas si aplica, aquí se dejan en 0
    v_gastos := 0;
    v_multas := 0;

    -- Base = derechos
    v_base := v_derechos;

    -- Total
    v_total := v_formas + v_forma + v_derechos + v_anuncios + v_recargos + v_gastos + v_multas;

    -- Upsert en saldos_lic
    IF EXISTS (SELECT 1 FROM saldos_lic WHERE id_licencia = p_id_licencia) THEN
        UPDATE saldos_lic SET
            derechos = v_derechos,
            anuncios = v_anuncios,
            recargos = v_recargos,
            gastos = v_gastos,
            multas = v_multas,
            formas = v_formas + v_forma,
            total = v_total,
            base = v_base,
            desc_derechos = v_desc_derechos,
            desc_recargos = v_desc_recargos
        WHERE id_licencia = p_id_licencia;
    ELSE
        INSERT INTO saldos_lic (
            id_licencia, derechos, anuncios, recargos, gastos, multas, formas, total, base, desc_derechos, desc_recargos
        ) VALUES (
            p_id_licencia, v_derechos, v_anuncios, v_recargos, v_gastos, v_multas, v_formas + v_forma, v_total, v_base, v_desc_derechos, v_desc_recargos
        );
    END IF;
END;
$$;

-- ============================================

