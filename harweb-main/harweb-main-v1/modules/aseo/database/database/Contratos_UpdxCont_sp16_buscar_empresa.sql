-- Stored Procedure: sp16_buscar_empresa
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE).
-- Generado para formulario: Contratos_UpdxCont
-- Fecha: 2025-08-27 14:22:10

CREATE OR REPLACE FUNCTION sp16_buscar_empresa(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT num_empresa, ctrol_emp, descripcion, representante
    FROM ta_16_empresas
    WHERE UPPER(descripcion) LIKE '%' || UPPER(p_nombre) || '%'
      AND ctrol_emp = 9
    ORDER BY num_empresa;
END;
$$ LANGUAGE plpgsql;