-- Stored Procedure: sp_buscar_tramite
-- Tipo: Catalog
-- Descripción: Busca un trámite por id_tramite y retorna datos relevantes para el formulario.
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-26 14:47:37

CREATE OR REPLACE FUNCTION sp_buscar_tramite(p_id_tramite INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc TEXT,
    actividad TEXT,
    propietarionvo TEXT
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