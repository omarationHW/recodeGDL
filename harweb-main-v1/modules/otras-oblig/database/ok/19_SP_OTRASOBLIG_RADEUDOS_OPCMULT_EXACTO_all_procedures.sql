-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: RAdeudos_OpcMult (EXACTO del archivo original)
-- Archivo: 19_SP_OTRASOBLIG_RADEUDOS_OPCMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: con34_rdetade_021
-- Tipo: Report
-- Descripción: Obtiene los adeudos de un local por id_datos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con34_rdetade_021(p_id_datos integer)
RETURNS TABLE(registro integer, axo integer, mes integer, periodo date, importe numeric, recargo numeric) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo, axo, mes, periodo, importe, recargo
  FROM otrasoblig.t34_adeudos
  WHERE id_datos = p_id_datos AND status = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: upd34_ade_01
-- Tipo: CRUD
-- Descripción: Actualiza el status de un adeudo (pagado, condonado, cancelado, prescrito)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION upd34_ade_01(
  par_id_datos integer,
  par_Axo integer,
  par_Mes integer,
  par_Fecha date,
  par_Id_Rec integer,
  par_Caja varchar,
  par_Consec integer,
  par_Folio_rcbo varchar,
  par_tab varchar,
  par_status varchar,
  par_Opc varchar
) RETURNS TABLE(status integer, concepto_status varchar) AS $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM otrasoblig.t34_adeudos WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  IF v_count = 0 THEN
    RETURN QUERY SELECT 1, 'Adeudo no encontrado';
    RETURN;
  END IF;
  UPDATE otrasoblig.t34_adeudos
    SET status = par_status,
        fecha_pago = par_Fecha,
        id_recaudadora = par_Id_Rec,
        caja = par_Caja,
        operacion = par_Consec,
        folio_recibo = par_Folio_rcbo
    WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  RETURN QUERY SELECT 0, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: ta_12_recaudadoras
-- Tipo: Catalog
-- Descripción: Catálogo de recaudadoras
-- --------------------------------------------

-- Tabla: otrasoblig.ta_12_recaudadoras
-- id_rec, recaudadora, domicilio, tel, recaudador, sector
-- SELECT id_rec, recaudadora FROM otrasoblig.ta_12_recaudadoras ORDER BY id_rec;

-- ============================================

-- SP 4/4: ta_12_operaciones
-- Tipo: Catalog
-- Descripción: Catálogo de cajas por recaudadora
-- --------------------------------------------

-- Tabla: otrasoblig.ta_12_operaciones
-- id_rec, caja, operacion, id_usuario, tip_impresora
-- SELECT id_rec, caja FROM otrasoblig.ta_12_operaciones ORDER BY id_rec, caja;

-- ============================================