-- Stored Procedure: sp_localesmodif_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local por criterios únicos (oficina, mercado, categoria, seccion, local, letra, bloque)
-- Generado para formulario: LocalesModif
-- Fecha: 2025-08-27 00:10:52

CREATE OR REPLACE FUNCTION sp_localesmodif_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    nombre text,
    domicilio text,
    sector text,
    zona integer,
    descripcion_local text,
    superficie numeric,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    vigencia text,
    clave_cuota integer,
    bloqueo integer,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local::integer,
        l.oficina::integer,
        l.num_mercado::integer,
        l.categoria::integer,
        l.seccion::text,
        l.local::integer,
        l.letra_local::text,
        l.bloque::text,
        l.nombre::text,
        l.domicilio::text,
        l.sector::text,
        l.zona::integer,
        l.descripcion_local::text,
        l.superficie::numeric,
        l.giro::integer,
        l.fecha_alta::date,
        l.fecha_baja::date,
        l.vigencia::text,
        l.clave_cuota::integer,
        l.bloqueo::integer,
        l.id_usuario::integer
    FROM publico.ta_11_locales l
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NOT DISTINCT FROM NULLIF(p_letra_local, ''))
      AND (l.bloque IS NOT DISTINCT FROM NULLIF(p_bloque, ''))
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;