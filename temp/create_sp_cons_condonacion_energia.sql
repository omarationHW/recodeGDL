-- Stored Procedure: sp_cons_condonacion_energia
-- Descripción: Consulta las condonaciones de energía de un local específico
-- Autor: Sistema
-- Fecha: 2025-01-24

CREATE OR REPLACE FUNCTION sp_cons_condonacion_energia(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_condonacion integer,
    id_local integer,
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre_local varchar,
    arrendatario varchar,
    vigencia varchar,
    axo smallint,
    periodo smallint,
    fecha_condonacion timestamp,
    importe_original numeric,
    importe_condonado numeric,
    motivo varchar,
    observacion varchar,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_cancelacion as id_condonacion,
        l.id_local,
        c.id_energia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre as nombre_local,
        l.arrendatario,
        l.vigencia,
        c.axo,
        c.periodo,
        c.fecha_alta as fecha_condonacion,
        ae.importe as importe_original,
        c.importe as importe_condonado,
        c.clave_canc as motivo,
        c.observacion,
        u.usuario
    FROM ta_11_locales l
    INNER JOIN ta_11_adeudos_energia ae ON l.id_local = ae.id_local
    INNER JOIN ta_11_ade_ene_canc c ON ae.id_energia = c.id_energia
    LEFT JOIN ta_12_passwords u ON c.id_usuario = u.id_usuario
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local = p_letra_local OR (p_letra_local IS NULL AND l.letra_local IS NULL))
      AND (l.bloque = p_bloque OR (p_bloque IS NULL AND l.bloque IS NULL))
    ORDER BY c.axo DESC, c.periodo DESC;
END;
$$ LANGUAGE plpgsql;
