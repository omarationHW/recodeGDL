-- Stored Procedure: sp_altas_folios
-- Tipo: CRUD
-- Descripción: Inserta un folio de multa de estacionómetro en ta14_folios_adeudo.
-- Generado para formulario: sfrm_transfolios
-- Fecha: 2025-08-27 14:33:28

CREATE OR REPLACE FUNCTION sp_altas_folios(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR,
    p_fec DATE,
    p_clave SMALLINT,
    p_estado SMALLINT,
    p_agente INTEGER,
    p_captura SMALLINT
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    INSERT INTO ta14_folios_adeudo (
        axo, folio, fecha_folio, placa, infraccion, estado, vigilante, fec_cap, usu_inicial
    ) VALUES (
        p_axo, p_folio, p_fec, p_placa, p_clave, p_estado, p_agente, CURRENT_DATE, p_captura
    );
    RETURN QUERY SELECT 1 AS result, 'Insertado correctamente' AS msg;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;