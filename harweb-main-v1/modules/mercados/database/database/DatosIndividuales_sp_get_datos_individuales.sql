-- Stored Procedure: sp_get_datos_individuales
-- Tipo: Catalog
-- Descripción: Obtiene los datos individuales de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_datos_individuales(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(30),
    arrendatario VARCHAR(30),
    domicilio VARCHAR(40),
    sector VARCHAR(1),
    zona SMALLINT,
    descripcion_local VARCHAR(255),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    num_mercado_nvo SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.*, m.num_mercado_nvo
    FROM ta_11_locales l
    LEFT JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;