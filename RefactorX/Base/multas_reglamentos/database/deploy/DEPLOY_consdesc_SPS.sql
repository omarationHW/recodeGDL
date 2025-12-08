-- ============================================
-- STORED PROCEDURE PARA consdesc.vue
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-26
-- Descripcion: SP para consulta de descuentos
-- ============================================

DROP FUNCTION IF EXISTS consdesc_sp_buscar(VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION consdesc_sp_buscar(
    p_cuenta VARCHAR DEFAULT '',
    p_tipo VARCHAR DEFAULT '',
    p_estado VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_descuento INTEGER,
    cuenta VARCHAR,
    tipo VARCHAR,
    porcentaje INTEGER,
    autoriza VARCHAR,
    fecha DATE,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dm.id_descto::INTEGER AS id_descuento,
        dm.id_contrato::TEXT::VARCHAR AS cuenta,
        'M'::VARCHAR AS tipo,
        COALESCE(dm.porcentaje, 0)::INTEGER AS porcentaje,
        COALESCE(TRIM(dm.usuario_alta), '')::VARCHAR AS autoriza,
        dm.fecha_alta::DATE AS fecha,
        COALESCE(dm.vigencia, 'V')::VARCHAR AS estado
    FROM t34_descmul dm
    WHERE
        (p_cuenta = '' OR dm.id_contrato::TEXT LIKE '%' || p_cuenta || '%')
        AND (p_tipo = '' OR p_tipo = 'M')
        AND (p_estado = '' OR dm.vigencia = p_estado)

    UNION ALL

    SELECT
        dr.id_descto::INTEGER AS id_descuento,
        dr.id_contrato::TEXT::VARCHAR AS cuenta,
        'R'::VARCHAR AS tipo,
        COALESCE(dr.porcentaje, 0)::INTEGER AS porcentaje,
        COALESCE(TRIM(dr.usuario_alta), '')::VARCHAR AS autoriza,
        dr.fecha_alta::DATE AS fecha,
        COALESCE(dr.vigencia, 'V')::VARCHAR AS estado
    FROM t34_descrec dr
    WHERE
        (p_cuenta = '' OR dr.id_contrato::TEXT LIKE '%' || p_cuenta || '%')
        AND (p_tipo = '' OR p_tipo = 'R')
        AND (p_estado = '' OR dr.vigencia = p_estado)

    ORDER BY fecha DESC NULLS LAST
    LIMIT 200;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION consdesc_sp_buscar(VARCHAR, VARCHAR, VARCHAR) IS 'Busca descuentos por cuenta, tipo y estado';

SELECT 'SP consdesc_sp_buscar creado correctamente' AS status;
