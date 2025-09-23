-- Stored Procedure: sp_listanotificaciones_reporte
-- Tipo: Report
-- Descripción: Devuelve el listado de notificaciones/requerimientos/secuestros de multas según los parámetros de búsqueda y orden.
-- Generado para formulario: listanotificacionesfrm
-- Fecha: 2025-08-27 12:54:10

CREATE OR REPLACE FUNCTION sp_listanotificaciones_reporte(
    p_tipo CHAR(1),
    p_axo INTEGER,
    p_recaud INTEGER,
    p_inicio INTEGER,
    p_final INTEGER,
    p_orden TEXT DEFAULT 'lote'
)
RETURNS TABLE (
    abrevia TEXT,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_lote INTEGER,
    folioreq INTEGER
) AS $$
BEGIN
    IF p_orden = 'lote' THEN
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_recaud
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
          AND r.recaud = p_recaud
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY r.folioreq;
    ELSE -- dependencia
        RETURN QUERY
        SELECT d.abrevia, m.axo_acta, m.num_acta, m.num_lote, r.folioreq
        FROM reqmultas r
        JOIN multas m ON m.id_multa = r.id_multa
        LEFT JOIN c_dependencias d ON d.id_dependencia = m.id_dependencia
        WHERE r.axoreq = p_axo
          AND r.recaud = p_recaud
          AND r.folioreq BETWEEN p_inicio AND p_final
          AND r.tipo = p_tipo
          AND m.cvepago IS NULL
          AND m.fecha_cancelacion IS NULL
        ORDER BY d.abrevia, m.axo_acta, m.num_acta;
    END IF;
END;
$$ LANGUAGE plpgsql;