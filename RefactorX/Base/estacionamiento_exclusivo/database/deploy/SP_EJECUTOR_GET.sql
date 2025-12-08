-- =====================================================
-- SP: comun.sp_ejecutor_get
-- Base: padron_licencias
-- Ejecutar en: padron_licencias
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_ejecutor_get(
    p_cve_eje INTEGER,
    p_id_rec INTEGER
)
RETURNS TABLE(
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHARACTER(4),
    fec_rfc DATE,
    hom_rfc CHARACTER(3),
    nombre CHARACTER VARYING,
    id_rec SMALLINT,
    categoria CHARACTER VARYING,
    observacion CHARACTER VARYING,
    oficio CHARACTER VARYING,
    fecinic DATE,
    fecterm DATE,
    vigencia CHARACTER(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje,
        e.ini_rfc::CHARACTER(4),
        e.fec_rfc,
        e.hom_rfc::CHARACTER(3),
        e.nombre::CHARACTER VARYING,
        e.id_rec,
        e.categoria::CHARACTER VARYING,
        e.observacion::CHARACTER VARYING,
        e.oficio::CHARACTER VARYING,
        e.fecinic,
        e.fecterm,
        e.vigencia::CHARACTER(1)
    FROM comun.ta_15_ejecutores e
    WHERE e.cve_eje = p_cve_eje
      AND (p_id_rec IS NULL OR e.id_rec = p_id_rec);
END;
$$;

-- Verificar creación
DO $$
BEGIN
    RAISE NOTICE 'SP comun.sp_ejecutor_get creado exitosamente';
END $$;
