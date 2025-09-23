-- Stored Procedure: sp_get_tramite_info
-- Tipo: Catalog
-- Descripción: Obtiene información de trámite y RFC para bloqueo
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-27 16:24:36

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_id_tramite INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR(13),
    actividad VARCHAR(130),
    propietarionvo VARCHAR(242)
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.id_licencia, t.rfc, t.actividad,
      trim(trim(coalesce(t.primer_ap, '')) || ' ' || trim(coalesce(t.segundo_ap, '')) || ' ' || trim(t.propietario)) as propietarionvo
    FROM lic_autoev a
    JOIN tramites t ON t.id_tramite = a.id_tramite
    WHERE a.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;