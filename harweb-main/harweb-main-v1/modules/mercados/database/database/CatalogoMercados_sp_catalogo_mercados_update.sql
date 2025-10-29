-- Stored Procedure: sp_catalogo_mercados_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de mercado existente
-- Generado para formulario: CatalogoMercados
-- Fecha: 2025-08-26 23:04:40

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_update(
    p_oficina smallint,
    p_num_mercado_nvo smallint,
    p_categoria smallint,
    p_descripcion varchar(30),
    p_cuenta_ingreso integer,
    p_cuenta_energia integer,
    p_id_zona smallint,
    p_tipo_emision char(1)
) RETURNS TABLE (result text) AS $$
BEGIN
    UPDATE ta_11_mercados SET
        categoria = p_categoria,
        descripcion = p_descripcion,
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = p_cuenta_energia,
        id_zona = p_id_zona,
        tipo_emision = p_tipo_emision
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;