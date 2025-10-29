-- Stored Procedure: sp_cancelar_descuento_predial
-- Tipo: CRUD
-- Descripción: Cancela un descuento predial
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_predial(p_id INTEGER, p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE descpred SET status = 'C', fecbaja = NOW(), captbaja = p_usuario WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;