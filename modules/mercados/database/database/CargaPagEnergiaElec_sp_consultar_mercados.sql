-- Stored Procedure: sp_consultar_mercados
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una oficina
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 22:53:19

CREATE OR REPLACE FUNCTION sp_consultar_mercados(
    p_oficina integer
) RETURNS TABLE(
    id integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;