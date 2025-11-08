-- Stored Procedure: sp_get_adeudos_tcultural
-- Tipo: Report
-- Descripción: Obtiene la lista de adeudos del Tianguis Cultural para un rango de folios y periodo/año.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 23:03:00

CREATE OR REPLACE FUNCTION sp_get_adeudos_tcultural(
    p_local_desde INTEGER,
    p_local_hasta INTEGER,
    p_periodo SMALLINT,
    p_axo SMALLINT,
    p_user_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    local INTEGER,
    nombre VARCHAR,
    descuento NUMERIC,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.local,
        t."Nombre" AS nombre,
        t."Descuento" AS descuento,
        a.axo,
        a.periodo,
        a.importe
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales l ON a.id_local = l.id_local
    LEFT JOIN cobrotrimestral t ON t."Folio" = l.local
    WHERE l.oficina = 1
      AND l.num_mercado = 214
      AND l.categoria = 1
      AND l.seccion = 'SS'
      AND l.local BETWEEN p_local_desde AND p_local_hasta
      AND a.periodo = p_periodo
      AND a.axo = p_axo
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
    ORDER BY l.local ASC;
END;
$$ LANGUAGE plpgsql;