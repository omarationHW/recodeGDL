-- Stored Procedure: sp16_contratos
-- Tipo: Report
-- Descripción: Obtiene el padrón de contratos filtrado por tipo y vigencia.
-- Generado para formulario: Rep_PadronContratos
-- Fecha: 2025-08-27 15:10:45

CREATE OR REPLACE FUNCTION sp16_contratos(parTipo TEXT, parVigencia TEXT)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    calle TEXT,
    numext TEXT,
    numint TEXT,
    colonia TEXT,
    sector TEXT,
    cp TEXT,
    rfc TEXT,
    municipio TEXT,
    estado TEXT,
    curp TEXT,
    status_contrato TEXT,
    num_empresa INTEGER,
    nombre_empresa TEXT,
    representante_empresa TEXT,
    tipo_aseo TEXT,
    tipo_aseo_descripcion TEXT,
    cve_recoleccion TEXT,
    unidad_recoleccion TEXT,
    cantidad_recoleccion INTEGER,
    inicio_oblig TEXT,
    fin_oblig TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato, c.num_contrato, c.calle, c.numext, c.numint, c.colonia, c.sector, c.cp, c.rfc, c.municipio, c.estado, c.curp, c.status_contrato,
        c.num_empresa, e.descripcion AS nombre_empresa, e.representante AS representante_empresa,
        c.tipo_aseo, ta.descripcion AS tipo_aseo_descripcion, c.cve_recoleccion, u.descripcion AS unidad_recoleccion, c.cantidad_recoleccion,
        to_char(c.aso_mes_oblig, 'YYYY-MM') AS inicio_oblig,
        to_char(c.fecha_hora_baja, 'YYYY-MM') AS fin_oblig
    FROM ta_16_contratos c
    JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa
    JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_unidades u ON u.ctrol_recolec = c.ctrol_recolec
    WHERE (parTipo = 'T' OR c.tipo_aseo = parTipo)
      AND (parVigencia = 'T' OR c.status_vigencia = parVigencia)
    ORDER BY c.control_contrato, c.num_contrato, c.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;