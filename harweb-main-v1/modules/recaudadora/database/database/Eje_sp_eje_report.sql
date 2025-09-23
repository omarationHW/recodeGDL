-- Stored Procedure: sp_eje_report
-- Tipo: Report
-- Descripción: Reporte de ejecutores por rango de fechas y recaudadora
-- Generado para formulario: FrmEje
-- Fecha: 2025-08-27 21:17:33

CREATE OR REPLACE FUNCTION sp_eje_report(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_recaud INTEGER
) RETURNS TABLE(
    cveejecutor INTEGER,
    paterno TEXT,
    materno TEXT,
    nombres TEXT,
    rfc TEXT,
    recaud INTEGER,
    oficio TEXT,
    fecing DATE,
    fecinic DATE,
    fecterm DATE,
    vigente TEXT,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveejecutor, paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, vigente, feccap
    FROM ejecutores
    WHERE (p_fecha_inicio IS NULL OR fecing >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR fecing <= p_fecha_fin)
      AND (p_recaud IS NULL OR recaud = p_recaud)
    ORDER BY cveejecutor;
END;
$$ LANGUAGE plpgsql;