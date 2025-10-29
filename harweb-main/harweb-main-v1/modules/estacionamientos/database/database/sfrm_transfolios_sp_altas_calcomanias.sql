-- Stored Procedure: sp_altas_calcomanias
-- Tipo: CRUD
-- Descripción: Inserta una calcomanía sin propietario en ta14_calco.
-- Generado para formulario: sfrm_transfolios
-- Fecha: 2025-08-27 14:33:28

CREATE OR REPLACE FUNCTION sp_altas_calcomanias(
    p_axo SMALLINT,
    p_calco INTEGER,
    p_status VARCHAR,
    p_turno VARCHAR,
    p_fecini DATE,
    p_fecfin DATE,
    p_placa VARCHAR,
    p_propie INTEGER,
    p_usu INTEGER
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    INSERT INTO ta14_calco(
        axo, num_calco, tipo, turno, fecha_inicial, fecha_fin, placa, propietario, fec_cap, usu_inicial
    ) VALUES (
        p_axo, p_calco, p_status, p_turno, p_fecini, p_fecfin, p_placa, p_propie, CURRENT_DATE, p_usu
    );
    RETURN QUERY SELECT 1 AS result, 'Insertado correctamente' AS msg;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0 AS result, SQLERRM AS msg;
END;
$$ LANGUAGE plpgsql;