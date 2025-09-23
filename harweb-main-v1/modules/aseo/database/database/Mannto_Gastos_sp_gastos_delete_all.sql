-- Stored Procedure: sp_gastos_delete_all
-- Tipo: CRUD
-- Descripción: Elimina todos los registros de ta_16_gastos (solo debe haber uno)
-- Generado para formulario: Mannto_Gastos
-- Fecha: 2025-08-27 14:44:22

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_16_gastos;
END;
$$;