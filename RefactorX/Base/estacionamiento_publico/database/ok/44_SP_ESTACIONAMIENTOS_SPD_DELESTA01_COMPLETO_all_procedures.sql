-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: estacionamiento_publico
-- ESQUEMA: public
-- ============================================
\c estacionamiento_publico;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- SP: spd_delesta01 (COMPLETO - Traducido de Informix)
-- Archivo: 44_SP_ESTACIONAMIENTOS_SPD_DELESTA01_COMPLETO_all_procedures.sql
-- Generado: 2025-12-07
-- Descripción: SP para operaciones sobre folios de estacionamientos
--              Usado por: TransFoliosPublicos.vue, EstadoMpioPublicos.vue
-- ============================================

-- DROP de función existente para reemplazar
DROP FUNCTION IF EXISTS spd_delesta01(SMALLINT, INTEGER, TEXT, INTEGER, DATE, SMALLINT, TEXT, INTEGER, INTEGER, SMALLINT);

-- SP: spd_delesta01
-- Tipo: CRUD
-- Descripción: Procesa operaciones sobre folios de estacionamientos públicos.
--              Traduce la lógica del SP Informix spd_delesta01.
-- Opciones:
--   1 = Eliminar de ta14_datos_edo (usado por Estado/Mpio)
--   6 = Baja de folio CON fecha específica (cancelación con fecha de archivo)
--   7 = Baja de folio con fecha actual (cancelación estándar)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_delesta01(
  p_axo SMALLINT,
  p_folio INTEGER,
  p_placa TEXT,
  p_convenio INTEGER,
  p_fecha DATE,
  p_reca SMALLINT,
  p_caja TEXT,
  p_oper INTEGER,
  p_usuauto INTEGER,
  p_opc SMALLINT
)
RETURNS TABLE(result_code SMALLINT, result_msg TEXT)
LANGUAGE plpgsql AS $$
DECLARE
    v_rows_affected INTEGER := 0;
    v_fecha_baja DATE;
BEGIN
    -- Opción 1: Eliminar registro de ta14_datos_edo (usado por Estado/Mpio)
    IF p_opc = 1 THEN
        DELETE FROM ta14_datos_edo
        WHERE axo = p_axo AND folio = p_folio AND placa = p_placa;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN QUERY SELECT 1::SMALLINT, 'Registro eliminado de datos_edo correctamente'::TEXT;
        ELSE
            RETURN QUERY SELECT 0::SMALLINT, 'No se encontró el registro en datos_edo'::TEXT;
        END IF;
        RETURN;
    END IF;

    -- Opción 6: Baja de folio con fecha específica (del archivo)
    -- Usado cuando sRadioButton1 está marcado en el Pascal
    IF p_opc = 6 THEN
        v_fecha_baja := p_fecha;  -- Usa la fecha del parámetro

        -- Actualizar el folio a estado de baja
        UPDATE ta14_folios_adeudo
        SET estado = 99,  -- Estado de baja/cancelado
            fec_baja = v_fecha_baja,
            usu_baja = p_usuauto,
            convenio = p_convenio,
            recaudadora = p_reca,
            caja = p_caja,
            operador = p_oper
        WHERE axo = p_axo AND folio = p_folio AND placa = p_placa;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            -- Insertar en histórico si existe la tabla
            BEGIN
                INSERT INTO ta14_folios_histo (
                    axo, folio, placa, fecha_mov, tipo_mov, usuario, convenio
                )
                VALUES (
                    p_axo, p_folio, p_placa, v_fecha_baja, 'BAJA', p_usuauto, p_convenio
                );
            EXCEPTION WHEN OTHERS THEN
                -- Ignorar si la tabla histórico no existe
                NULL;
            END;

            RETURN QUERY SELECT 1::SMALLINT, ('Folio ' || p_folio || ' dado de baja correctamente (fecha: ' || v_fecha_baja || ')')::TEXT;
        ELSE
            RETURN QUERY SELECT 0::SMALLINT, ('No se encontró el folio ' || p_folio || ' con placa ' || p_placa)::TEXT;
        END IF;
        RETURN;
    END IF;

    -- Opción 7: Baja de folio con fecha actual
    -- Usado cuando sRadioButton1 NO está marcado
    IF p_opc = 7 THEN
        v_fecha_baja := CURRENT_DATE;  -- Usa fecha actual

        -- Actualizar el folio a estado de baja
        UPDATE ta14_folios_adeudo
        SET estado = 99,  -- Estado de baja/cancelado
            fec_baja = v_fecha_baja,
            usu_baja = p_usuauto,
            convenio = p_convenio,
            recaudadora = p_reca,
            caja = p_caja,
            operador = p_oper
        WHERE axo = p_axo AND folio = p_folio AND placa = p_placa;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            -- Insertar en histórico si existe la tabla
            BEGIN
                INSERT INTO ta14_folios_histo (
                    axo, folio, placa, fecha_mov, tipo_mov, usuario, convenio
                )
                VALUES (
                    p_axo, p_folio, p_placa, v_fecha_baja, 'BAJA', p_usuauto, p_convenio
                );
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;

            RETURN QUERY SELECT 1::SMALLINT, ('Folio ' || p_folio || ' dado de baja correctamente')::TEXT;
        ELSE
            RETURN QUERY SELECT 0::SMALLINT, ('No se encontró el folio ' || p_folio || ' con placa ' || p_placa)::TEXT;
        END IF;
        RETURN;
    END IF;

    -- Cualquier otra opción no implementada
    RETURN QUERY SELECT -1::SMALLINT, ('Opción ' || p_opc || ' no implementada')::TEXT;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT -99::SMALLINT, ('Error: ' || SQLERRM)::TEXT;
