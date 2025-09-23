-- Stored Procedure: sp_get_movimientos_by_local
-- Tipo: Report
-- Descripción: Obtiene todos los movimientos de un local específico, incluyendo datos de usuario y local.
-- Generado para formulario: DatosMovimientos
-- Fecha: 2025-08-26 23:46:08

CREATE OR REPLACE FUNCTION sp_get_movimientos_by_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR,
    sector VARCHAR,
    zona SMALLINT,
    drescripcion_local VARCHAR,
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP,
    usuario VARCHAR,
    vigencia VARCHAR,
    clave_cuota SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo_memo, a.numero_memo, a.nombre, a.sector, a.zona, a.drescripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.tipo_movimiento, a.fecha, b.usuario, a.vigencia, a.clave_cuota, c.oficina, c.num_mercado, c.categoria, c.seccion
    FROM ta_11_movimientos a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON c.id_local = a.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.fecha;
END;
$$ LANGUAGE plpgsql;