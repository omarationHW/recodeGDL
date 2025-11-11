-- =====================================================
-- SP: sp_lista_eje_get
-- Descripción: Lista ejecutores (catálogo) para selección en formularios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_lista_eje_get()
RETURNS TABLE (
    cve_eje INTEGER,
    nombre VARCHAR(60),
    vigencia CHAR(1),
    id_rec SMALLINT,
    oficio VARCHAR(14),
    fecinic DATE,
    fecterm DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.cve_eje,
        e.nombre,
        e.vigencia,
        e.id_rec,
        e.oficio,
        e.fecinic,
        e.fecterm
    FROM ta_15_ejecutores e
    WHERE e.vigencia = '1'
    ORDER BY e.nombre, e.cve_eje;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_lista_eje_get();
-- SELECT cve_eje, nombre FROM sp_lista_eje_get() WHERE id_rec = 1;
