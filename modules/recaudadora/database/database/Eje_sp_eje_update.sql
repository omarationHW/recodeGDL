-- Stored Procedure: sp_eje_update
-- Tipo: CRUD
-- Descripción: Actualiza un ejecutor existente
-- Generado para formulario: FrmEje
-- Fecha: 2025-08-27 21:17:33

CREATE OR REPLACE FUNCTION sp_eje_update(
    p_id INTEGER,
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
) RETURNS TABLE(updated BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET
        paterno = p_paterno,
        materno = p_materno,
        nombres = p_nombres,
        rfc = p_rfc,
        recaud = p_recaud,
        oficio = p_oficio,
        fecing = p_fecing,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        capturista = p_capturista,
        feccap = NOW()
    WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;