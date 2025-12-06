-- Stored Procedure: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un mercado por oficina y num_mercado
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

DROP FUNCTION IF EXISTS sp_get_mercado(smallint, smallint);

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    id_mercado integer,
    oficina smallint,
    num_mercado_nvo smallint,
    num_mercado_old smallint,
    descripcion varchar(30),
    domicilio varchar(100),
    zona smallint,
    vigencia char(1),
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_mercado, a.oficina, a.num_mercado_nvo, a.num_mercado_old, a.descripcion,
           a.domicilio, a.zona, a.vigencia, a.fecha_alta, a.id_usuario
    FROM public.ta_11_mercados a
    WHERE a.oficina = p_oficina AND a.num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;