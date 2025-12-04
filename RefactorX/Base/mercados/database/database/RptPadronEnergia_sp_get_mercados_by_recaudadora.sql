-- ============================================
-- STORED PROCEDURE
-- Formulario: RptPadronEnergia
-- SP: sp_get_mercados_by_recaudadora
-- Base: mercados
-- Esquema: padron_licencias.comun
-- Fecha: 2025-12-04 (Fix tipos INTEGER para compatibilidad Laravel)
-- ============================================

DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(integer) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(smallint) CASCADE;

-- Acepta y retorna INTEGER para compatibilidad con Laravel/PHP
-- Aunque la tabla usa SMALLINT, PostgreSQL hace el cast automáticamente
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
    p_recaudadora_id INTEGER
)
RETURNS TABLE(
    num_mercado_nvo INTEGER,
    descripcion VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo::INTEGER,
        m.descripcion
    FROM comun.ta_11_mercados m
    WHERE m.oficina = p_recaudadora_id
      AND m.cuenta_energia > 0
    ORDER BY m.num_mercado_nvo;
END;
$$;
