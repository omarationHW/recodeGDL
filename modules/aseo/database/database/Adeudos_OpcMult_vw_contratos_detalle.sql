-- Stored Procedure: vw_contratos_detalle
-- Tipo: Catalog
-- Descripción: Vista para obtener detalle de contrato por número y tipo de aseo
-- Generado para formulario: Adeudos_OpcMult
-- Fecha: 2025-08-27 20:39:32

CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.*, e.descripcion as nom_emp, e.representante, e.domicilio, c.status_vigencia
FROM ta_16_contratos c
JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;