-- Stored Procedure: sp_reactiva_folios_aplicar
-- Tipo: CRUD
-- Descripción: Transfiere un folio de ta14_folios_histo a ta14_folios_adeudo y elimina de ta14_folios_histo y ta14_condonado.
-- Generado para formulario: Reactiva_Folios
-- Fecha: 2025-08-27 13:53:46

CREATE OR REPLACE FUNCTION sp_reactiva_folios_aplicar(
    p_opcion integer, -- 0=por placa+folio, 1=por axo+folio
    p_placa varchar(7),
    p_axo integer,
    p_folio integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_row RECORD;
BEGIN
    -- Buscar el folio
    IF p_opcion = 0 THEN
        SELECT * INTO v_row FROM ta14_folios_histo WHERE placa = UPPER(TRIM(p_placa)) AND folio = p_folio;
    ELSE
        SELECT * INTO v_row FROM ta14_folios_histo WHERE axo = p_axo AND folio = p_folio;
    END IF;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'No existe registro como adeudo';
        RETURN;
    END IF;

    BEGIN
        -- Iniciar transacción implícita
        INSERT INTO ta14_folios_adeudo (
            axo, folio, fecha_folio, placa, infraccion, estado, vigilante, num_acuerdo, fec_cap, usu_inicial, zona, espacio
        ) VALUES (
            v_row.axo, v_row.folio, v_row.fecha_folio, v_row.placa, v_row.infraccion, v_row.estado, v_row.vigilante, v_row.num_acuerdo, v_row.fec_cap, v_row.usu_inicial, v_row.zona, v_row.espacio
        );

        DELETE FROM ta14_folios_histo WHERE control = v_row.control;
        DELETE FROM ta14_condonado WHERE control = v_row.control;

        RETURN QUERY SELECT true, 'Se GRABÓ el Adeudo y se ELIMINÓ el Histórico';
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al grabar EN ADEUDO y borrar HISTÓRICO: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;