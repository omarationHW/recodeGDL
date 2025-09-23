-- Stored Procedure: sp_emisionlocales_emitir_recibos
-- Tipo: CRUD
-- Descripción: Genera la emisión de recibos para un mercado/oficina/año/periodo
-- Generado para formulario: EmisionLocales
-- Fecha: 2025-08-26 23:54:25

CREATE OR REPLACE FUNCTION sp_emisionlocales_emitir_recibos(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    local INTEGER,
    nombre VARCHAR,
    descripcion_local VARCHAR,
    superficie FLOAT,
    renta NUMERIC,
    subtotal NUMERIC,
    meses VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.local,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
             WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
             ELSE l.superficie * c.importe_cuota END AS renta,
        0 AS subtotal, -- Calculado en frontend o en otro SP
        '' AS meses
    FROM ta_11_locales l
    JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    JOIN ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_mercado
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
      AND l.id_local NOT IN (
        SELECT id_local FROM ta_11_pagos_local WHERE id_local = l.id_local AND axo = p_axo AND periodo = p_periodo
      )
      AND l.id_local NOT IN (
        SELECT id_local FROM ta_11_ade_loc_canc WHERE id_local = l.id_local AND axo = p_axo AND periodo = p_periodo
      )
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;