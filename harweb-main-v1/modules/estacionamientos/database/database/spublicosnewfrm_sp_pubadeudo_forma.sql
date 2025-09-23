-- Stored Procedure: sp_pubadeudo_forma
-- Tipo: CRUD
-- Descripción: Alta de adeudo por formato (pubadeudo) para el estacionamiento público.
-- Generado para formulario: spublicosnewfrm
-- Fecha: 2025-08-27 14:50:43

CREATE OR REPLACE FUNCTION sp_pubadeudo_forma(
    pubmain_id integer,
    axo integer,
    mes integer,
    concepto varchar,
    ade_importe numeric,
    id_usuario integer
) RETURNS TABLE(result integer, resultstr varchar) AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO pubadeudo (
        fecha_at, pubmain_id, axo, mes, tipo, concepto, ade_importe, ade_descto, id_usuario
    ) VALUES (
        CURRENT_DATE, pubmain_id, axo, mes, 2, concepto, ade_importe, 0, id_usuario
    ) RETURNING id INTO new_id;
    result := 1;
    resultstr := 'Adeudo registrado';
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    result := 0;
    resultstr := 'Error: ' || SQLERRM;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;