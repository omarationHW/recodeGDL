-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: listanotificacionesfrm
-- Generado: 2025-08-27 21:26:15
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_listanotificaciones_report
-- Tipo: Report
-- Descripción: Genera el listado de notificaciones/requerimientos/secuestros de multas según los filtros y orden seleccionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listanotificaciones_report(
    p_axo integer,
    p_reca integer,
    p_inicio integer,
    p_final integer,
    p_tipo character varying,
    p_orden character varying
)
RETURNS TABLE (
    abrevia text,
    axo_acta integer,
    num_acta integer,
    num_lote integer,
    folioreq integer
) AS $$
BEGIN
    IF p_orden = 'lote' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
        ORDER BY m.num_lote, m.num_acta;
    ELSIF p_orden = 'vigentes' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY r.folioreq;
    ELSIF p_orden = 'dependencia' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_reca
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY d.abrevia, m.axo_acta, m.num_acta;
    ELSE
        RAISE EXCEPTION 'Orden no válido: %', p_orden;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

