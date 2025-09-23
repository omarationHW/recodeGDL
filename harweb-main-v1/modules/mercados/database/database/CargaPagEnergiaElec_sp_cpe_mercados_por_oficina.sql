-- Stored Procedure: sp_cpe_mercados_por_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados disponibles para una oficina
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_mercados_por_oficina(p_oficina SMALLINT)
RETURNS TABLE(id INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;