-- Stored Procedure: sp_catalogo_mercados_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de mercado
-- Generado para formulario: CatalogoMercados
-- Fecha: 2025-08-26 23:04:40

CREATE OR REPLACE FUNCTION sp_catalogo_mercados_create(
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
    INSERT INTO ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, p_descripcion, p_cuenta_ingreso, p_cuenta_energia, p_id_zona, p_tipo_emision
    );
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;