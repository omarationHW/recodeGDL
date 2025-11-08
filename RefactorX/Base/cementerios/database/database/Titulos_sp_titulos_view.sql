-- Stored Procedure: sp_titulos_view
-- Tipo: Catalog
-- Descripción: Devuelve la vista previa de los datos de beneficiario para un título.
-- Generado para formulario: Titulos
-- Fecha: 2025-08-27 14:55:53

CREATE OR REPLACE FUNCTION sp_titulos_view(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.libro, t.axo, t.folio, t.partida
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;