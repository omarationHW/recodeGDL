-- Stored Procedure: sp_get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una recaudadora que tienen energía eléctrica.
-- Generado para formulario: PadronEnergia
-- Fecha: 2025-08-27 00:17:27

CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(p_id_rec integer)
RETURNS TABLE(num_mercado_nvo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_id_rec AND cuenta_energia > 0 ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;