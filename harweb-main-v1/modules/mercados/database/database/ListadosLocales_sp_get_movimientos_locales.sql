-- Stored Procedure: sp_get_movimientos_locales
-- Tipo: Report
-- Descripción: Obtiene los movimientos de locales en un rango de fechas y recaudadora
-- Generado para formulario: ListadosLocales
-- Fecha: 2025-08-27 00:08:33

CREATE OR REPLACE FUNCTION sp_get_movimientos_locales(p_fecha_desde DATE, p_fecha_hasta DATE, p_recaudadora_id INT)
RETURNS TABLE(
    id_movimiento INT,
    fecha TIMESTAMP,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    tipodescripcion VARCHAR(50),
    nombre VARCHAR(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_movimiento, m.fecha, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque,
        CASE m.tipo_movimiento
            WHEN 1 THEN 'ALTA'
            WHEN 2 THEN 'CAMBIO DE GIRO'
            WHEN 3 THEN 'CAMBIO FECHA ALTA'
            WHEN 4 THEN 'CAMBIO NOMBRE LOC.'
            WHEN 5 THEN 'CAMBIO DOMICILIO'
            WHEN 6 THEN 'CAMBIO DE ZONA'
            WHEN 7 THEN 'CAMBIO LOCAL,SUPERF.'
            WHEN 8 THEN 'BAJA TOTAL'
            WHEN 9 THEN 'BAJA ADMINISTRATIVA'
            WHEN 10 THEN 'BAJA POR ACUERDO'
            WHEN 11 THEN 'REACTIVACION'
            WHEN 12 THEN 'BLOQUEADO'
            WHEN 13 THEN 'REACTIVAR BLOQUEO'
            ELSE 'OTRO'
        END AS tipodescripcion,
        l.nombre
    FROM ta_11_movimientos m
    JOIN ta_11_locales l ON l.id_local = m.id_local
    WHERE m.fecha::date BETWEEN p_fecha_desde AND p_fecha_hasta
      AND l.oficina = p_recaudadora_id
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, m.axo_memo, m.numero_memo;
END;
$$ LANGUAGE plpgsql;