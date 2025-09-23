-- Stored Procedure: sp_abcf_update_adicional
-- Tipo: CRUD
-- Descripción: Actualiza o inserta los datos adicionales de un folio.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE PROCEDURE sp_abcf_update_adicional(
    p_folio INTEGER,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_telefono VARCHAR,
    p_clave_ife VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_13_datosrcmadic WHERE control_rcm = p_folio) THEN
        UPDATE ta_13_datosrcmadic SET
            rfc = p_rfc,
            curp = p_curp,
            telefono = p_telefono,
            clave_ife = p_clave_ife
        WHERE control_rcm = p_folio;
    ELSE
        INSERT INTO ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife)
        VALUES (p_folio, p_rfc, p_curp, p_telefono, p_clave_ife);
    END IF;
END;
$$;