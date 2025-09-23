CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.*, e.descripcion as nom_emp, e.representante, e.domicilio, c.status_vigencia
FROM ta_16_contratos c
JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;