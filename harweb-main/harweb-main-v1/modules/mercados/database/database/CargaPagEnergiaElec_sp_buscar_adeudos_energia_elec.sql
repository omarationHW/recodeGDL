-- Stored Procedure: sp_buscar_adeudos_energia_elec
-- Tipo: CRUD
-- Descripción: Busca los adeudos de energía eléctrica para un rango de locales
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 22:53:19

CREATE OR REPLACE FUNCTION sp_buscar_adeudos_energia_elec(
    p_oficina integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local_desde integer,
    p_local_hasta integer
) RETURNS TABLE(
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    cve_consumo varchar,
    cantidad numeric,
    axo integer,
    periodo integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_energia, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           d.cve_consumo, d.cantidad, a.axo, a.periodo, a.importe
    FROM ta_11_adeudo_energ a
    JOIN ta_11_locales c ON c.id_local = d.id_local
    JOIN ta_11_energia d ON d.id_energia = a.id_energia
    WHERE c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND c.categoria = p_categoria
      AND c.seccion = p_seccion
      AND c.local BETWEEN p_local_desde AND p_local_hasta
      AND d.vigencia = 'A'
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;