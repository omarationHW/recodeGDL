-- Stored Procedure: sp_catalogo_mercados_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de mercado
-- Generado para formulario: CatalogoMercados
-- Fecha: 2025-08-26 23:04:40

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_delete(
    p_oficina smallint,
    p_num_mercado_nvo smallint
) RETURNS TABLE (result text) AS $$
BEGIN
    DELETE FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;