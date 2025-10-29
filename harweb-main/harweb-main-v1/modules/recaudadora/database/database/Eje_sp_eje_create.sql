-- Stored Procedure: sp_eje_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo ejecutor
-- Generado para formulario: FrmEje
-- Fecha: 2025-08-27 21:17:33

CREATE OR REPLACE FUNCTION sp_eje_create(
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(cveejecutor INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ejecutores (paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, capturista, vigente, feccap)
    VALUES (p_paterno, p_materno, p_nombres, p_rfc, p_recaud, p_oficio, p_fecing, p_fecinic, p_fecterm, p_capturista, 'V', NOW())
    RETURNING cveejecutor INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;