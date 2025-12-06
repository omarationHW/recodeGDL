-- Stored Procedure: sp_reporte_catalogo_mercados
-- Tipo: Report
-- Descripción: Genera el reporte del catálogo de mercados con filtros opcionales
-- Formulario: RptCatalogoMerc
-- Fecha corrección: 2025-12-05

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
        m.descripcion,
        COALESCE(z.zona, 'SIN ZONA')::VARCHAR AS domicilio,
        COALESCE(z.zona, 'SIN ZONA')::VARCHAR AS zona,
        COALESCE(m.tipo_emision, 'M')::VARCHAR AS tipo_emision,
        CASE
            WHEN m.num_mercado_nvo < 99 THEN 'A'::VARCHAR
            ELSE 'I'::VARCHAR
        END AS estado
    FROM ta_11_mercados m
    LEFT JOIN ta_12_zonas z ON m.id_zona = z.id_zona
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
-- 2. El campo domicilio se mapea desde ta_12_zonas.zona (no existe campo domicilio en zonas)
-- 3. El campo zona también viene de ta_12_zonas.zona
-- 4. El campo estado se deriva de la lógica: mercados < 99 son Activos, >= 99 son Inactivos
-- 5. El tipo_emision usa 'M' (Mensual) como valor por defecto si es NULL
-- 6. Los parámetros son opcionales (DEFAULT NULL) para permitir consultas sin filtros
