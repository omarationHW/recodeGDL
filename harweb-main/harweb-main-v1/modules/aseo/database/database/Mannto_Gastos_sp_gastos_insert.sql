-- Stored Procedure: sp_gastos_insert
-- Tipo: CRUD
-- Descripción: Inserta un registro de gastos en ta_16_gastos
-- Generado para formulario: Mannto_Gastos
-- Fecha: 2025-08-27 14:44:22

CREATE OR REPLACE PROCEDURE sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);
END;
$$;