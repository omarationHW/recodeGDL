-- Stored Procedure: sp_titulos_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos del beneficiario de un título.
-- Generado para formulario: Titulos
-- Fecha: 2025-08-27 14:55:53

CREATE OR REPLACE FUNCTION sp_titulos_update(
    p_control_rcm INTEGER,
    p_titulo INTEGER,
    p_fecha DATE,
    p_libro INTEGER,
    p_axo INTEGER,
    p_folio INTEGER,
    p_nombre TEXT,
    p_domicilio TEXT,
    p_colonia TEXT,
    p_telefono TEXT,
    p_partida TEXT
) RETURNS TABLE(status TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE ta_13_titulos
    SET libro = p_libro,
        axo = p_axo,
        folio = p_folio,
        nombre_beneficiario = p_nombre,
        domicilio_beneficiario = p_domicilio,
        colonia_beneficiario = p_colonia,
        telefono_beneficiario = p_telefono,
        partida = p_partida
    WHERE control_rcm = p_control_rcm AND titulo = p_titulo AND fecha = p_fecha;
    RETURN QUERY SELECT 'OK', 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;