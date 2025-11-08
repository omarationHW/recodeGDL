-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Condonacion
-- Generado: 2025-08-26 23:10:57
-- Total SPs: 4
-- ============================================

-- SP 1/4: buscar_local_condonacion
-- Tipo: CRUD
-- Descripción: Busca un local activo y vigente para condonación según los parámetros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_local_condonacion(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie numeric,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, descripcion_local, superficie, clave_cuota
    FROM public.ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local = p_letra_local OR (p_letra_local IS NULL AND letra_local IS NULL))
      AND (bloque = p_bloque OR (p_bloque IS NULL AND bloque IS NULL))
      AND vigencia = 'A' AND bloqueo < 4
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: spd_11_condonacion
-- Tipo: CRUD
-- Descripción: Devuelve los adeudos de un local para condonación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_11_condonacion(
    p_idlocal integer,
    p_idusu integer
) RETURNS TABLE (
    expression integer,
    expression_1 smallint,
    expression_2 smallint,
    expression_3 numeric,
    expression_4 varchar,
    expression_5 smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe, 'Adeudo de renta'::varchar, 0
    FROM public.ta_11_adeudo_local
    WHERE id_local = p_idlocal;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: condonar_adeudo_local
-- Tipo: CRUD
-- Descripción: Condona un adeudo específico de un local (mueve de adeudo a tabla de condonados).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION condonar_adeudo_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint,
    p_importe numeric,
    p_clave_canc varchar,
    p_observacion varchar,
    p_id_usuario integer,
    p_fecha timestamp
) RETURNS void AS $$
BEGIN
    INSERT INTO public.ta_11_ade_loc_canc (
        id_cancelacion, id_local, axo, periodo, importe, clave_canc, observacion, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_axo, p_periodo, p_importe, p_clave_canc, p_observacion, p_fecha, p_id_usuario
    );
    DELETE FROM public.ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: deshacer_condonacion_local
-- Tipo: CRUD
-- Descripción: Deshace una condonación, regresando el adeudo a la tabla de adeudos y borrando de condonados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION deshacer_condonacion_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint,
    p_importe numeric,
    p_id_usuario integer,
    p_fecha timestamp,
    p_id_cancelacion integer,
    p_observacion varchar
) RETURNS void AS $$
BEGIN
    INSERT INTO public.ta_11_adeudo_local (
        id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_axo, p_periodo, p_importe, p_fecha, p_id_usuario
    );
    DELETE FROM public.ta_11_ade_loc_canc
    WHERE id_cancelacion = p_id_cancelacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

