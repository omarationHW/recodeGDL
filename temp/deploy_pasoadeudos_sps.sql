-- ============================================================
-- DESPLIEGUE DE SPs CORREGIDOS PARA PasoAdeudos
-- Fecha: 2025-12-04
-- ============================================================

-- ============================================================
-- 1. SP: sp_get_tianguis_locales
-- ============================================================

DROP FUNCTION IF EXISTS public.sp_get_tianguis_locales(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_get_tianguis_locales(p_ano INTEGER)
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
    FROM comun.ta_11_locales a
    JOIN comun.ta_11_cuo_locales b ON b.clave_cuota = a.clave_cuota AND b.axo = p_ano
    WHERE a.num_mercado = 214;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_tianguis_locales(INTEGER) IS
'Obtiene los locales del tianguis (Mercado 214) y su cuota para un año dado';

-- ============================================================
-- 2. SP: sp_insertar_adeudo_local
-- ============================================================

DROP FUNCTION IF EXISTS public.sp_insertar_adeudo_local(INTEGER, INTEGER, INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_insertar_adeudo_local(
    p_id_local INTEGER,
    p_ano INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Verificar si ya existe el adeudo
    SELECT COUNT(*) INTO v_existe
    FROM comun.ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_ano
      AND periodo = p_periodo;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un adeudo para este local en el periodo especificado';
        RETURN;
    END IF;

    -- Insertar el adeudo
    INSERT INTO comun.ta_11_adeudo_local (
        id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        p_id_local, p_ano, p_periodo, p_importe, NOW(), p_id_usuario
    );

    RETURN QUERY SELECT true, 'Adeudo insertado correctamente';
END;
$$;

COMMENT ON FUNCTION public.sp_insertar_adeudo_local(INTEGER, INTEGER, INTEGER, NUMERIC, INTEGER) IS
'Inserta un registro de adeudo local para el tianguis (Mercado 214)';

-- ============================================================
-- FIN DEL DESPLIEGUE
-- ============================================================
