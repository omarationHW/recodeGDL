-- Stored Procedure: sp_recaudadoras_delete
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- Generado para formulario: Mannto_Recaudadoras
-- Fecha: 2025-08-27 14:49:12

CREATE OR REPLACE PROCEDURE sp_recaudadoras_delete(p_num_rec SMALLINT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_contratos WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;