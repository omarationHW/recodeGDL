-- ========================================================================
-- SPS CORREGIDOS PARA ENERGIA MODIF - CAMBIOS DE ENERGÍA ELÉCTRICA
-- Base de datos: padron_licencias
-- Fecha: 2025-12-04
-- ========================================================================

-- ========================================================================
-- SP 1: sp_energia_modif_buscar
-- Busca el registro de energía para un local específico
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_energia_modif_buscar(
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
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo,
        e.local_adicional,
        e.cantidad,
        e.vigencia,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario
    FROM padron_licencias.comun.ta_11_locales l
    INNER JOIN mercados.public.ta_11_energia e
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

-- ========================================================================
-- SP 2: sp_energia_modif_modificar
-- Modifica registro de energía y actualiza historial y adeudos
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_energia_modif_modificar(
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
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old RECORD;
    v_now TIMESTAMP := now();
    v_mov CHAR(1);
BEGIN
    v_mov := upper(substr(p_movimiento, 1, 1));

    -- Obtener registro anterior
    SELECT * INTO v_old
    FROM mercados.public.ta_11_energia
    WHERE id_energia = p_id_energia
      AND id_local = p_id_local;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Registro de energía no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Validaciones
    IF p_cantidad IS NULL OR p_cantidad = 0 THEN
        RETURN QUERY SELECT FALSE, 'La cantidad de kilowhatts/cuota fija no tiene información'::TEXT;
        RETURN;
    END IF;

    IF v_mov = 'B' AND p_vigencia <> 'B' THEN
        RETURN QUERY SELECT FALSE, 'No coincide el movimiento con la vigencia'::TEXT;
        RETURN;
    END IF;

    IF v_mov <> 'B' AND p_vigencia = 'B' THEN
        RETURN QUERY SELECT FALSE, 'La vigencia debe ser "A" o "E" para movimientos distintos de baja'::TEXT;
        RETURN;
    END IF;

    IF v_mov = 'B' AND (p_periodo_baja_axo IS NULL OR p_periodo_baja_mes IS NULL) THEN
        RETURN QUERY SELECT FALSE, 'Falta capturar el periodo de baja'::TEXT;
        RETURN;
    END IF;

    -- Insertar en historial
    INSERT INTO mercados.public.ta_11_energia_hist (
        id_energia,
        axo,
        numero,
        cve_consumo,
        local_adicional,
        cantidad,
        vigencia,
        fecha_alta,
        fecha_baja,
        fecha_modificacion,
        id_usuario,
        movimiento,
        fecha_registro,
        usuario_registro
    ) VALUES (
        p_id_energia,
        EXTRACT(YEAR FROM v_now)::INTEGER,
        0,
        v_old.cve_consumo,
        v_old.local_adicional,
        v_old.cantidad,
        v_old.vigencia,
        v_old.fecha_alta,
        v_old.fecha_baja,
        v_old.fecha_modificacion,
        v_old.id_usuario,
        v_mov,
        v_now,
        p_usuario_id
    );

    -- Actualizar registro de energía
    UPDATE mercados.public.ta_11_energia
    SET
        cve_consumo = p_cve_consumo,
        local_adicional = p_local_adicional,
        cantidad = p_cantidad,
        vigencia = p_vigencia,
        fecha_alta = p_fecha_alta,
        fecha_baja = CASE WHEN v_mov = 'B' THEN p_fecha_baja ELSE NULL END,
        fecha_modificacion = v_now,
        id_usuario = p_usuario_id
    WHERE id_energia = p_id_energia
      AND id_local = p_id_local;

    -- Procesos según tipo de movimiento
    IF v_mov = 'B' THEN
        -- B = BAJA: Borrar adeudos del periodo de baja en adelante
        DELETE FROM mercados.public.ta_11_adeudo_energ
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));

    ELSIF v_mov = 'F' THEN
        -- F = RECALCULAR COMPLETO: Eliminar todos y regenerar desde fecha_alta
        DELETE FROM mercados.public.ta_11_adeudo_energ
        WHERE id_energia = p_id_energia;

        -- Regenerar adeudos desde fecha_alta hasta hoy
        DECLARE
            v_date DATE := p_fecha_alta;
            v_end DATE := CURRENT_DATE;
            v_axo INTEGER;
            v_mes INTEGER;
        BEGIN
            WHILE v_date <= v_end LOOP
                v_axo := EXTRACT(YEAR FROM v_date)::INTEGER;
                v_mes := EXTRACT(MONTH FROM v_date)::INTEGER;

                INSERT INTO mercados.public.ta_11_adeudo_energ (
                    id_energia,
                    axo,
                    periodo,
                    cve_consumo,
                    cantidad,
                    importe,
                    fecha_alta,
                    id_usuario
                ) VALUES (
                    p_id_energia,
                    v_axo,
                    v_mes,
                    p_cve_consumo,
                    p_cantidad,
                    p_cantidad,
                    v_now,
                    p_usuario_id
                );

                v_date := v_date + INTERVAL '1 month';
            END LOOP;
        END;

    ELSIF v_mov = 'D' THEN
        -- D = ACTUALIZAR DESDE PERIODO: Actualizar adeudos del periodo en adelante
        UPDATE mercados.public.ta_11_adeudo_energ
        SET
            cantidad = p_cantidad,
            importe = p_cantidad,
            fecha_alta = v_now,
            id_usuario = p_usuario_id
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));

    ELSIF v_mov = 'C' THEN
        -- C = CAMBIO SIMPLE: Solo actualiza el registro, no afecta adeudos
        NULL; -- No hay operaciones adicionales

    END IF;

    RETURN QUERY SELECT TRUE, 'Se modificó correctamente el registro de energía eléctrica'::TEXT;
END;
$$;

-- ========================================================================
-- COMENTARIOS Y NOTAS:
-- ========================================================================
-- 1. Schemas utilizados:
--    - padron_licencias.comun.ta_11_locales (datos del local)
--    - mercados.public.ta_11_energia (registro principal de energía)
--    - mercados.public.ta_11_energia_hist (historial de cambios)
--    - mercados.public.ta_11_adeudo_energ (adeudos de energía)
--
-- 2. sp_energia_modif_buscar:
--    - JOIN cross-database entre padron_licencias y mercados
--    - Busca por todos los campos que identifican un local
--    - Usa IS NOT DISTINCT FROM para comparar campos que pueden ser NULL
--
-- 3. sp_energia_modif_modificar:
--    - Tipos de movimiento:
--      - 'A' o 'C' = CAMBIO/ALTA: Solo actualiza registro
--      - 'B' = BAJA: Actualiza registro + elimina adeudos futuros
--      - 'D' = ACTUALIZAR DESDE PERIODO: Actualiza adeudos futuros con nueva cantidad
--      - 'F' = RECALCULAR COMPLETO: Regenera todos los adeudos desde fecha_alta
--    - Siempre guarda el registro anterior en ta_11_energia_hist
--    - Validaciones de consistencia entre movimiento y vigencia
--    - Para movimiento 'B' requiere periodo de baja (año y mes)
-- ========================================================================
