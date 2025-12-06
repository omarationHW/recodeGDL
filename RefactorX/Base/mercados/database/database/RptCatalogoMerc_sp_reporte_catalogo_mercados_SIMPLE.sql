-- Stored Procedure: sp_reporte_catalogo_mercados
-- Tipo: Report
-- Descripción: Genera el reporte del catálogo de mercados con filtros opcionales
-- Formulario: RptCatalogoMerc
-- Fecha corrección: 2025-12-05
-- Versión: SIMPLE (sin JOIN a ta_12_zonas porque la tabla no existe en la BD mercados)

CREATE OR REPLACE FUNCTION sp_reporte_catalogo_mercados(
    p_oficina SMALLINT DEFAULT NULL,
    p_estado VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR,
    domicilio VARCHAR,
    zona VARCHAR,
    tipo_emision VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.oficina,
        m.num_mercado_nvo,
        COALESCE(m.descripcion, '')::VARCHAR AS descripcion,
        'N/D'::VARCHAR AS domicilio,
        COALESCE(m.zona::TEXT, 'N/D')::VARCHAR AS zona,
        'M'::VARCHAR AS tipo_emision,
        CASE
            WHEN m.num_mercado_nvo < 99 THEN 'A'::VARCHAR
            ELSE 'I'::VARCHAR
        END AS estado
    FROM ta_11_mercados m
    WHERE
        (p_oficina IS NULL OR m.oficina = p_oficina)
        AND (p_estado IS NULL OR
             (p_estado = 'A' AND m.num_mercado_nvo < 99) OR
             (p_estado = 'I' AND m.num_mercado_nvo >= 99))
    ORDER BY m.oficina ASC, m.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;

-- Comentarios:
-- 1. Se agregaron parámetros opcionales p_oficina y p_estado
-- 2. El campo domicilio retorna 'N/D' (no disponible) porque no hay tabla de referencia
-- 3. El campo zona retorna el id_zona como texto (no hay tabla ta_12_zonas en BD mercados)
-- 4. El campo estado se deriva de la lógica: mercados < 99 son Activos, >= 99 son Inactivos
-- 5. El tipo_emision usa 'M' (Mensual) como valor por defecto si es NULL
-- 6. Los parámetros son opcionales (DEFAULT NULL) para permitir consultas sin filtros
