-- Stored Procedure: sp_search_bloqueos_rfc
-- Tipo: Catalog
-- Descripción: Busca RFC bloqueados por coincidencia parcial
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-27 16:24:36

CREATE OR REPLACE FUNCTION sp_search_bloqueos_rfc(p_rfc VARCHAR)
RETURNS TABLE(
    rfc VARCHAR(13),
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR(1),
    observacion VARCHAR(255),
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT rfc, id_tramite, licencia, hora, vig, observacion, capturista FROM bloqueo_rfc_lic WHERE rfc ILIKE '%' || p_rfc || '%' ORDER BY rfc;
END;
$$ LANGUAGE plpgsql;