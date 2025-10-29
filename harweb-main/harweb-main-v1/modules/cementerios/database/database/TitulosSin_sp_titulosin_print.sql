-- Stored Procedure: sp_titulosin_print
-- Tipo: CRUD
-- Descripción: Prepara los datos para la impresión del título sin referencias. Puede devolver los datos en formato JSON o PDF.
-- Generado para formulario: TitulosSin
-- Fecha: 2025-08-27 14:58:45

CREATE OR REPLACE FUNCTION sp_titulosin_print(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER,
    p_rec SMALLINT,
    p_telefono VARCHAR
) RETURNS JSON AS $$
DECLARE
    folio_data RECORD;
    rec_data RECORD;
    result JSON;
BEGIN
    SELECT * INTO folio_data FROM sp_titulosin_get_folio(p_folio, p_fecha, p_operacion);
    SELECT * INTO rec_data FROM sp_titulosin_get_rec(p_rec);
    result := json_build_object(
        'folio', folio_data,
        'rec', rec_data,
        'telefono', p_telefono
    );
    RETURN result;
END;
$$ LANGUAGE plpgsql;