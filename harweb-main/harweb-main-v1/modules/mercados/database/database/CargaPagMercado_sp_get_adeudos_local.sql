-- Stored Procedure: sp_get_adeudos_local
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos de un local específico
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(
    p_oficina integer,
    p_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer
) RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
           a.axo, a.periodo, a.importe, a.fecha_alta, b.usuario
    FROM ta_11_adeudo_local a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON a.id_local = c.id_local
    WHERE c.oficina = p_oficina
      AND c.num_mercado = p_mercado
      AND c.categoria = p_categoria
      AND c.seccion = p_seccion
      AND c.local = p_local
      AND c.vigencia = 'A'
      AND c.bloqueo < 4
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;