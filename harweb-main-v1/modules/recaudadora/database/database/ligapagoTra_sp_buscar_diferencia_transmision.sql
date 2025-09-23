-- Stored Procedure: sp_buscar_diferencia_transmision
-- Tipo: Report
-- Descripción: Obtiene información de diferencia de transmisión por folio.
-- Generado para formulario: ligapagoTra
-- Fecha: 2025-08-27 12:45:03

CREATE OR REPLACE FUNCTION sp_buscar_diferencia_transmision(
    p_folio INTEGER
) RETURNS SETOF diferencias_glosa AS $$
BEGIN
    RETURN QUERY SELECT * FROM diferencias_glosa WHERE foliot = p_folio;
END;
$$ LANGUAGE plpgsql;