-- Stored Procedure: sp_cpe_buscar_adeudos
-- Tipo: CRUD
-- Descripción: Busca adeudos de energía eléctrica para un rango de locales
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_buscar_adeudos(
    p_ofi SMALLINT, p_mer SMALLINT, p_cat SMALLINT, p_sec VARCHAR, p_loc1 SMALLINT, p_loc2 SMALLINT
) RETURNS TABLE(
    id_energia INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    cve_consumo VARCHAR,
    cantidad FLOAT,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    partida VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_energia, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           d.cve_consumo, d.cantidad, a.axo, a.periodo, a.importe, '' AS partida
    FROM ta_11_adeudo_energ a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON c.id_local = d.id_local
    JOIN ta_11_energia d ON d.id_energia = a.id_energia
    WHERE c.oficina = p_ofi
      AND c.num_mercado = p_mer
      AND c.categoria = p_cat
      AND c.seccion = p_sec
      AND c.local BETWEEN p_loc1 AND p_loc2
      AND d.vigencia = 'A'
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;