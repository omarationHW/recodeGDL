-- Stored Procedure: sp_get_licencia_recibo
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la licencia para impresión de recibo
-- Generado para formulario: ImpRecibofrm
-- Fecha: 2025-08-27 18:32:11

CREATE OR REPLACE FUNCTION sp_get_licencia_recibo(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER,
    nombre TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    dom_completo TEXT,
    propietarionvo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.licencia,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS nombre,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS domicilio,
           l.id_licencia,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS dom_completo,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia = p_licencia AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;