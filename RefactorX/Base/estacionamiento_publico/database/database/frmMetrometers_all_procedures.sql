-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: frmMetrometers
-- Generado: 2025-08-27 13:37:50
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_metrometer_by_axo_folio
-- Tipo: Catalog
-- Descripción: Obtiene un registro de ta14_adicional_mmeters por axo y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_metrometer_by_axo_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    axo smallint,
    folio integer,
    direccion varchar(100),
    poslong varchar(30),
    poslat varchar(30),
    marca varchar(30),
    modelo varchar(30),
    linkfoto1 varchar(100),
    linkfoto2 varchar(100),
    motivo varchar(250),
    idmedio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, direccion, poslong, poslat, marca, modelo, linkfoto1, linkfoto2, motivo, idmedio
    FROM ta14_adicional_mmeters
    WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_update_metrometer
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un registro en ta14_adicional_mmeters.
-- --------------------------------------------

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

-- ============================================

