-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaTCultural
-- Generado: 2025-08-26 23:03:00
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_adeudos_tcultural
-- Tipo: Report
-- Descripción: Obtiene la lista de adeudos del Tianguis Cultural para un rango de folios y periodo/año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_tcultural(
    p_local_desde INTEGER,
    p_local_hasta INTEGER,
    p_periodo SMALLINT,
    p_axo SMALLINT,
    p_user_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    local INTEGER,
    nombre VARCHAR,
    descuento NUMERIC,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.local,
        t."Nombre" AS nombre,
        t."Descuento" AS descuento,
        a.axo,
        a.periodo,
        a.importe
    FROM public.ta_11_adeudo_local a
    JOIN public.ta_11_locales l ON a.id_local = l.id_local
    LEFT JOIN cobrotrimestral t ON t."Folio" = l.local
    WHERE l.oficina = 1
      AND l.num_mercado = 214
      AND l.categoria = 1
      AND l.seccion = 'SS'
      AND l.local BETWEEN p_local_desde AND p_local_hasta
      AND a.periodo = p_periodo
      AND a.axo = p_axo
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
    ORDER BY l.local ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_validate_pagos_tcultural
-- Tipo: CRUD
-- Descripción: Valida que los folios de pagos existan en ingresos y no estén duplicados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validate_pagos_tcultural(
    p_pagos_json JSON
) RETURNS TABLE(foliosErroneos TEXT[]) AS $$
DECLARE
    pagos RECORD;
    folios_err TEXT[] := ARRAY[]::TEXT[];
    rec RECORD;
BEGIN
    FOR pagos IN SELECT * FROM json_populate_recordset(NULL::record, p_pagos_json) LOOP
        -- Validar que los campos requeridos estén presentes
        IF pagos.fecha_pago IS NULL OR pagos.rec IS NULL OR pagos.caja IS NULL OR pagos.operacion IS NULL OR pagos.partida IS NULL THEN
            folios_err := array_append(folios_err, pagos.local::TEXT);
        ELSE
            -- Validar existencia en ingresos (ejemplo: tabla ta_12_importes)
            SELECT 1 INTO rec FROM public.ta_12_importes
                WHERE fecing = pagos.fecha_pago::date
                  AND recing = pagos.rec::smallint
                  AND cajing = pagos.caja::varchar
                  AND opcaja = pagos.operacion::integer
            LIMIT 1;
            IF NOT FOUND THEN
                folios_err := array_append(folios_err, pagos.local::TEXT);
            END IF;
        END IF;
    END LOOP;
    RETURN QUERY SELECT folios_err;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_save_pagos_tcultural
-- Tipo: CRUD
-- Descripción: Guarda los pagos del Tianguis Cultural y elimina los adeudos correspondientes. Aplica descuento si corresponde.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_save_pagos_tcultural(
    p_pagos_json JSON,
    p_user_id INTEGER
) RETURNS JSON AS $$
DECLARE
    pagos RECORD;
    l_renta NUMERIC;
    l_renta_desc NUMERIC;
    inserted_count INTEGER := 0;
    deleted_count INTEGER := 0;
BEGIN
    FOR pagos IN SELECT * FROM json_populate_recordset(NULL::record, p_pagos_json) LOOP
        IF pagos.fecha_pago IS NULL OR pagos.rec IS NULL OR pagos.caja IS NULL OR pagos.operacion IS NULL OR pagos.partida IS NULL THEN
            CONTINUE;
        END IF;
        -- Calcular descuento si aplica
        IF pagos.descuento IS NOT NULL AND pagos.descuento > 0 THEN
            l_renta := pagos.importe;
            l_renta_desc := round(l_renta - (l_renta * pagos.descuento / 100.0), 2);
        ELSE
            l_renta_desc := pagos.importe;
        END IF;
        -- Insertar pago
        INSERT INTO public.ta_11_pagos_local (
            id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
        ) VALUES (
            DEFAULT, pagos.id_local, pagos.axo, pagos.periodo, pagos.fecha_pago::date, pagos.rec, pagos.caja, pagos.operacion, l_renta_desc, pagos.partida, NOW(), p_user_id
        );
        inserted_count := inserted_count + 1;
        -- Eliminar adeudo
        DELETE FROM public.ta_11_adeudo_local
        WHERE id_local = pagos.id_local AND axo = pagos.axo AND periodo = pagos.periodo;
        deleted_count := deleted_count + 1;
    END LOOP;
    RETURN json_build_object('inserted', inserted_count, 'deleted', deleted_count);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_tianguis_info
-- Tipo: Catalog
-- Descripción: Obtiene información del folio del Tianguis Cultural desde la tabla cobrotrimestral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tianguis_info(
    p_folio INTEGER
) RETURNS TABLE(
    folio INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    poblacion VARCHAR,
    superficie NUMERIC,
    giro VARCHAR,
    descuento NUMERIC,
    motivo_descuento VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        "Folio", "Nombre", "Domicilio", "Colonia", "Poblacion", "Superficie", "Giro", "Descuento", "MotivoDescuento"
    FROM cobrotrimestral
    WHERE "Folio" = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

