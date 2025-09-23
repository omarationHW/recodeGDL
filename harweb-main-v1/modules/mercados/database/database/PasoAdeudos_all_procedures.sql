-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PasoAdeudos
-- Generado: 2025-08-27 00:27:26
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_insertar_adeudo_local
-- Tipo: CRUD
-- Descripción: Inserta un registro de adeudo local para el tianguis (Mercado 214)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_insertar_adeudo_local(
    p_id_local INTEGER,
    p_ano INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC,
    p_actualizacion TIMESTAMP,
    p_id_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_adeudo_local (
        id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_ano, p_periodo, p_importe, p_actualizacion, p_id_usuario
    );
END;
$$;

-- ============================================

-- SP 2/2: sp_get_tianguis_locales
-- Tipo: Catalog
-- Descripción: Obtiene los locales del tianguis (Mercado 214) y su cuota para un año dado
-- --------------------------------------------

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

-- ============================================

