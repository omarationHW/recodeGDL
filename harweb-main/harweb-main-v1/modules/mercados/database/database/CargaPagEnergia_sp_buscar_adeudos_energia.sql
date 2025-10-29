-- Stored Procedure: sp_buscar_adeudos_energia
-- Tipo: CRUD
-- Descripción: Busca los adeudos de energía eléctrica para un local específico.
-- Generado para formulario: CargaPagEnergia
-- Fecha: 2025-08-26 22:51:22

CREATE OR REPLACE FUNCTION sp_buscar_adeudos_energia(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER
) RETURNS TABLE (
    id_adeudo_energia INTEGER,
    id_energia INTEGER,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    axo INTEGER,
    periodo INTEGER,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    importe NUMERIC,
    fecha_alta TIMESTAMP,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_adeudo_energia, a.id_energia, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, a.axo, a.periodo, a.cve_consumo, a.cantidad, a.importe, a.fecha_alta, u.usuario
    FROM ta_11_adeudo_energ a
    JOIN ta_11_energia d ON a.id_energia = d.id_energia
    JOIN ta_11_locales b ON d.id_local = b.id_local
    JOIN ta_12_passwords u ON a.id_usuario = u.id_usuario
    WHERE b.oficina = p_oficina
      AND b.num_mercado = p_mercado
      AND b.categoria = p_categoria
      AND b.seccion = p_seccion
      AND b.local = p_local
      AND NOT EXISTS (
        SELECT 1 FROM ta_11_pago_energia pe
        WHERE pe.id_energia = a.id_energia AND pe.axo = a.axo AND pe.periodo = a.periodo
      )
    ORDER BY a.id_energia, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;