-- Stored Procedure: sp_buscar_contratos_asc
-- Tipo: Report
-- Descripción: Busca contratos cuyo número sea mayor o igual al parámetro y por tipo de aseo, orden ascendente.
-- Generado para formulario: Pagos_Cons_ContAsc
-- Fecha: 2025-08-27 15:00:04

CREATE OR REPLACE FUNCTION sp_buscar_contratos_asc(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, b.tipo_aseo, b.descripcion
    FROM ta_16_contratos a
    JOIN ta_16_tipo_aseo b ON a.ctrol_aseo = b.ctrol_aseo
    WHERE a.num_contrato >= p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    ORDER BY a.num_contrato ASC;
END;
$$ LANGUAGE plpgsql;