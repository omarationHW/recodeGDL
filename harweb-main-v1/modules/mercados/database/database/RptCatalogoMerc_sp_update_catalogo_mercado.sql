-- Stored Procedure: sp_update_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en el catálogo de mercados.
-- Generado para formulario: RptCatalogoMerc
-- Fecha: 2025-08-27 00:48:02

CREATE OR REPLACE FUNCTION sp_update_catalogo_mercado(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_cuenta_energia INTEGER,
    p_id_zona SMALLINT,
    p_tipo_emision VARCHAR,
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_11_mercados SET
        categoria = p_categoria,
        descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = p_cuenta_energia,
        id_zona = p_id_zona,
        tipo_emision = p_tipo_emision,
        id_usuario = p_usuario_id,
        fecha_modificacion = NOW()
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;