-- Stored Procedure: sp_get_adeudos_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de locales para un año, oficina y periodo dados.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 22:39:11

CREATE OR REPLACE FUNCTION sp_get_adeudos_locales(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie FLOAT,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    local INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota,
           SUM(a.importe) AS adeudo, d.recaudadora, e.descripcion, c.local
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales c ON a.id_local = c.id_local
    JOIN ta_12_recaudadoras d ON d.id_rec = c.oficina
    JOIN ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo = p_axo
      AND c.oficina = p_oficina
      AND a.periodo <= p_periodo
      AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion DESC, c.local, c.letra_local, c.bloque;
END;
$$ LANGUAGE plpgsql;