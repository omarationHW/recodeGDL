-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

-- SP 1/10: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo() RETURNS TABLE (ctrol_aseo integer, tipo_aseo varchar, descripcion varchar, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM public.ta_16_tipo_aseo ORDER BY ctrol_aseo;
END; $$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

-- SP 3/10: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene todas las zonas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_zonas() RETURNS TABLE (ctrol_zona integer, zona smallint, sub_zona smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_zona, zona, sub_zona, descripcion FROM public.ta_16_zonas ORDER BY zona, sub_zona;
END; $$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

-- SP 5/10: sp_busca_contrato
-- Tipo: CRUD
-- Descripción: Busca contrato por número y tipo de aseo
-- --------------------------------------------

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
    FROM public.ta_16_contratos C
    JOIN public.ta_16_empresas A ON A.num_empresa = C.num_empresa AND A.ctrol_emp = C.ctrol_emp
    JOIN public.ta_16_tipos_emp B ON A.ctrol_emp = B.ctrol_emp
    JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec
    WHERE C.num_contrato = num_contrato AND C.ctrol_aseo = ctrol_aseo;
END; $$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

-- SP 7/10: sp_busca_convenio
-- Tipo: CRUD
-- Descripción: Busca convenio relacionado a un contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_convenio(idlc integer) RETURNS TABLE (convenio varchar, id_conv_resto integer) AS $$
BEGIN
  RETURN QUERY
    SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio, b.id_conv_resto
    FROM public.ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d
    WHERE a.id_referencia = idlc AND a.modulo = 16
      AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
      AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END; $$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

-- SP 9/10: sp_licencia_giro_abc
-- Tipo: CRUD
-- Descripción: Aplica acción sobre relación licencia-giro/contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_licencia_giro_abc(opc varchar, licencia_giro integer, control_contrato integer) RETURNS TABLE (status integer, leyenda varchar) AS $$
BEGIN
  IF opc = 'A' THEN
    -- Activar/Re-Activar
    INSERT INTO public.ta_16_rel_licgiro (id, num_licencia, control_contrato, vigencia)
    VALUES (DEFAULT, licencia_giro, control_contrato, 'V')
    ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V';
    RETURN QUERY SELECT 0, 'Licencia activada o reactivada';
  ELSIF opc = 'D' THEN
    -- Desligar/Eliminar
    DELETE FROM public.ta_16_rel_licgiro WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia desligada/eliminada';
  ELSIF opc = 'C' THEN
    -- Cancelar
    UPDATE public.ta_16_rel_licgiro SET vigencia = 'C' WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia cancelada';
  ELSE
    RETURN QUERY SELECT 1, 'Opción no válida';
  END IF;
END; $$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD_01 (EXACTO del archivo original)
-- Archivo: 63_SP_ASEO_CONTRATOS_UPD_01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 10 (EXACTO)
-- ============================================

