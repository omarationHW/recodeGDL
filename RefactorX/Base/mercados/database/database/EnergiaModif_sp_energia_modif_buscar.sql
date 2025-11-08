-- Stored Procedure: sp_energia_modif_buscar
-- Tipo: CRUD
-- Descripción: Busca el registro de energía para un local específico
-- Generado para formulario: EnergiaModif
-- Fecha: 2025-08-26 23:56:17

CREATE OR REPLACE FUNCTION sp_energia_modif_buscar(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_energia integer,
    id_local integer,
    cve_consumo varchar,
    local_adicional varchar,
    cantidad numeric,
    vigencia varchar,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_energia, e.id_local, e.cve_consumo, e.local_adicional, e.cantidad, e.vigencia, e.fecha_alta, e.fecha_baja, e.fecha_modificacion, e.id_usuario
    FROM ta_11_locales l
    JOIN ta_11_energia e ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (l.bloque IS NOT DISTINCT FROM p_bloque)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;