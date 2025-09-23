-- Stored Procedure: insert_pubadeudo
-- Tipo: CRUD
-- Descripción: Inserta un nuevo adeudo para un estacionamiento
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE PROCEDURE insert_pubadeudo(
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer,
    p_concepto varchar,
    p_ade_importe numeric,
    p_id_usuario integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO pubadeudo (fecha_at, pubmain_id, axo, mes, tipo, concepto, ade_importe, ade_descto, id_usuario)
    VALUES (CURRENT_DATE, p_pubmain_id, p_axo, p_mes, 2, p_concepto, p_ade_importe, 0, p_id_usuario);
END;
$$;