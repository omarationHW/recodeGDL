-- Stored Procedure: sp_tramite_baja_anun_buscar
-- Tipo: CRUD
-- Descripción: Busca un anuncio, sus saldos y la licencia relacionada.
-- Generado para formulario: TramiteBajaAnun
-- Fecha: 2025-08-27 19:45:07

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio JSONB,
    saldos JSONB,
    licencia JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        row_to_json(a),
        (SELECT json_agg(row_to_json(s)) FROM detsal_lic s WHERE s.id_anuncio = a.id_anuncio AND s.cvepago = 0),
        row_to_json(l)
    FROM anuncios a
    LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;