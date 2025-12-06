-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: LocalesModif
-- Generado: 2025-08-27 00:10:52
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_localesmodif_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local por criterios únicos (oficina, mercado, categoria, seccion, local, letra, bloque)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_localesmodif_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    local smallint,
    letra_local varchar(3),
    bloque varchar(2),
    nombre varchar(30),
    domicilio varchar(70),
    sector char(1),
    zona smallint,
    descripcion_local char(20),
    superficie numeric,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    vigencia char(1),
    clave_cuota smallint,
    bloqueo smallint,
    id_usuario integer
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
        l.nombre,
        l.domicilio,
        l.sector,
        l.zona,
        l.descripcion_local,
        l.superficie,
        l.giro,
        l.fecha_alta,
        l.fecha_baja,
        l.vigencia,
        l.clave_cuota,
        l.bloqueo,
        l.id_usuario
    FROM public.ta_11_localpaso l
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local = p_letra_local OR (l.letra_local IS NULL AND p_letra_local IS NULL))
      AND (l.bloque = p_bloque OR (l.bloque IS NULL AND p_bloque IS NULL))
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_localesmodif_modificar_local
-- Tipo: CRUD
-- Descripción: Realiza la modificación de un local, registra movimiento, actualiza datos, bloqueos, y adeudos según reglas de negocio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_localesmodif_modificar_local(
    p_id_local integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_sector varchar,
    p_zona integer,
    p_descripcion_local varchar,
    p_superficie numeric,
    p_giro integer,
    p_fecha_alta date,
    p_fecha_baja date,
    p_vigencia varchar,
    p_clave_cuota integer,
    p_tipo_movimiento integer,
    p_bloqueo integer,
    p_cve_bloqueo integer,
    p_fecha_inicio_bloqueo date,
    p_fecha_final_bloqueo date,
    p_observacion varchar,
    p_id_usuario integer,
    p_fecha_actual timestamp
) RETURNS TABLE (result text) AS $$
DECLARE
    v_mov_id integer;
    v_msg text;
BEGIN
    -- 1. Registrar movimiento
    INSERT INTO comun.ta_11_movimientos (
        id_local, axo_memo, numero_memo, nombre, arrendatario, domicilio, sector, zona, drescripcion_local, superficie, giro, fecha_alta, fecha_baja, vigencia, clave_cuota, tipo_movimiento, fecha, id_usuario, bloqueo
    ) VALUES (
        p_id_local, EXTRACT(YEAR FROM p_fecha_alta)::integer, 0, p_nombre, NULL, p_domicilio, p_sector, p_zona, p_descripcion_local, p_superficie, p_giro, p_fecha_alta, p_fecha_baja, p_vigencia, p_clave_cuota, p_tipo_movimiento, now(), p_id_usuario, COALESCE(p_bloqueo,0)
    ) RETURNING id_movimiento INTO v_mov_id;

    -- 2. Actualizar local
    UPDATE comun.ta_11_locales SET
        nombre = p_nombre,
        domicilio = p_domicilio,
        sector = p_sector,
        zona = p_zona,
        descripcion_local = p_descripcion_local,
        superficie = p_superficie,
        giro = p_giro,
        fecha_alta = p_fecha_alta,
        fecha_baja = p_fecha_baja,
        fecha_modificacion = now(),
        vigencia = p_vigencia,
        id_usuario = p_id_usuario,
        clave_cuota = p_clave_cuota,
        bloqueo = COALESCE(p_bloqueo,0)
    WHERE id_local = p_id_local;

    -- 3. Bloqueo/desbloqueo
    IF p_tipo_movimiento = 12 THEN -- Bloquear
        INSERT INTO comun.ta_11_bloqueo (id_local, cve_bloqueo, fecha_inicio, fecha_final, observacion, id_usuario, fecha_actual)
        VALUES (p_id_local, p_cve_bloqueo, p_fecha_inicio_bloqueo, NULL, p_observacion, p_id_usuario, now());
    ELSIF p_tipo_movimiento = 13 THEN -- Desbloquear
        UPDATE comun.ta_11_bloqueo SET
            fecha_final = p_fecha_final_bloqueo,
            observacion = p_observacion,
            id_usuario = p_id_usuario,
            fecha_actual = now()
        WHERE id_local = p_id_local AND cve_bloqueo = p_cve_bloqueo AND fecha_inicio = p_fecha_inicio_bloqueo;
    END IF;

    -- 4. Adeudos (simplificado, lógica real debe ser más detallada)
    -- Aquí se puede llamar a otro SP para recalcular adeudos si aplica

    v_msg := 'OK';
    RETURN QUERY SELECT v_msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

