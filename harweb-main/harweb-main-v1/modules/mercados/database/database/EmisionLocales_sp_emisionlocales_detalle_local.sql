-- Stored Procedure: sp_emisionlocales_detalle_local
-- Tipo: Report
-- Descripción: Devuelve el detalle completo de un local
-- Generado para formulario: EmisionLocales
-- Fecha: 2025-08-26 23:54:25

CREATE OR REPLACE FUNCTION sp_emisionlocales_detalle_local(p_id_local INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local SMALLINT,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    descripcion_local VARCHAR,
    superficie FLOAT,
    clave_cuota SMALLINT,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, descripcion_local, superficie, clave_cuota, vigencia, fecha_alta, fecha_baja
    FROM ta_11_locales
    WHERE id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;