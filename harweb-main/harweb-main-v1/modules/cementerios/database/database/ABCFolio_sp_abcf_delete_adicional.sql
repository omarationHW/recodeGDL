-- Stored Procedure: sp_abcf_delete_adicional
-- Tipo: CRUD
-- Descripción: Elimina los datos adicionales de un folio.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE PROCEDURE sp_abcf_delete_adicional(p_folio INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$;