-- Stored Procedure: delete_pubadeudo
-- Tipo: CRUD
-- Descripción: Elimina adeudos hasta un año/mes específico para un estacionamiento
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE PROCEDURE delete_pubadeudo(
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM pubadeudo
    WHERE pubmain_id = p_pubmain_id
      AND ((axo * 10) + mes) <= ((p_axo * 10) + p_mes)
      AND tipo = 10;
END;
$$;