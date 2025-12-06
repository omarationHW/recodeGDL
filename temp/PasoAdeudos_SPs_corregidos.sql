-- ============================================
-- STORED PROCEDURES CORREGIDOS: PasoAdeudos
-- Base de datos: padron_licencias
-- Esquema: public
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SP: sp_get_tianguis_locales
-- Descripción: Obtiene los locales del tianguis (Mercado 214) con cuota
-- Retorna: TABLE con información completa del local y cuota
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_tianguis_locales(p_ano INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    superficie NUMERIC,
    vigencia VARCHAR,
    clave_cuota SMALLINT,
    importe_cuota NUMERIC
)
LANGUAGE plpgsql
AS $$
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
        l.nombre,
        l.domicilio,
        l.superficie,
        l.vigencia,
        c.clave_cuota,
        c.importe_cuota
    FROM padron_licencias.comun.ta_11_locales l
    LEFT JOIN mercados.public.ta_11_cuo_locales c
        ON c.clave_cuota = l.clave_cuota AND c.axo = p_ano
    WHERE l.oficina = 1
      AND l.num_mercado = 214
      AND l.vigencia = 'A';
END;
$$;

-- ============================================
-- SP: sp_insertar_adeudo_local
-- Descripción: Inserta adeudo local para tianguis
-- Retorna: TABLE con success y message
-- ============================================

CREATE OR REPLACE FUNCTION sp_insertar_adeudo_local(
    p_id_local INTEGER,
    p_ano INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC,
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_adeudo INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_adeudo INTEGER;
    v_existe BOOLEAN;
BEGIN
    -- Verificar si ya existe el adeudo
    SELECT EXISTS(
        SELECT 1
        FROM padron_licencias.comun.ta_11_adeudo_local
        WHERE id_local = p_id_local
          AND axo = p_ano
          AND periodo = p_periodo
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT
            FALSE,
            'El adeudo ya existe para este local, año y periodo'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el adeudo
    BEGIN
        INSERT INTO padron_licencias.comun.ta_11_adeudo_local (
            id_local, axo, periodo, importe, fecha_alta, id_usuario
        ) VALUES (
            p_id_local, p_ano, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario
        )
        RETURNING id_adeudo_local INTO v_id_adeudo;

        RETURN QUERY SELECT
            TRUE,
            'Adeudo insertado correctamente'::TEXT,
            v_id_adeudo;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                FALSE,
                ('Error al insertar: ' || SQLERRM)::TEXT,
                NULL::INTEGER;
    END;
END;
$$;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
