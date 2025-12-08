-- =====================================================
-- SPs CRUD para Ejecutores
-- Base: padron_licencias
-- Esquema: comun
-- Ejecutar en: padron_licencias
-- =====================================================

-- 1. SP UPDATE - Actualizar ejecutor
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_update(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT,
    p_ini_rfc CHARACTER VARYING,
    p_fec_rfc DATE,
    p_hom_rfc CHARACTER VARYING,
    p_nombre CHARACTER VARYING,
    p_oficio CHARACTER VARYING,
    p_fecinic DATE,
    p_fecterm DATE
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE comun.ta_15_ejecutores
    SET
        ini_rfc = p_ini_rfc,
        fec_rfc = p_fec_rfc,
        hom_rfc = p_hom_rfc,
        nombre = p_nombre,
        oficio = p_oficio,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        vigencia = 'A'
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF FOUND THEN
        RETURN QUERY SELECT 'OK'::TEXT;
    ELSE
        RETURN QUERY SELECT 'No existe ejecutor con esa clave'::TEXT;
    END IF;
END;
$$;

-- 2. SP CREATE - Crear nuevo ejecutor
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_create(
    p_cve_eje INTEGER,
    p_ini_rfc CHARACTER VARYING,
    p_fec_rfc DATE,
    p_hom_rfc CHARACTER VARYING,
    p_nombre CHARACTER VARYING,
    p_id_rec SMALLINT,
    p_oficio CHARACTER VARYING,
    p_fecinic DATE,
    p_fecterm DATE
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Verificar si ya existe
    SELECT COUNT(*) INTO v_existe
    FROM comun.ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT 'Ya existe ejecutor con ese número en la recaudadora'::TEXT;
        RETURN;
    END IF;

    -- Obtener el siguiente id_ejecutor
    SELECT COALESCE(MAX(id_ejecutor), 0) + 1 INTO v_new_id FROM comun.ta_15_ejecutores;

    -- Insertar nuevo ejecutor
    INSERT INTO comun.ta_15_ejecutores (
        id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec,
        oficio, fecinic, fecterm, vigencia
    ) VALUES (
        v_new_id, p_cve_eje, p_ini_rfc, p_fec_rfc, p_hom_rfc, p_nombre, p_id_rec,
        p_oficio, p_fecinic, p_fecterm, 'A'
    );

    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$;

-- 3. SP TOGGLE VIGENCIA - Baja/Reactiva ejecutor
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_toggle_vigencia(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vigencia_actual CHARACTER(1);
BEGIN
    -- Obtener vigencia actual
    SELECT vigencia INTO v_vigencia_actual
    FROM comun.ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'No existe ejecutor con esa clave'::TEXT;
        RETURN;
    END IF;

    -- Toggle vigencia
    IF v_vigencia_actual = 'A' OR v_vigencia_actual = 'V' THEN
        UPDATE comun.ta_15_ejecutores
        SET vigencia = 'B'
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Baja'::TEXT;
    ELSE
        UPDATE comun.ta_15_ejecutores
        SET vigencia = 'A'
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Reactivado'::TEXT;
    END IF;
END;
$$;

-- Verificar creación
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'SPs CRUD creados exitosamente:';
    RAISE NOTICE '  - comun.sp_ejecutor_update';
    RAISE NOTICE '  - comun.sp_ejecutor_create';
    RAISE NOTICE '  - comun.sp_ejecutor_toggle_vigencia';
    RAISE NOTICE '=====================================================';
END $$;
