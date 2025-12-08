-- ============================================
-- FIX: sp_rubros_listar
-- Problema: Referencia incorrecta a db_ingresos.t34_datos
-- Fecha: 2025-11-25
-- ============================================

DROP FUNCTION IF EXISTS sp_rubros_listar();

CREATE OR REPLACE FUNCTION sp_rubros_listar()
RETURNS TABLE (
    id_34_tab INTEGER,
    cve_tab VARCHAR,
    nombre VARCHAR,
    cajero VARCHAR,
    auto_tab BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_34_tab,
        t.cve_tab::VARCHAR,
        t.nombre::VARCHAR,
        t.cajero::VARCHAR,
        CASE WHEN t.auto_tab > 0 THEN TRUE ELSE FALSE END as auto_tab
    FROM t34_tablas t
    ORDER BY t.cve_tab;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_rubros_listar() IS 'Lista todos los rubros de otras obligaciones';

SELECT 'SP sp_rubros_listar corregido' AS resultado;
