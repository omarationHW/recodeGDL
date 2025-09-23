-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Upd_01
-- Generado: 2025-08-27 14:24:09
-- Total SPs: 10
-- ============================================

-- SP 1/10: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo() RETURNS TABLE (ctrol_aseo integer, tipo_aseo varchar, descripcion varchar, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/10: sp_get_unidades
-- Tipo: Catalog
-- Descripción: Obtiene unidades de recolección por ejercicio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_unidades(ejercicio integer) RETURNS TABLE (ctrol_recolec integer, cve_recolec varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_recolec, cve_recolec, descripcion FROM ta_16_unidades WHERE ejercicio_recolec = ejercicio ORDER BY ctrol_recolec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/10: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene todas las zonas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_zonas() RETURNS TABLE (ctrol_zona integer, zona smallint, sub_zona smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY zona, sub_zona;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/10: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene todas las recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras() RETURNS TABLE (id_rec smallint, id_zona integer, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

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
    FROM ta_16_contratos C
    JOIN ta_16_empresas A ON A.num_empresa = C.num_empresa AND A.ctrol_emp = C.ctrol_emp
    JOIN ta_16_tipos_emp B ON A.ctrol_emp = B.ctrol_emp
    JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
    WHERE C.num_contrato = num_contrato AND C.ctrol_aseo = ctrol_aseo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/10: sp_buscar_empresas
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_empresas(nombre varchar) RETURNS TABLE (num_empresa integer, ctrol_emp integer, descripcion varchar, representante varchar) AS $$
BEGIN
  RETURN QUERY SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante
    FROM ta_16_empresas a, ta_16_tipos_emp b
    WHERE a.descripcion ILIKE '%' || nombre || '%' AND b.ctrol_emp = a.ctrol_emp
    ORDER BY a.num_empresa;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/10: sp_busca_convenio
-- Tipo: CRUD
-- Descripción: Busca convenio relacionado a un contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_convenio(idlc integer) RETURNS TABLE (convenio varchar, id_conv_resto integer) AS $$
BEGIN
  RETURN QUERY
    SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio, b.id_conv_resto
    FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d
    WHERE a.id_referencia = idlc AND a.modulo = 16
      AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
      AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/10: sp_licencias_relacionadas
-- Tipo: CRUD
-- Descripción: Obtiene licencias relacionadas a un contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_licencias_relacionadas(control_contrato integer) RETURNS TABLE (
  num_licencia integer, actividad varchar, propietario varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_licencia, b.actividad, b.propietario
    FROM ta_16_rel_licgiro a
    JOIN catastro_gdl."Licencias" b ON b.licencia = a.num_licencia AND b.vigente = 'V'
    WHERE a.control_contrato = control_contrato
    ORDER BY a.num_licencia;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/10: sp_licencia_giro_abc
-- Tipo: CRUD
-- Descripción: Aplica acción sobre relación licencia-giro/contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_licencia_giro_abc(opc varchar, licencia_giro integer, control_contrato integer) RETURNS TABLE (status integer, leyenda varchar) AS $$
BEGIN
  IF opc = 'A' THEN
    -- Activar/Re-Activar
    INSERT INTO ta_16_rel_licgiro (id, num_licencia, control_contrato, vigencia)
    VALUES (DEFAULT, licencia_giro, control_contrato, 'V')
    ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V';
    RETURN QUERY SELECT 0, 'Licencia activada o reactivada';
  ELSIF opc = 'D' THEN
    -- Desligar/Eliminar
    DELETE FROM ta_16_rel_licgiro WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia desligada/eliminada';
  ELSIF opc = 'C' THEN
    -- Cancelar
    UPDATE ta_16_rel_licgiro SET vigencia = 'C' WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia cancelada';
  ELSE
    RETURN QUERY SELECT 1, 'Opción no válida';
  END IF;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 10/10: sp_upd16_contrato_01
-- Tipo: CRUD
-- Descripción: Actualiza contrato según opción (ver lógica Delphi)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_upd16_contrato_01(
  par_Control_Cont integer,
  par_Num_Emp integer,
  par_Ctrol_Emp integer,
  par_Cant_recolec integer,
  par_Ctrol_Zona integer,
  par_Id_Rec integer,
  par_Axo_Ini integer,
  par_Mes_Ini integer,
  par_Opcion integer,
  par_Cve_recolec varchar,
  par_Domicilio varchar,
  par_Sector varchar,
  par_Docto varchar,
  par_Descrip varchar
) RETURNS TABLE (status integer, concepto varchar) AS $$
DECLARE
  v_status integer := 0;
  v_concepto varchar := '';
BEGIN
  -- Opción 0: Cambiar tipo de unidad de recolección
  IF par_Opcion = 0 THEN
    UPDATE ta_16_contratos SET ctrol_recolec = (SELECT ctrol_recolec FROM ta_16_unidades WHERE cve_recolec = par_Cve_recolec LIMIT 1)
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Tipo de unidad de recolección actualizado';
  ELSIF par_Opcion = 1 THEN
    -- Cambiar inicio de obligación
    UPDATE ta_16_contratos SET aso_mes_oblig = make_date(par_Axo_Ini, par_Mes_Ini, 1)
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Inicio de obligación actualizado';
  ELSIF par_Opcion = 2 THEN
    -- Cambiar cantidad de unidades
    UPDATE ta_16_contratos SET cantidad_recolec = par_Cant_recolec
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Cantidad de unidades actualizada';
  ELSIF par_Opcion = 3 THEN
    -- Cambio de empresa
    UPDATE ta_16_contratos SET num_empresa = par_Num_Emp, ctrol_emp = par_Ctrol_Emp
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Empresa actualizada';
  ELSIF par_Opcion = 4 THEN
    -- Cambio de domicilio
    UPDATE ta_16_contratos SET domicilio = par_Domicilio
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Domicilio actualizado';
  ELSIF par_Opcion = 5 THEN
    -- Cambio de zona
    UPDATE ta_16_contratos SET ctrol_zona = par_Ctrol_Zona
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Zona actualizada';
  ELSIF par_Opcion = 6 THEN
    -- Cambio de sector
    UPDATE ta_16_contratos SET sector = par_Sector
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Sector actualizado';
  ELSIF par_Opcion = 7 THEN
    -- Cambio de recaudadora
    UPDATE ta_16_contratos SET id_rec = par_Id_Rec
    WHERE control_contrato = par_Control_Cont;
    v_concepto := 'Recaudadora actualizada';
  ELSE
    v_status := 1;
    v_concepto := 'Opción no válida';
  END IF;
  RETURN QUERY SELECT v_status, v_concepto;
END; $$ LANGUAGE plpgsql;

-- ============================================

