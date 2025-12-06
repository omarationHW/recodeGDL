-- ============================================================
-- DESPLIEGUE DE SPs CORREGIDOS PARA EnergiaModif
-- Fecha: 2025-12-04
-- Problema: Referencias cross-database incorrectas (padron_licencias.schema.tabla)
-- Solución: Usar solo schema.tabla
-- ============================================================

-- ============================================================
-- 1. SP: sp_energia_modif_buscar
-- ============================================================

DROP FUNCTION IF EXISTS public.sp_energia_modif_buscar(integer, integer, integer, varchar, integer, varchar, varchar);

CREATE OR REPLACE FUNCTION public.sp_energia_modif_buscar(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR,
    p_bloque VARCHAR
)
RETURNS TABLE (
    id_energia INTEGER,
    id_local INTEGER,
    cve_consumo VARCHAR,
    local_adicional VARCHAR,
    cantidad NUMERIC,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo::VARCHAR,
        e.local_adicional::VARCHAR,
        e.cantidad,
        e.vigencia::VARCHAR,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario
    FROM comun.ta_11_locales l
    INNER JOIN db_ingresos.ta_11_energia e
        ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (l.bloque IS NOT DISTINCT FROM p_bloque)
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION public.sp_energia_modif_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR) IS
'Busca el registro de energía para un local específico';

-- ============================================================
-- 2. SP: sp_energia_modif_modificar
-- ============================================================

DROP FUNCTION IF EXISTS public.sp_energia_modif_modificar(integer, integer, numeric, varchar, date, date, varchar, varchar, varchar, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_energia_modif_modificar(
    p_id_energia INTEGER,
    p_id_local INTEGER,
    p_cantidad NUMERIC,
    p_vigencia VARCHAR,
    p_fecha_alta DATE,
    p_fecha_baja DATE,
    p_movimiento VARCHAR,
    p_cve_consumo VARCHAR,
    p_local_adicional VARCHAR,
    p_usuario_id INTEGER,
    p_periodo_baja_axo INTEGER,
    p_periodo_baja_mes INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old RECORD;
    v_now TIMESTAMP := NOW();
    v_mov CHAR(1);
    v_date DATE;
    v_end DATE;
    v_axo INTEGER;
    v_mes INTEGER;
BEGIN
    v_mov := UPPER(SUBSTR(p_movimiento, 1, 1));

    -- Buscar registro actual
    SELECT * INTO v_old
    FROM db_ingresos.ta_11_energia
    WHERE id_energia = p_id_energia AND id_local = p_id_local;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Registro de energía no encontrado';
        RETURN;
    END IF;

    -- Validaciones
    IF p_cantidad IS NULL OR p_cantidad = 0 THEN
        RETURN QUERY SELECT false, 'La cantidad de kilowhatts/cuota fija no tiene información';
        RETURN;
    END IF;

    IF v_mov = 'B' AND p_vigencia <> 'B' THEN
        RETURN QUERY SELECT false, 'No coincide el movimiento con la vigencia';
        RETURN;
    END IF;

    IF v_mov <> 'B' AND p_vigencia = 'B' THEN
        RETURN QUERY SELECT false, 'La vigencia debe ser "A" o "E" para movimientos distintos de baja';
        RETURN;
    END IF;

    IF v_mov = 'B' AND (p_periodo_baja_axo IS NULL OR p_periodo_baja_mes IS NULL) THEN
        RETURN QUERY SELECT false, 'Falta capturar el periodo de baja';
        RETURN;
    END IF;

    -- Insertar en historial
    INSERT INTO db_ingresos.ta_11_energia_hist (
        id_energia, axo, numero, cve_consumo, local_adicional, cantidad, vigencia,
        fecha_alta, fecha_baja, fecha_modificacion, id_usuario, movimiento,
        fecha_registro, usuario_registro
    ) VALUES (
        p_id_energia, EXTRACT(YEAR FROM v_now)::INTEGER, 0, v_old.cve_consumo,
        v_old.local_adicional, v_old.cantidad, v_old.vigencia, v_old.fecha_alta,
        v_old.fecha_baja, v_old.fecha_modificacion, v_old.id_usuario, v_mov,
        v_now, p_usuario_id
    );

    -- Actualizar energía
    UPDATE db_ingresos.ta_11_energia
    SET
        cve_consumo = p_cve_consumo,
        local_adicional = p_local_adicional,
        cantidad = p_cantidad,
        vigencia = p_vigencia,
        fecha_alta = p_fecha_alta,
        fecha_baja = CASE WHEN v_mov = 'B' THEN p_fecha_baja ELSE NULL END,
        fecha_modificacion = v_now,
        id_usuario = p_usuario_id
    WHERE id_energia = p_id_energia AND id_local = p_id_local;

    -- Procesos según movimiento
    IF v_mov = 'B' THEN
        -- Borrar adeudos del periodo de baja en adelante
        DELETE FROM db_ingresos.ta_11_adeudo_energ
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));

    ELSIF v_mov = 'F' THEN
        -- Eliminar todos los adeudos
        DELETE FROM db_ingresos.ta_11_adeudo_energ
        WHERE id_energia = p_id_energia;

        -- Recalcular adeudos desde fecha_alta hasta hoy
        v_date := p_fecha_alta;
        v_end := CURRENT_DATE;

        WHILE v_date <= v_end LOOP
            v_axo := EXTRACT(YEAR FROM v_date)::INTEGER;
            v_mes := EXTRACT(MONTH FROM v_date)::INTEGER;

            INSERT INTO db_ingresos.ta_11_adeudo_energ (
                id_energia, axo, periodo, cve_consumo, cantidad, importe,
                fecha_alta, id_usuario
            ) VALUES (
                p_id_energia, v_axo, v_mes, p_cve_consumo, p_cantidad,
                p_cantidad, v_now, p_usuario_id
            );

            v_date := v_date + INTERVAL '1 month';
        END LOOP;

    ELSIF v_mov = 'D' THEN
        -- Actualizar adeudos en el rango
        UPDATE db_ingresos.ta_11_adeudo_energ
        SET cantidad = p_cantidad,
            importe = p_cantidad,
            fecha_alta = v_now,
            id_usuario = p_usuario_id
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));
    END IF;

    RETURN QUERY SELECT true, 'Se modificó correctamente el registro de energía eléctrica';
END;
$$;

COMMENT ON FUNCTION public.sp_energia_modif_modificar(INTEGER, INTEGER, NUMERIC, VARCHAR, DATE, DATE, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, INTEGER) IS
'Modifica el registro de energía y actualiza historial y adeudos según reglas de negocio';

-- ============================================================
-- FIN DEL DESPLIEGUE
-- ============================================================
