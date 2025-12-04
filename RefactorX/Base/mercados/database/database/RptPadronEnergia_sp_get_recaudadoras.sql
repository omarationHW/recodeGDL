-- ============================================
-- STORED PROCEDURE
-- Formulario: RptPadronEnergia
-- SP: sp_get_recaudadoras
-- Base: mercados
-- Esquema: padron_licencias.comun
-- Fecha: 2025-12-04
-- ============================================

DROP FUNCTION IF EXISTS sp_get_recaudadoras();

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
    id_rec integer,
    recaudadora varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id_rec,
        recaudadora
    FROM comun.ta_12_recaudadoras
    ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;
