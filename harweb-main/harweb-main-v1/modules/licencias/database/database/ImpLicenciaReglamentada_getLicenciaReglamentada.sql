-- Stored Procedure: getLicenciaReglamentada
-- Tipo: Report
-- Descripción: Obtiene los datos completos de la licencia reglamentada, giro, convcta y zona.
-- Generado para formulario: ImpLicenciaReglamentadaFrm
-- Fecha: 2025-08-26 17:01:24

-- PostgreSQL function to get licencia reglamentada
CREATE OR REPLACE FUNCTION getLicenciaReglamentada(p_licencia integer)
RETURNS TABLE (
    licencia jsonb,
    giro jsonb,
    convcta jsonb,
    zona jsonb
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        to_jsonb(l.*),
        to_jsonb(g.*),
        to_jsonb(c.*),
        to_jsonb(z.*)
    FROM licencias l
    LEFT JOIN c_giros g ON g.id_giro = l.id_giro
    LEFT JOIN convcta c ON c.cvecuenta = l.cvecuenta
    LEFT JOIN zona_lic z ON z.licencia = l.licencia
    WHERE l.licencia = p_licencia AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;