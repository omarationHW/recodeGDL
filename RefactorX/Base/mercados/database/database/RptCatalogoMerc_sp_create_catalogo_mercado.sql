-- Stored Procedure: sp_create_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en el catálogo de mercados.
-- Generado para formulario: RptCatalogoMerc
-- Fecha: 2025-08-27 00:48:02

CREATE OR REPLACE FUNCTION sp_create_catalogo_mercado(
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
    INSERT INTO ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision, id_usuario, fecha_alta
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, UPPER(p_descripcion), p_cuenta_ingreso, p_cuenta_energia, p_id_zona, p_tipo_emision, p_usuario_id, NOW()
    );
END;
$$ LANGUAGE plpgsql;