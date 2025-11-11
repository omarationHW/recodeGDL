-- SP: sp_otras_oblig_buscar_adeudos
-- Descripción: Obtiene el detalle de adeudos por periodo con recargos y descuentos
-- Parámetros: par_tabla INTEGER, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER
-- Retorna: Adeudos detallados por concepto, año y mes
-- Prioridad: CRÍTICA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_adeudos(
    par_tabla INTEGER,
    par_id_datos INTEGER,
    par_aso INTEGER,
    par_mes INTEGER
)
RETURNS TABLE (
    concepto VARCHAR(100),
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC(12,2),
    recargos_pagar NUMERIC(12,2),
    dscto_importe NUMERIC(12,2),
    dscto_recargos NUMERIC(12,2),
    actualizacion_pagar NUMERIC(12,2),
    total_periodo NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(c.nombre, 'Sin concepto')::VARCHAR(100) AS concepto,
        a.axo,
        a.mes,
        COALESCE(a.importe_pagar, 0)::NUMERIC(12,2),
        COALESCE(a.recargos_pagar, 0)::NUMERIC(12,2),
        COALESCE(a.dscto_importe, 0)::NUMERIC(12,2),
        COALESCE(a.dscto_recargos, 0)::NUMERIC(12,2),
        COALESCE(a.actualizacion_pagar, 0)::NUMERIC(12,2),
        (COALESCE(a.importe_pagar, 0) +
         COALESCE(a.recargos_pagar, 0) -
         COALESCE(a.dscto_importe, 0) -
         COALESCE(a.dscto_recargos, 0) +
         COALESCE(a.actualizacion_pagar, 0))::NUMERIC(12,2) AS total_periodo
    FROM t_34_adeudos a
    INNER JOIN t_34_conceptos c ON a.id_34_conceptos = c.id_34_conceptos
    WHERE a.id_34_datos = par_id_datos
      AND a.status IN ('P', 'A') -- Pendiente o Activo
      AND (a.axo < par_aso OR (a.axo = par_aso AND a.mes <= par_mes))
    ORDER BY c.nombre, a.axo, a.mes;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_buscar_adeudos(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Obtiene el detalle de adeudos pendientes hasta el año/mes especificado, incluyendo importes, recargos, descuentos y actualización';
