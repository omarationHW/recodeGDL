-- Stored Procedure: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de aseo. Si tipo=0, trae todos excepto los de Ctrol_Aseo=0; si no, filtra por Ctrol_Aseo.
-- Generado para formulario: uDM_Procesos
-- Fecha: 2025-08-27 15:45:14

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo(tipo integer)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer
) AS $$
BEGIN
    IF tipo = 0 THEN
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo <> 0;
    ELSE
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo = tipo;
    END IF;
END;
$$ LANGUAGE plpgsql;