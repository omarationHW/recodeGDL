-- Stored Procedure: sp_cpe_cajas_por_oficina
-- Tipo: Catalog
-- Descripción: Devuelve las cajas disponibles para una oficina
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_cajas_por_oficina(p_oficina SMALLINT)
RETURNS TABLE(id INTEGER, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, caja FROM ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja ASC;
END;
$$ LANGUAGE plpgsql;