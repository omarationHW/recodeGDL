-- Stored Procedure: report_folios_adeudo_por_inspector
-- Tipo: Report
-- Descripción: Devuelve el conteo de folios de adeudo por inspector para una fecha dada.
-- Generado para formulario: sfrm_report_pagos
-- Fecha: 2025-08-27 14:28:30

CREATE OR REPLACE FUNCTION report_folios_adeudo_por_inspector(p_fechora date)
RETURNS TABLE (
    vigilante integer,
    inspector varchar(100),
    folios integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
    FROM ta14_folios_adeudo a
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    WHERE a.fecha_folio = p_fechora
    GROUP BY a.vigilante, inspector
    ORDER BY inspector;
END;
$$ LANGUAGE plpgsql;