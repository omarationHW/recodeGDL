-- ============================================
-- DEPLOY CONSOLIDADO: modlicAdeudofrm
-- Componente 82/95 - BATCH 17
-- Generado: 2025-11-20
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_calc_sdoslsr
-- Nota: Convertido de PROCEDURE a FUNCTION para compatibilidad
CREATE OR REPLACE FUNCTION public.sp_calc_sdoslsr(p_id_licencia INTEGER)
RETURNS JSON AS $$
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

    -- Gastos y multas
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

    RETURN json_build_object(
        'success', true,
        'derechos', v_derechos,
        'anuncios', v_anuncios,
        'recargos', v_recargos,
        'total', v_total
    );
END;
$$ LANGUAGE plpgsql;
