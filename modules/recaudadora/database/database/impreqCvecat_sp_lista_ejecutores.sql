-- Stored Procedure: sp_lista_ejecutores
-- Tipo: Catalog
-- Descripción: Lista ejecutores disponibles para una recaudadora y fecha
-- Generado para formulario: impreqCvecat
-- Fecha: 2025-08-27 21:20:48

CREATE OR REPLACE FUNCTION sp_lista_ejecutores(
    p_recaud INTEGER, p_fecha DATE
) RETURNS TABLE(cveejecutor INTEGER, ncompleto TEXT, asignar INTEGER, ultfec_entrega DATE) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, ncompleto, asignados, ultfec_entrega FROM ejecutores WHERE recaud = p_recaud AND (vigencia = 'V' OR (ultfec_entrega = p_fecha));
END;
$$ LANGUAGE plpgsql;