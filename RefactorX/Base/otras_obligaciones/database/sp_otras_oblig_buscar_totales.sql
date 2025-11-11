-- SP: sp_otras_oblig_buscar_totales
-- Descripción: Obtiene los totales agrupados por concepto
-- Parámetros: par_tabla INTEGER, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER
-- Retorna: Totales de adeudos agrupados por cuenta/concepto
-- Prioridad: CRÍTICA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_totales(
    par_tabla INTEGER,
    par_id_datos INTEGER,
    par_aso INTEGER,
    par_mes INTEGER
)
RETURNS TABLE (
    concepto VARCHAR(100),
    cuenta INTEGER,
    importe NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(c.nombre, 'Sin concepto')::VARCHAR(100) AS concepto,
        COUNT(*)::INTEGER AS cuenta,
        SUM(
            COALESCE(a.importe_pagar, 0) +
            COALESCE(a.recargos_pagar, 0) -
            COALESCE(a.dscto_importe, 0) -
            COALESCE(a.dscto_recargos, 0) +
            COALESCE(a.actualizacion_pagar, 0)
        )::NUMERIC(12,2) AS importe
    FROM t_34_adeudos a
    INNER JOIN t_34_conceptos c ON a.id_34_conceptos = c.id_34_conceptos
    WHERE a.id_34_datos = par_id_datos
      AND a.status IN ('P', 'A') -- Pendiente o Activo
      AND (a.axo < par_aso OR (a.axo = par_aso AND a.mes <= par_mes))
    GROUP BY c.id_34_conceptos, c.nombre
    HAVING SUM(
        COALESCE(a.importe_pagar, 0) +
        COALESCE(a.recargos_pagar, 0) -
        COALESCE(a.dscto_importe, 0) -
        COALESCE(a.dscto_recargos, 0) +
        COALESCE(a.actualizacion_pagar, 0)
    ) > 0
    ORDER BY c.nombre;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_buscar_totales(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Obtiene los totales de adeudos agrupados por concepto, incluyendo cantidad de periodos e importe total';
