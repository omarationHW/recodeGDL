-- =====================================================
-- SP: sp_carta_invitacion
-- Descripción: Genera datos para cartas de invitación de apremios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_carta_invitacion(
    p_folio VARCHAR(50)
)
RETURNS TABLE (
    folio VARCHAR(50),
    nombre VARCHAR(255),
    direccion TEXT,
    importe NUMERIC(12,2),
    fecha DATE,
    modulo VARCHAR(50),
    zona VARCHAR(50),
    observaciones TEXT,
    ejecutor_nombre VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio::VARCHAR(50) AS folio,
        COALESCE(a.datos, 'No especificado')::VARCHAR(255) AS nombre,
        COALESCE(a.observaciones, 'Sin dirección registrada')::TEXT AS direccion,
        COALESCE(a.importe_global, 0)::NUMERIC(12,2) AS importe,
        COALESCE(a.fecha_emision, CURRENT_DATE)::DATE AS fecha,
        COALESCE(a.modulo::VARCHAR, 'N/A')::VARCHAR(50) AS modulo,
        COALESCE(a.zona::VARCHAR, 'N/A')::VARCHAR(50) AS zona,
        COALESCE(a.observaciones, '')::TEXT AS observaciones,
        COALESCE(e.nombre, 'Sin ejecutor')::VARCHAR(255) AS ejecutor_nombre
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.folio::VARCHAR = p_folio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_carta_invitacion('12345');
-- SELECT * FROM sp_carta_invitacion('98765');
