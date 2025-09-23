-- Stored Procedure: sp_get_meses_adeudo
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de un local para un año dado.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 22:39:11

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo(p_id_local INTEGER, p_axo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo
    ORDER BY id_local, axo, periodo;
END;
$$ LANGUAGE plpgsql;