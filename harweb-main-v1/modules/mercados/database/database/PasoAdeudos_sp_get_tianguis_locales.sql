-- Stored Procedure: sp_get_tianguis_locales
-- Tipo: Catalog
-- Descripción: Obtiene los locales del tianguis (Mercado 214) y su cuota para un año dado
-- Generado para formulario: PasoAdeudos
-- Fecha: 2025-08-27 00:27:26

CREATE OR REPLACE FUNCTION sp_get_tianguis_locales(p_ano INTEGER)
RETURNS TABLE (
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR,
    arrendatario VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    zona SMALLINT,
    descripcion_local VARCHAR,
    superficie NUMERIC,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR,
    id_usuario INTEGER,
    clave_cuota_local SMALLINT,
    bloqueo SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.clave_cuota, b.importe_cuota, a.*
    FROM ta_11_locales a
    JOIN ta_11_cuo_locales b ON b.clave_cuota = a.clave_cuota AND b.axo = p_ano
    WHERE a.num_mercado = 214;
END;
$$ LANGUAGE plpgsql;