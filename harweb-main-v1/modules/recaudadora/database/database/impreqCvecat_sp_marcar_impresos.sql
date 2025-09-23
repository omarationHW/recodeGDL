-- Stored Procedure: sp_marcar_impresos
-- Tipo: CRUD
-- Descripción: Marca como impresos los requerimientos seleccionados
-- Generado para formulario: impreqCvecat
-- Fecha: 2025-08-27 21:20:48

CREATE OR REPLACE FUNCTION sp_marcar_impresos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_usuario TEXT
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET impreso = 'S', feccap = NOW(), capturista = p_usuario
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'impreso' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;