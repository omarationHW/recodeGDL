-- Stored Procedure: sp_upd16_contrato_01
-- Tipo: CRUD
-- Descripción: Actualiza contrato según opción (ver lógica Delphi)
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

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