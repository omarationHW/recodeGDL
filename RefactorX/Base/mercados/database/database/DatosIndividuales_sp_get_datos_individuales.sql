-- Stored Procedure: sp_get_datos_individuales
-- Tipo: Catalog
-- Descripción: Obtiene los datos individuales de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

DROP FUNCTION IF EXISTS sp_get_datos_individuales(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_datos_individuales(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(2),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(60),
    arrendatario VARCHAR(30),
    domicilio VARCHAR(70),
    sector CHAR(1),
    zona SMALLINT,
    descripcion_local CHAR(20),
    superficie NUMERIC,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia CHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    bloqueo SMALLINT,
    observacion VARCHAR(250),
    num_mercado_nvo SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.id_contribuy_prop,
        l.id_contribuy_renta,
        l.nombre,
        l.arrendatario,
        l.domicilio,
        l.sector,
        l.zona,
        l.descripcion_local,
        l.superficie,
        l.giro,
        l.fecha_alta,
        l.fecha_baja,
        l.fecha_modificacion,
        l.vigencia,
        l.id_usuario,
        l.clave_cuota,
        l.bloqueo,
        l.observacion,
        m.num_mercado_nvo
    FROM publico.ta_11_locales l
    LEFT JOIN public.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;