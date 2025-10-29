-- Stored Procedure: sp_save_cargadatos
-- Tipo: CRUD
-- Descripción: Guarda o actualiza los datos del predio y su avaluo.
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-26 15:06:43

CREATE OR REPLACE FUNCTION sp_save_cargadatos(p_cvecatnva TEXT, p_data JSONB, p_user TEXT)
RETURNS JSONB AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    SELECT cvecuenta INTO v_cvecuenta FROM convcta WHERE cvecatnva = p_cvecatnva LIMIT 1;
    IF v_cvecuenta IS NULL THEN
        RAISE EXCEPTION 'Clave catastral no encontrada';
    END IF;
    -- Actualizar ubicacion
    UPDATE ubicacion SET
        calle = COALESCE(p_data->>'calle', calle),
        noexterior = COALESCE(p_data->>'noexterior', noexterior),
        interior = COALESCE(p_data->>'interior', interior),
        colonia = COALESCE(p_data->>'colonia', colonia),
        codpos = COALESCE(p_data->>'codpos', codpos)
    WHERE cvecuenta = v_cvecuenta;
    -- Actualizar avaluos (solo el vigente)
    UPDATE avaluos SET
        supterr = COALESCE((p_data->>'supterr')::NUMERIC, supterr),
        supconst = COALESCE((p_data->>'supconst')::NUMERIC, supconst),
        valorterr = COALESCE((p_data->>'valorterr')::NUMERIC, valorterr),
        valorconst = COALESCE((p_data->>'valorconst')::NUMERIC, valorconst),
        valfiscal = COALESCE((p_data->>'valfiscal')::NUMERIC, valfiscal),
        observacion = COALESCE(p_data->>'observacion', observacion),
        capturista = p_user,
        feccap = NOW()
    WHERE cvecuenta = v_cvecuenta AND vigencia = 'V';
    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql;