-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EnergiaModif
-- Generado: 2025-08-26 23:56:17
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_energia_modif_buscar
-- Tipo: CRUD
-- Descripción: Busca el registro de energía para un local específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_energia_modif_buscar(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_energia integer,
    id_local integer,
    cve_consumo varchar,
    local_adicional varchar,
    cantidad numeric,
    vigencia varchar,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_energia, e.id_local, e.cve_consumo, e.local_adicional, e.cantidad, e.vigencia, e.fecha_alta, e.fecha_baja, e.fecha_modificacion, e.id_usuario
    FROM public.ta_11_locales l
    JOIN public.ta_11_energia e ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (l.bloque IS NOT DISTINCT FROM p_bloque)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_energia_modif_modificar
-- Tipo: CRUD
-- Descripción: Modifica el registro de energía y actualiza historial y adeudos según reglas de negocio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_energia_modif_modificar(
    p_id_energia integer,
    p_id_local integer,
    p_cantidad numeric,
    p_vigencia varchar,
    p_fecha_alta date,
    p_fecha_baja date,
    p_movimiento varchar,
    p_cve_consumo varchar,
    p_local_adicional varchar,
    p_usuario_id integer,
    p_periodo_baja_axo integer,
    p_periodo_baja_mes integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_old record;
    v_now timestamp := now();
    v_mov char(1);
BEGIN
    v_mov := upper(substr(p_movimiento,1,1));
    SELECT * INTO v_old FROM public.ta_11_energia WHERE id_energia = p_id_energia AND id_local = p_id_local;
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
    INSERT INTO public.ta_11_energia_hist (
        id_energia_hist, id_energia, axo, numero, cve_consumo, local_adicional, cantidad, vigencia, fecha_alta, fecha_baja, fecha_modificacion, id_usuario, movimiento, fecha_registro, usuario_registro
    ) VALUES (
        DEFAULT, p_id_energia, extract(year from v_now)::int, 0, v_old.cve_consumo, v_old.local_adicional, v_old.cantidad, v_old.vigencia, v_old.fecha_alta, v_old.fecha_baja, v_old.fecha_modificacion, v_old.id_usuario, v_mov, v_now, p_usuario_id
    );
    -- Actualizar energía
    UPDATE public.ta_11_energia SET
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
        DELETE FROM public.ta_11_adeudo_energ
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));
    ELSIF v_mov = 'F' THEN
        -- Eliminar todos los adeudos
        DELETE FROM public.ta_11_adeudo_energ WHERE id_energia = p_id_energia;
        -- Recalcular adeudos desde fecha_alta hasta hoy
        -- (Lógica simplificada: se puede ajustar según reglas de negocio)
        DECLARE
            v_date date := p_fecha_alta;
            v_end date := current_date;
            v_axo int;
            v_mes int;
        BEGIN
            WHILE v_date <= v_end LOOP
                v_axo := extract(year from v_date)::int;
                v_mes := extract(month from v_date)::int;
                INSERT INTO public.ta_11_adeudo_energ (id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario)
                VALUES (DEFAULT, p_id_energia, v_axo, v_mes, p_cve_consumo, p_cantidad, p_cantidad, v_now, p_usuario_id);
                v_date := v_date + interval '1 month';
            END LOOP;
        END;
    ELSIF v_mov = 'D' THEN
        -- Actualizar adeudos en el rango
        UPDATE public.ta_11_adeudo_energ
        SET cantidad = p_cantidad, importe = p_cantidad, fecha_alta = v_now, id_usuario = p_usuario_id
        WHERE id_energia = p_id_energia
          AND ((axo = p_periodo_baja_axo AND periodo >= p_periodo_baja_mes)
               OR (axo > p_periodo_baja_axo));
    END IF;
    RETURN QUERY SELECT true, 'Se modificó correctamente el registro de energía eléctrica';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_catalogo_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_recaudadoras() RETURNS TABLE (
    id_rec integer,
    recaudadora varchar
) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_catalogo_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalogo_secciones() RETURNS TABLE (
    seccion varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM public.ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

