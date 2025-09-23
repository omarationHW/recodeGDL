-- Stored Procedure: sp_update_metrometer
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un registro en ta14_adicional_mmeters.
-- Generado para formulario: frmMetrometers
-- Fecha: 2025-08-27 13:37:50

CREATE OR REPLACE FUNCTION sp_update_metrometer(
    p_axo integer,
    p_folio integer,
    p_direccion varchar(100),
    p_marca varchar(30),
    p_motivo varchar(250),
    p_modelo varchar(30) DEFAULT NULL,
    p_poslong varchar(30) DEFAULT NULL,
    p_poslat varchar(30) DEFAULT NULL,
    p_linkfoto1 varchar(100) DEFAULT NULL,
    p_linkfoto2 varchar(100) DEFAULT NULL,
    p_idmedio integer DEFAULT NULL
)
RETURNS TABLE (
    updated boolean
) AS $$
BEGIN
    UPDATE ta14_adicional_mmeters
    SET direccion = p_direccion,
        marca = p_marca,
        motivo = p_motivo,
        modelo = COALESCE(p_modelo, modelo),
        poslong = COALESCE(p_poslong, poslong),
        poslat = COALESCE(p_poslat, poslat),
        linkfoto1 = COALESCE(p_linkfoto1, linkfoto1),
        linkfoto2 = COALESCE(p_linkfoto2, linkfoto2),
        idmedio = COALESCE(p_idmedio, idmedio)
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;