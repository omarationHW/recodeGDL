-- Stored Procedure: sp_max_impresiones
-- Tipo: CRUD
-- Descripción: Calcula el máximo de impresiones posibles para una recaudadora
-- Generado para formulario: impreqCvecat
-- Fecha: 2025-08-27 21:20:48

CREATE OR REPLACE FUNCTION sp_max_impresiones(
    p_recaud INTEGER
) RETURNS TABLE(max INTEGER) AS $$
DECLARE
    tEjec INTEGER;
    tReq INTEGER;
    sZona INTEGER;
    maxImp INTEGER;
BEGIN
    SELECT COUNT(*) INTO tEjec FROM ejecutores WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO tReq FROM reqpredial WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO sZona FROM reqpredial WHERE recaud = p_recaud AND (zona_subzona = '0' OR zona_subzona IS NULL) AND vigencia = 'V';
    maxImp := tReq - sZona;
    IF tEjec > 0 THEN
        maxImp := LEAST(maxImp, tEjec);
    END IF;
    RETURN QUERY SELECT maxImp;
END;
$$ LANGUAGE plpgsql;