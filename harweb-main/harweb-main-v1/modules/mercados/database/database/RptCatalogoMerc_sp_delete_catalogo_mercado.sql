-- Stored Procedure: sp_delete_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Elimina un registro del catálogo de mercados.
-- Generado para formulario: RptCatalogoMerc
-- Fecha: 2025-08-27 00:48:02

CREATE OR REPLACE FUNCTION sp_delete_catalogo_mercado(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT
) RETURNS VOID AS $$
BEGIN
    DELETE FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;