-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptMovimientos
-- SP: sp_get_movimientos_locales
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS sp_get_movimientos_locales(date, date, integer);

CREATE OR REPLACE FUNCTION sp_get_movimientos_locales(
    p_fecha_desde date,
    p_fecha_hasta date,
    p_recaudadora_id integer
)
RETURNS TABLE (
    id_movimiento integer,
    fecha timestamp,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local integer,
    letra_local varchar(1),
    bloque varchar(1),
    tipodescripcion varchar(50),
    nombre varchar(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.id_movimiento,
        m.fecha,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        CASE m.tipo_movimiento
            WHEN 1 THEN 'ALTA'::varchar(50)
            WHEN 2 THEN 'CAMBIO DE GIRO'::varchar(50)
            WHEN 3 THEN 'CAMBIO FECHA ALTA'::varchar(50)
            WHEN 4 THEN 'CAMBIO NOMBRE LOC.'::varchar(50)
            WHEN 5 THEN 'CAMBIO DOMICILIO'::varchar(50)
            WHEN 6 THEN 'CAMBIO DE ZONA'::varchar(50)
            WHEN 7 THEN 'CAMBIO LOCAL,SUPERF.'::varchar(50)
            WHEN 8 THEN 'BAJA TOTAL'::varchar(50)
            WHEN 9 THEN 'BAJA ADMINISTRATIVA'::varchar(50)
            WHEN 10 THEN 'BAJA POR ACUERDO'::varchar(50)
            WHEN 11 THEN 'REACTIVACION'::varchar(50)
            WHEN 12 THEN 'BLOQUEADO'::varchar(50)
            WHEN 13 THEN 'REACTIVAR BLOQUEO'::varchar(50)
            ELSE 'OTRO'::varchar(50)
        END AS tipodescripcion,
        l.nombre
    FROM mercados.public.ta_11_movimientos m
    JOIN padron_licencias.comun.ta_11_locales l
        ON l.id_local = m.id_local
    WHERE m.fecha::date BETWEEN p_fecha_desde AND p_fecha_hasta
      AND l.oficina = p_recaudadora_id
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, m.axo_memo, m.numero_memo;
END;
$$ LANGUAGE plpgsql;
