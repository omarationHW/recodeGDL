-- Stored Procedure: sp_buscar_transmision
-- Tipo: Report
-- Descripción: Busca una transmisión patrimonial por folio.
-- Generado para formulario: ligapagoTra
-- Fecha: 2025-08-27 12:45:03

CREATE OR REPLACE FUNCTION sp_buscar_transmision(
    p_folio INTEGER
) RETURNS SETOF actostransm AS $$
BEGIN
    RETURN QUERY SELECT * FROM actostransm WHERE folio = p_folio;
END;
$$ LANGUAGE plpgsql;