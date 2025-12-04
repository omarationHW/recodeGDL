-- ============================================
-- SP: sp_get_movimientos_locales
-- Descripción: Obtiene el reporte de movimientos de locales en un período específico por recaudadora
-- Esquemas: mercados.public (ta_11_movimientos), padron_licencias.comun (ta_11_locales, ta_12_passwords)
-- Componente: RptMovimientos.vue
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_movimientos_locales(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora_id SMALLINT
)
RETURNS TABLE (
    id_movimiento INTEGER,
    fecha TIMESTAMP,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local CHAR(1),
    bloque CHAR(3),
    tipo_movimiento SMALLINT,
    tipodescripcion VARCHAR(30),
    nombre VARCHAR(60),
    axo_memo SMALLINT,
    numero_memo INTEGER,
    id_local INTEGER,
    usuario VARCHAR(20),
    giro SMALLINT,
    superficie NUMERIC,
    clave_cuota SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    vigencia CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_movimiento,
        a.fecha,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        a.tipo_movimiento,
        CASE a.tipo_movimiento
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
            ELSE 'DESCONOCIDO'
        END::VARCHAR(30) AS tipodescripcion,
        a.nombre::VARCHAR(60),
        a.axo_memo,
        a.numero_memo,
        a.id_local,
        COALESCE(c.usuario, 'N/A')::VARCHAR(20) AS usuario,
        a.giro,
        a.superficie,
        a.clave_cuota,
        a.fecha_alta,
        a.fecha_baja,
        a.vigencia
    FROM mercados.ta_11_movimientos a
    INNER JOIN comun.ta_11_locales b ON a.id_local = b.id_local
    LEFT JOIN comun.ta_12_passwords c ON b.id_usuario = c.id_usuario
    WHERE DATE(a.fecha) BETWEEN p_fecha_desde AND p_fecha_hasta
      AND b.oficina = p_recaudadora_id
    ORDER BY b.oficina ASC, b.num_mercado ASC, b.categoria ASC, b.seccion ASC,
             b.local ASC, b.letra_local ASC, b.bloque ASC, a.axo_memo ASC, a.numero_memo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TEST DATA
-- ============================================
-- SELECT * FROM sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1);
