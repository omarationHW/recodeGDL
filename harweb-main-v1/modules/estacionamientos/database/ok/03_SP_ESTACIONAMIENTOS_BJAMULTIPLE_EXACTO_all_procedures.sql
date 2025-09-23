-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: Bja_Multiple (EXACTO del archivo original)
-- Archivo: 03_SP_ESTACIONAMIENTOS_BJAMULTIPLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_insert_folios_baja_esta
-- Tipo: CRUD
-- Descripción: Inserta un registro en la tabla ta14_folios_baja_esta.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_insert_folios_baja_esta(
    p_archivo VARCHAR,
    p_referencia INTEGER,
    p_folio_archivo INTEGER,
    p_fecha_archivo VARCHAR,
    p_placa VARCHAR,
    p_anomalia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.ta14_folios_baja_esta (
        archivo, referencia, folio_archivo, fecha_archivo, placa, anomalia, tarifa, estatus, fecha_captura, usuario, observaciones
    ) VALUES (
        p_archivo, p_referencia, p_folio_archivo, p_fecha_archivo, p_placa, p_anomalia, NULL, NULL, CURRENT_DATE, NULL, NULL
    );
END;
$$;

-- ============================================

-- SP 2/3: sp14_ejecuta_sp
-- Tipo: CRUD
-- Descripción: Realiza el llenado y aplicación de los folios grabados. (Lógica a definir según reglas de negocio, aquí es un ejemplo genérico)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp14_ejecuta_sp()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Ejemplo: Actualizar estatus a 9 (error de validación) para registros con algún criterio
    UPDATE public.ta14_folios_baja_esta
    SET estatus = 9
    WHERE estatus IS NULL AND (anomalia IS NULL OR anomalia = '');
    -- Aquí se puede agregar más lógica de aplicación según reglas de negocio
END;
$$;

-- ============================================

-- SP 3/3: sp_get_incidencias_baja_multiple
-- Tipo: Report
-- Descripción: Devuelve los registros con error de validación (estatus = 9) para un archivo dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_incidencias_baja_multiple(p_archivo VARCHAR)
RETURNS TABLE (
    placa VARCHAR,
    folio_archivo INTEGER,
    fecha_archivo VARCHAR,
    anomalia VARCHAR,
    referencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT placa, folio_archivo, fecha_archivo, anomalia, referencia
    FROM public.ta14_folios_baja_esta
    WHERE archivo = p_archivo AND estatus = 9;
END;
$$ LANGUAGE plpgsql;

-- ============================================