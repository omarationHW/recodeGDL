-- ============================================
-- CONFIGURACION BASE DE DATOS: estacionamiento_publico
-- ESQUEMA: public
-- ============================================
\c estacionamiento_publico;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- SP: Valet Paso (COMPLETO - Recodificado)
-- Archivo: 46_SP_ESTACIONAMIENTOS_VALET_PASO_COMPLETO_all_procedures.sql
-- Generado: 2025-12-07
-- Descripcion: SPs para procesar archivos CSV de valet parking
--              Basado en sfrm_valet_paso.pas
-- ============================================

-- Crear tabla si no existe para almacenar datos de valet
CREATE TABLE IF NOT EXISTS ta14_valet_paso (
    id SERIAL PRIMARY KEY,
    fecha_proceso DATE DEFAULT CURRENT_DATE,
    folio INTEGER,
    placa VARCHAR(10),
    fecha_entrada TIMESTAMP,
    fecha_salida TIMESTAMP,
    tarifa NUMERIC(10,2),
    importe NUMERIC(10,2),
    estatus VARCHAR(1) DEFAULT 'A',
    observaciones TEXT,
    usuario_proceso INTEGER DEFAULT 0,
    fec_cap TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indice para busquedas
CREATE INDEX IF NOT EXISTS idx_valet_paso_folio ON ta14_valet_paso(folio);
CREATE INDEX IF NOT EXISTS idx_valet_paso_placa ON ta14_valet_paso(placa);
CREATE INDEX IF NOT EXISTS idx_valet_paso_fecha ON ta14_valet_paso(fecha_proceso);

-- ============================================
-- SP: sp_valet_paso_procesar
-- Tipo: CRUD
-- Descripcion: Procesa contenido CSV de valet y guarda en tabla
-- Parametros:
--   p_contenido: Contenido del CSV como texto (lineas separadas por \n)
--   p_usuario: ID del usuario que procesa
-- Retorna: Resumen de procesamiento
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_valet_paso_procesar(TEXT, INTEGER);

CREATE OR REPLACE FUNCTION sp_valet_paso_procesar(
    p_contenido TEXT,
    p_usuario INTEGER DEFAULT 0
)
RETURNS TABLE(
    total_lineas INTEGER,
    insertados INTEGER,
    errores INTEGER,
    detalle_errores TEXT
) AS $$
DECLARE
    v_lineas TEXT[];
    v_linea TEXT;
    v_campos TEXT[];
    v_total INTEGER := 0;
    v_insertados INTEGER := 0;
    v_errores INTEGER := 0;
    v_detalle TEXT := '';
    v_folio INTEGER;
    v_placa VARCHAR(10);
    v_fecha_entrada TIMESTAMP;
    v_fecha_salida TIMESTAMP;
    v_tarifa NUMERIC(10,2);
    v_importe NUMERIC(10,2);
    v_i INTEGER;
BEGIN
    -- Separar contenido en lineas
    v_lineas := string_to_array(p_contenido, E'\n');

    -- Procesar cada linea (saltar encabezado si existe)
    FOR v_i IN 1..array_length(v_lineas, 1) LOOP
        v_linea := TRIM(v_lineas[v_i]);

        -- Saltar lineas vacias
        IF v_linea = '' OR v_linea IS NULL THEN
            CONTINUE;
        END IF;

        -- Saltar encabezado (primera linea con texto no numerico)
        IF v_i = 1 AND v_linea ~* '^[a-z]' THEN
            CONTINUE;
        END IF;

        v_total := v_total + 1;

        BEGIN
            -- Separar campos por coma o punto y coma
            IF position(';' IN v_linea) > 0 THEN
                v_campos := string_to_array(v_linea, ';');
            ELSE
                v_campos := string_to_array(v_linea, ',');
            END IF;

            -- Validar minimo de campos
            IF array_length(v_campos, 1) < 4 THEN
                v_errores := v_errores + 1;
                v_detalle := v_detalle || 'Linea ' || v_i || ': Campos insuficientes; ';
                CONTINUE;
            END IF;

            -- Parsear campos
            -- Formato esperado: folio,placa,fecha_entrada,fecha_salida,tarifa,importe
            v_folio := NULLIF(TRIM(v_campos[1]), '')::INTEGER;
            v_placa := UPPER(TRIM(COALESCE(v_campos[2], '')));

            -- Parsear fechas (formato flexible)
            BEGIN
                v_fecha_entrada := NULLIF(TRIM(v_campos[3]), '')::TIMESTAMP;
            EXCEPTION WHEN OTHERS THEN
                v_fecha_entrada := NULL;
            END;

            BEGIN
                v_fecha_salida := NULLIF(TRIM(v_campos[4]), '')::TIMESTAMP;
            EXCEPTION WHEN OTHERS THEN
                v_fecha_salida := NULL;
            END;

            -- Parsear montos
            BEGIN
                v_tarifa := COALESCE(NULLIF(TRIM(v_campos[5]), '')::NUMERIC, 0);
            EXCEPTION WHEN OTHERS THEN
                v_tarifa := 0;
            END;

            BEGIN
                v_importe := COALESCE(NULLIF(TRIM(v_campos[6]), '')::NUMERIC, 0);
            EXCEPTION WHEN OTHERS THEN
                v_importe := 0;
            END;

            -- Validar datos minimos
            IF v_folio IS NULL OR v_folio = 0 THEN
                v_errores := v_errores + 1;
                v_detalle := v_detalle || 'Linea ' || v_i || ': Folio invalido; ';
                CONTINUE;
            END IF;

            IF v_placa = '' THEN
                v_errores := v_errores + 1;
                v_detalle := v_detalle || 'Linea ' || v_i || ': Placa vacia; ';
                CONTINUE;
            END IF;

            -- Verificar duplicado
            IF EXISTS (SELECT 1 FROM ta14_valet_paso WHERE folio = v_folio AND placa = v_placa AND fecha_proceso = CURRENT_DATE) THEN
                v_errores := v_errores + 1;
                v_detalle := v_detalle || 'Linea ' || v_i || ': Duplicado (folio=' || v_folio || '); ';
                CONTINUE;
            END IF;

            -- Insertar registro
            INSERT INTO ta14_valet_paso (
                folio, placa, fecha_entrada, fecha_salida,
                tarifa, importe, usuario_proceso, fecha_proceso
            ) VALUES (
                v_folio, v_placa, v_fecha_entrada, v_fecha_salida,
                v_tarifa, v_importe, p_usuario, CURRENT_DATE
            );

            v_insertados := v_insertados + 1;

        EXCEPTION WHEN OTHERS THEN
            v_errores := v_errores + 1;
            v_detalle := v_detalle || 'Linea ' || v_i || ': ' || SQLERRM || '; ';
        END;
    END LOOP;

    -- Retornar resumen
    RETURN QUERY SELECT v_total, v_insertados, v_errores, v_detalle;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 0, 0, 1, ('Error general: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_valet_paso_consultar
-- Tipo: Consulta
-- Descripcion: Consulta registros de valet procesados
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_valet_paso_consultar(DATE, DATE, VARCHAR);

CREATE OR REPLACE FUNCTION sp_valet_paso_consultar(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_placa VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    fecha_proceso DATE,
    folio INTEGER,
    placa VARCHAR(10),
    fecha_entrada TIMESTAMP,
    fecha_salida TIMESTAMP,
    tarifa NUMERIC(10,2),
    importe NUMERIC(10,2),
    estatus VARCHAR(1),
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.id,
        v.fecha_proceso,
        v.folio,
        v.placa,
        v.fecha_entrada,
        v.fecha_salida,
        v.tarifa,
        v.importe,
        v.estatus,
        v.observaciones
    FROM ta14_valet_paso v
    WHERE (p_fecha_desde IS NULL OR v.fecha_proceso >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR v.fecha_proceso <= p_fecha_hasta)
      AND (p_placa IS NULL OR v.placa ILIKE '%' || p_placa || '%')
    ORDER BY v.fecha_proceso DESC, v.id DESC
    LIMIT 500;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_valet_paso_resumen
-- Tipo: Reporte
-- Descripcion: Resumen de procesamiento por fecha
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_valet_paso_resumen(DATE, DATE);

CREATE OR REPLACE FUNCTION sp_valet_paso_resumen(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    fecha DATE,
    total_registros BIGINT,
    total_importe NUMERIC,
    placas_unicas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.fecha_proceso,
        COUNT(*)::BIGINT,
        COALESCE(SUM(v.importe), 0)::NUMERIC,
        COUNT(DISTINCT v.placa)::BIGINT
    FROM ta14_valet_paso v
    WHERE (p_fecha_desde IS NULL OR v.fecha_proceso >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR v.fecha_proceso <= p_fecha_hasta)
    GROUP BY v.fecha_proceso
    ORDER BY v.fecha_proceso DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP: sp_valet_paso_eliminar
-- Tipo: CRUD
-- Descripcion: Elimina registros de valet por fecha
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_valet_paso_eliminar(DATE);

CREATE OR REPLACE FUNCTION sp_valet_paso_eliminar(
    p_fecha DATE
)
RETURNS TABLE(result INTEGER, msg TEXT) AS $$
DECLARE
    v_eliminados INTEGER;
BEGIN
    DELETE FROM ta14_valet_paso WHERE fecha_proceso = p_fecha;
    GET DIAGNOSTICS v_eliminados = ROW_COUNT;

    IF v_eliminados > 0 THEN
        RETURN QUERY SELECT 1, ('Se eliminaron ' || v_eliminados || ' registros del ' || p_fecha)::TEXT;
    ELSE
        RETURN QUERY SELECT 0, ('No se encontraron registros para la fecha ' || p_fecha)::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GRANT de permisos
GRANT EXECUTE ON FUNCTION sp_valet_paso_procesar TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_valet_paso_consultar TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_valet_paso_resumen TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_valet_paso_eliminar TO PUBLIC;
GRANT ALL ON TABLE ta14_valet_paso TO PUBLIC;
GRANT USAGE, SELECT ON SEQUENCE ta14_valet_paso_id_seq TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
