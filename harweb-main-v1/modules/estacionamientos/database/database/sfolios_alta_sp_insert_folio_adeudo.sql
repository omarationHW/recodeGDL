-- Stored Procedure: sp_insert_folio_adeudo
-- Tipo: CRUD
-- Descripción: Inserta un nuevo folio de adeudo en la tabla ta14_folios_adeudo.
-- Generado para formulario: sfolios_alta
-- Fecha: 2025-08-27 14:01:34

CREATE OR REPLACE FUNCTION sp_insert_folio_adeudo(
    p_axo INTEGER,
    p_folio INTEGER,
    p_fecha_folio DATE,
    p_placa VARCHAR,
    p_infraccion SMALLINT,
    p_estado INTEGER,
    p_vigilante INTEGER,
    p_usu_inicial INTEGER,
    p_zona SMALLINT,
    p_espacio SMALLINT
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    INSERT INTO ta14_folios_adeudo (
        axo, folio, fecha_folio, placa, infraccion, estado, vigilante, fec_cap, usu_inicial, zona, espacio
    ) VALUES (
        p_axo, p_folio, p_fecha_folio, p_placa, p_infraccion, p_estado, p_vigilante, CURRENT_DATE, p_usu_inicial, p_zona, p_espacio
    );
    RETURN QUERY SELECT 'OK'::TEXT;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;