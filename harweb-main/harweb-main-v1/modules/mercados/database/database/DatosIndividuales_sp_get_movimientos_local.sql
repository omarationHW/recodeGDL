-- Stored Procedure: sp_get_movimientos_local
-- Tipo: Catalog
-- Descripción: Obtiene los movimientos de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_movimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_movimiento INTEGER,
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR(30),
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_movimiento, id_local, axo_memo, numero_memo, nombre, tipo_movimiento, fecha
    FROM ta_11_movimientos
    WHERE id_local = p_id_local
    ORDER BY axo_memo, numero_memo;
END;
$$ LANGUAGE plpgsql;