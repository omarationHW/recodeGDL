-- Stored Procedure: sp_get_adeudos_local
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos de un local para la carga de pagos especial.
-- Generado para formulario: CargaPagEspecial
-- Fecha: 2025-08-26 22:54:46

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR,
    p_local SMALLINT
)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    partida VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           a.axo, a.periodo, a.importe, '' AS partida
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales c ON a.id_local = c.id_local
    WHERE c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND c.categoria = p_categoria
      AND c.seccion = p_seccion
      AND c.local = p_local
      AND c.vigencia = 'A'
      AND c.bloqueo < 4
      AND ((a.axo > 2005 OR (a.periodo >= 9 AND a.axo = 2005)) AND (a.axo < 2005 OR (a.periodo <= 10 AND a.axo = 2005)))
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;