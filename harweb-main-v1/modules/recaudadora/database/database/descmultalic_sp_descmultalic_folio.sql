-- Stored Procedure: sp_descmultalic_folio
-- Tipo: Report
-- Descripción: Obtiene los folios de requerimientos vigentes para una licencia
-- Generado para formulario: descmultalic
-- Fecha: 2025-08-27 00:04:06

CREATE OR REPLACE FUNCTION sp_descmultalic_folio(
    p_id_licencia INTEGER
) RETURNS TABLE(folio INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT folioreq FROM reqlicencias WHERE id_licencia = p_id_licencia AND vigencia = 'V';
END;
$$ LANGUAGE plpgsql;