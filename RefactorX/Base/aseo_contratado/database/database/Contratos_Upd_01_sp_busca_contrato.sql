-- Stored Procedure: sp_busca_contrato
-- Tipo: CRUD
-- Descripción: Busca contrato por número y tipo de aseo
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_busca_contrato(num_contrato integer, ctrol_aseo integer) RETURNS TABLE (
  num_empresa integer, ctrol_emp integer, tipo_empresa varchar, descripcion varchar, nom_emp varchar, representante varchar,
  control_contrato integer, num_contrato integer, ctrol_aseo integer, tipo_aseo varchar, descrip_aseo varchar,
  ctrol_recolec integer, cve_recolec varchar, descrip_und varchar, cantidad_recolec smallint,
  domicilio varchar, sector varchar, ctrol_zona integer, zona smallint, sub_zona smallint, descripcion_1 varchar, datos_zona varchar,
  id_rec smallint, recaudadora varchar, fecha_hora_alta timestamp, status_vigencia varchar, aso_mes_oblig date, cve varchar, usuario integer, fecha_hora_baja timestamp
) AS $$
BEGIN
  RETURN QUERY
    SELECT A.num_empresa, A.ctrol_emp, B.tipo_empresa, B.descripcion, A.descripcion AS nom_emp, A.representante,
      C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion AS descrip_aseo,
      C.ctrol_recolec, E.cve_recolec, E.descripcion AS descrip_und, C.cantidad_recolec,
      C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion AS descripcion_1,
      (C.ctrol_zona || '-' || F.zona || '-' || F.sub_zona || '-' || F.descripcion) AS datos_zona,
      C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja
    FROM ta_16_contratos C
    JOIN ta_16_empresas A ON A.num_empresa = C.num_empresa AND A.ctrol_emp = C.ctrol_emp
    JOIN ta_16_tipos_emp B ON A.ctrol_emp = B.ctrol_emp
    JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
    WHERE C.num_contrato = num_contrato AND C.ctrol_aseo = ctrol_aseo;
END; $$ LANGUAGE plpgsql;