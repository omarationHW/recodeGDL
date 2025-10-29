-- Stored Procedure: sp16_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo, devuelve todos los datos relevantes.
-- Generado para formulario: Contratos_UpdxCont
-- Fecha: 2025-08-27 14:22:10

CREATE OR REPLACE FUNCTION sp16_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    id_rec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_contrato, num_contrato, ctrol_aseo, num_empresa, ctrol_emp, ctrol_recolec, cantidad_recolec, domicilio, sector, ctrol_zona, id_rec, fecha_hora_alta, status_vigencia, aso_mes_oblig, cve, usuario, fecha_hora_baja
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;