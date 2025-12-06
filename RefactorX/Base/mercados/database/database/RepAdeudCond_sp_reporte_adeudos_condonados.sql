-- =============================================
-- SP: sp_reporte_adeudos_condonados
-- Descripción: Reporte de adeudos de locales que han sido condonados
-- Componente: RepAdeudCond.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_reporte_adeudos_condonados(INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_reporte_adeudos_condonados(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_mercado INTEGER DEFAULT NULL
)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(2),
    nombre VARCHAR(60),
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    clave_canc CHAR(1),
    observacion CHAR(60),
    fecha_alta TIMESTAMP,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        c.axo,
        c.periodo,
        c.importe,
        c.clave_canc,
        c.observacion,
        c.fecha_alta,
        COALESCE(u.nombre, 'N/A')::VARCHAR as usuario
    FROM
        publico.ta_11_ade_loc_canc c
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = c.id_local
    LEFT JOIN
        public.usuarios u ON u.id = c.id_usuario
    WHERE
        l.oficina = p_oficina
        AND c.axo = p_axo
        AND c.periodo = p_periodo
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
    ORDER BY
        c.fecha_alta DESC, l.num_mercado, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_reporte_adeudos_condonados(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Genera reporte de adeudos de locales que han sido condonados.
Parámetros: p_oficina (recaudadora), p_axo (año), p_periodo (mes), p_mercado (opcional).
Retorna: información de locales con adeudos condonados incluyendo clave de condonación y observaciones.';
