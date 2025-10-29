-- Stored Procedure: sp_histo_by_axo_folio
-- Tipo: Report
-- Descripción: Obtiene el historial de folios por año y folio.
-- Generado para formulario: srfrm_conci_banorte
-- Fecha: 2025-08-27 15:02:35

CREATE OR REPLACE FUNCTION sp_histo_by_axo_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    control integer,
    fecha_movto date,
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion smallint,
    estado smallint,
    vigilante integer,
    num_acuerdo integer,
    fec_cap date,
    usu_inicial integer,
    codigo_movto smallint,
    usu_bajaauto smallint,
    zona smallint,
    espacio smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control, b.fecha_movto, b.axo, b.folio, b.fecha_folio, b.placa, b.infraccion, b.estado, b.vigilante, b.num_acuerdo, b.fec_cap, b.usu_inicial, b.codigo_movto, b.usu_bajaauto, b.zona, b.espacio
    FROM ta14_folios_histo b
    WHERE b.axo = p_axo AND b.folio = p_folio;
END;
$$ LANGUAGE plpgsql;