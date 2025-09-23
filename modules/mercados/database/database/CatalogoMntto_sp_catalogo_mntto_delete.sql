-- Stored Procedure: sp_catalogo_mntto_delete
-- Tipo: CRUD
-- Descripción: Elimina un mercado por oficina y num_mercado_nvo
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 19:13:37

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_delete(
    p_oficina INTEGER,
    p_num_mercado_nvo INTEGER
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    DELETE FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;