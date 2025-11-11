-- SP: sp_otras_oblig_buscar_pagados
-- Descripción: Obtiene el historial de pagos realizados
-- Parámetros: p_Control INTEGER (id_34_datos)
-- Retorna: Historial de pagos con conceptos y fechas
-- Prioridad: ALTA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_pagados(
    p_Control INTEGER
)
RETURNS TABLE (
    id_pago INTEGER,
    fecha_pago DATE,
    concepto VARCHAR(100),
    axo INTEGER,
    mes INTEGER,
    importe_pagado NUMERIC(12,2),
    recargos_pagados NUMERIC(12,2),
    actualizacion_pagada NUMERIC(12,2),
    total_pagado NUMERIC(12,2),
    recaudadora VARCHAR(100),
    caja VARCHAR(50),
    folio_recibo VARCHAR(50),
    usuario VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_34_pagos AS id_pago,
        p.fecha_pago,
        COALESCE(c.nombre, 'Sin concepto')::VARCHAR(100) AS concepto,
        p.axo,
        p.mes,
        COALESCE(p.importe_pagado, 0)::NUMERIC(12,2),
        COALESCE(p.recargos_pagados, 0)::NUMERIC(12,2),
        COALESCE(p.actualizacion_pagada, 0)::NUMERIC(12,2),
        (COALESCE(p.importe_pagado, 0) +
         COALESCE(p.recargos_pagados, 0) +
         COALESCE(p.actualizacion_pagada, 0))::NUMERIC(12,2) AS total_pagado,
        COALESCE(r.nombre, '')::VARCHAR(100) AS recaudadora,
        COALESCE(p.caja, '')::VARCHAR(50),
        COALESCE(p.folio_recibo, '')::VARCHAR(50),
        COALESCE(u.nombre, '')::VARCHAR(100) AS usuario
    FROM t_34_pagos p
    INNER JOIN t_34_conceptos c ON p.id_34_conceptos = c.id_34_conceptos
    LEFT JOIN t_recaudadoras r ON p.id_recaudadora = r.cve_recaud
    LEFT JOIN t_usuarios u ON p.id_usuario = u.id_usuario
    WHERE p.id_34_datos = p_Control
      AND p.status = 'P' -- Pagado
    ORDER BY p.fecha_pago DESC, p.axo DESC, p.mes DESC;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_buscar_pagados(INTEGER) IS
'Obtiene el historial completo de pagos realizados para un control específico, ordenados por fecha descendente';
