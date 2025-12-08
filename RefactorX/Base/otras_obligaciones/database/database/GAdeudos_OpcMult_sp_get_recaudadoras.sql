-- ================================================================
-- SP: SP_GADEUDOS_OPC_MULT_RECAUDADORAS_GET
-- Módulo: otras_obligaciones
-- Descripción: Obtiene el catálogo de recaudadoras disponibles
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS SP_GADEUDOS_OPC_MULT_RECAUDADORAS_GET();

CREATE OR REPLACE FUNCTION SP_GADEUDOS_OPC_MULT_RECAUDADORAS_GET()
RETURNS TABLE (
    id_rec INTEGER,
    recaudadora VARCHAR,
    activa BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.recaudadora::VARCHAR,
        CASE WHEN r.activa = 1 THEN TRUE ELSE FALSE END as activa
    FROM public.recaudadoras r
    WHERE r.activa = 1
    ORDER BY r.recaudadora;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION SP_GADEUDOS_OPC_MULT_RECAUDADORAS_GET() IS 'Obtiene catálogo de recaudadoras activas - Otras Obligaciones';
