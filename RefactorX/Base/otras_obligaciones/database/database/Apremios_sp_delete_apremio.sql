-- Stored Procedure: sp_delete_apremio
-- Tipo: CRUD
-- Descripción: Elimina (o marca como no vigente) un registro de apremio.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-28 12:35:37

CREATE OR REPLACE FUNCTION sp_delete_apremio(id_control integer)
RETURNS VOID AS $$
BEGIN
    UPDATE ta_15_apremios SET vigencia = '0' WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;