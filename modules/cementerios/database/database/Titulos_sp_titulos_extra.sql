-- Stored Procedure: sp_titulos_extra
-- Tipo: Catalog
-- Descripción: Devuelve datos extendidos de la vista v_titulos_cem para impresión avanzada.
-- Generado para formulario: Titulos
-- Fecha: 2025-08-27 14:55:53

CREATE OR REPLACE FUNCTION sp_titulos_extra(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    scontrol_rcm INTEGER,
    snombre TEXT,
    sdomicilio TEXT,
    scolonia TEXT,
    stelefono TEXT,
    slibro INTEGER,
    saxo INTEGER,
    sfoliot INTEGER,
    snombreben TEXT,
    sdomben TEXT,
    scolben TEXT,
    stelben TEXT,
    spartida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT scontrol_rcm, snombre, sdomicilio, scolonia, stelefono, slibro, saxo, sfoliot, snombreben, sdomben, scolben, stelben, spartida
    FROM v_titulos_cem
    WHERE sfecha = p_fecha AND scontrol_rcm = p_folio AND soperacion = p_operacion;
END;
$$ LANGUAGE plpgsql;