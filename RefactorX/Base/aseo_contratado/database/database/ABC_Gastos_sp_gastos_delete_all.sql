-- Stored Procedure: sp_gastos_delete_all
-- Tipo: Catalog
-- Descripción: Elimina todos los registros de gastos (solo debe haber uno)
-- Generado para formulario: ABC_Gastos
-- Fecha: 2025-08-27 13:24:08

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_16_gastos;
END;
$$;