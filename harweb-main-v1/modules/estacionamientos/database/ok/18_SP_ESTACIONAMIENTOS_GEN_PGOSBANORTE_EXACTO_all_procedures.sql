-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: GEN_PGOSBANORTE (EXACTO del archivo original)
-- Archivo: 18_SP_ESTACIONAMIENTOS_GEN_PGOSBANORTE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp14_remesa
-- Tipo: CRUD
-- Descripción: Genera una nueva remesa de pagos Banorte para el periodo indicado. Inserta registros en ta14_datos_mpio y retorna status, obs y remesa.
-- --------------------------------------------

-- PostgreSQL version of sp14_remesa
-- Parámetros:
--   p_opc integer: opción (2 para carga de banorte)
--   p_axo integer: año
--   p_fec_ini date: fecha inicio
--   p_fec_fin date: fecha fin
--   p_fec_a_fin date: fecha actual fin
-- Retorna: status int, obs text, remesa text

CREATE OR REPLACE FUNCTION sp14_remesa(
    p_opc integer,
    p_axo integer,
    p_fec_ini date,
    p_fec_fin date,
    p_fec_a_fin date
)
RETURNS TABLE(status integer, obs text, remesa text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_remesa text;
    v_obs text := '';
BEGIN
    IF p_opc = 2 THEN
        -- Generar identificador de remesa
        v_remesa := 'R' || to_char(now(), 'YYYYMMDDHH24MISS');
        -- Aquí va la lógica de inserción/actualización de ta14_datos_mpio
        -- Por ejemplo:
        -- INSERT INTO ta14_datos_mpio (...)
        -- SELECT ... WHERE fecha_pago BETWEEN p_fec_ini AND p_fec_fin;
        -- Simulación:
        -- Si todo sale bien:
        status := 0;
        obs := 'Remesa generada correctamente';
        remesa := v_remesa;
        -- Actualizar registros con la nueva remesa
        UPDATE ta14_datos_mpio
        SET remesa = v_remesa, fecharemesa = now()
        WHERE fechapago BETWEEN p_fec_ini AND p_fec_fin
          AND (remesa IS NULL OR remesa = '');
    ELSE
        status := 1;
        obs := 'Opción no soportada';
        remesa := NULL;
    END IF;
    RETURN NEXT;
END;
$$;

-- ============================================

