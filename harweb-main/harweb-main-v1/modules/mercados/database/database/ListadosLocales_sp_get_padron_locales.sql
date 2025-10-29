-- Stored Procedure: sp_get_padron_locales
-- Tipo: Report
-- Descripción: Obtiene el padrón de locales para una recaudadora y mercado
-- Generado para formulario: ListadosLocales
-- Fecha: 2025-08-27 00:08:33

CREATE OR REPLACE FUNCTION sp_get_padron_locales(p_recaudadora_id INT, p_mercado_id INT)
RETURNS TABLE(
    id_local INT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie FLOAT,
    renta NUMERIC,
    vigencia VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.superficie,
        CASE 
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
            WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * fd.sabadosacum
            ELSE l.superficie * c.importe_cuota
        END AS renta,
        l.vigencia
    FROM ta_11_locales l
    JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    JOIN ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    LEFT JOIN ta_11_fecha_desc fd ON fd.mes = EXTRACT(MONTH FROM CURRENT_DATE)
    WHERE l.oficina = p_recaudadora_id AND l.num_mercado = p_mercado_id
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;