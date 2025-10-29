-- Stored Procedure: sp_get_cajas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cajas/operaciones.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 13:55:16

CREATE OR REPLACE FUNCTION sp_get_cajas()
RETURNS TABLE(
    id_rec smallint,
    caja text,
    operacion integer,
    id_usuario integer,
    tip_impresora text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, caja, operacion, id_usuario, tip_impresora
    FROM ta_12_operaciones
    ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;