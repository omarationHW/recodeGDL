-- Stored Procedure: sp_firmas_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de firmas en ta_17_firmaconv
-- Generado para formulario: FirmasMntto
-- Fecha: 2025-08-27 14:39:01

CREATE OR REPLACE PROCEDURE sp_firmas_delete(
    p_recaudadora INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_17_firmaconv WHERE recaudadora = p_recaudadora;
END;
$$;