-- Stored Procedure: sp_bajas_folios
-- Tipo: CRUD
-- Descripción: Realiza la baja de folios de multas de estacionómetros (simula lógica de spd_delesta01).
-- Generado para formulario: sfrm_transfolios
-- Fecha: 2025-08-27 14:33:28

CREATE OR REPLACE FUNCTION sp_bajas_folios(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR,
    p_fecha DATE,
    p_convenio INTEGER,
    p_reca SMALLINT,
    p_caja VARCHAR,
    p_oper INTEGER,
    p_opc SMALLINT,
    p_usuauto INTEGER
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
DECLARE
    v_updated INTEGER := 0;
BEGIN
    -- Simulación: actualiza estado de folio a 'baja' (ejemplo: estado=99)
    UPDATE ta14_folios_adeudo
    SET estado = CASE WHEN p_opc = 6 THEN 99 ELSE 98 END,
        fec_baja = p_fecha,
        usu_baja = p_usuauto
    WHERE axo = p_axo AND folio = p_folio AND placa = p_placa;
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated > 0 THEN
        RETURN QUERY SELECT 1 AS result, 'Baja realizada' AS msg;
    ELSE
        RETURN QUERY SELECT 0 AS result, 'No se encontró el folio' AS msg;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;