END;
$$;

-- ============================================
-- SP: sp_transfolios_altas
-- Tipo: CRUD
-- Descripción: Alta masiva de folios de multas de estacionómetros
--              Opción A del formulario sfrm_transfolios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_transfolios_altas(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR(10),
    p_fecha DATE,
    p_infraccion SMALLINT,
    p_agente INTEGER DEFAULT 1,
    p_captura INTEGER DEFAULT 0
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    -- Verificar si ya existe el folio
    IF EXISTS (SELECT 1 FROM ta14_folios_adeudo WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT 0, 'El folio ' || p_folio || ' ya existe para el año ' || p_axo;
        RETURN;
    END IF;

    INSERT INTO ta14_folios_adeudo (
        axo, folio, fecha_folio, placa, infraccion, estado, vigilante, fec_cap, usu_inicial
    ) VALUES (
        p_axo,
        p_folio,
        p_fecha,
        UPPER(TRIM(p_placa)),
        p_infraccion,
        14,  -- Estado inicial según Pascal
        p_agente,
        CURRENT_DATE,
        p_captura
    );

    RETURN QUERY SELECT 1, 'Folio ' || p_folio || ' insertado correctamente';

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_transfolios_bajas
-- Tipo: CRUD
-- Descripción: Baja masiva de folios de multas de estacionómetros
--              Opción B del formulario sfrm_transfolios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_transfolios_bajas(
    p_axo SMALLINT,
    p_folio INTEGER,
    p_placa VARCHAR(10),
    p_fecha DATE DEFAULT NULL,
    p_usar_fecha_archivo BOOLEAN DEFAULT FALSE,
    p_usuauto INTEGER DEFAULT 0
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
DECLARE
    v_fecha_baja DATE;
    v_opc SMALLINT;
BEGIN
    -- Determinar opción según checkbox
    IF p_usar_fecha_archivo AND p_fecha IS NOT NULL THEN
        v_fecha_baja := p_fecha;
        v_opc := 6;
    ELSE
        v_fecha_baja := CURRENT_DATE;
        v_opc := 7;
    END IF;

    -- Llamar al SP principal
    RETURN QUERY
    SELECT
        r.result_code::INTEGER,
        r.result_msg
    FROM spd_delesta01(
        p_axo,
        p_folio,
        UPPER(TRIM(p_placa)),
        0,  -- convenio
        v_fecha_baja,
        1::SMALLINT,  -- reca
        'Z',  -- caja
        0,  -- oper
        p_usuauto,
        v_opc
    ) r;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_transfolios_calcomanias
-- Tipo: CRUD
-- Descripción: Alta de calcomanías sin propietario
--              Opción C del formulario sfrm_transfolios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_transfolios_calcomanias(
    p_axo SMALLINT,
    p_calco INTEGER,
    p_status VARCHAR(1),
    p_turno VARCHAR(1),
    p_fecini DATE,
    p_fecfin DATE,
    p_placa VARCHAR(10),
    p_propie INTEGER DEFAULT 1,
    p_usu INTEGER DEFAULT 0
) RETURNS TABLE(result INTEGER, msg TEXT) AS $$
BEGIN
    -- Verificar si ya existe la calcomanía
    IF EXISTS (SELECT 1 FROM ta14_calco WHERE axo = p_axo AND num_calco = p_calco) THEN
        RETURN QUERY SELECT 0, 'La calcomanía ' || p_calco || ' ya existe para el año ' || p_axo;
        RETURN;
    END IF;

    INSERT INTO ta14_calco (
        axo, num_calco, tipo, turno, fecha_inicial, fecha_fin, placa, propietario, fec_cap, usu_inicial
    ) VALUES (
        p_axo,
        p_calco,
        UPPER(TRIM(p_status)),
        UPPER(TRIM(p_turno)),
        p_fecini,
        p_fecfin,
        UPPER(TRIM(p_placa)),
        p_propie,
        CURRENT_DATE,
        p_usu
    );

    RETURN QUERY SELECT 1, 'Calcomanía ' || p_calco || ' insertada correctamente';

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_get_infracciones_estacionamiento
-- Tipo: Catálogo
-- Descripción: Obtiene catálogo de infracciones para estacionamientos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_infracciones_estacionamiento()
RETURNS TABLE(
    clave SMALLINT,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.clave::SMALLINT,
        t.descripcion::VARCHAR(100)
    FROM ta14_tarifas t
    WHERE t.activo = TRUE OR t.activo IS NULL
    ORDER BY t.clave;

EXCEPTION WHEN OTHERS THEN
    -- Si no existe la tabla, retornar valores por defecto
    RETURN QUERY SELECT 1::SMALLINT, 'Infracción General'::VARCHAR(100);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GRANT de permisos
GRANT EXECUTE ON FUNCTION spd_delesta01 TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_transfolios_altas TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_transfolios_bajas TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_transfolios_calcomanias TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_get_infracciones_estacionamiento TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
