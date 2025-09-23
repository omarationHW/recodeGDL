CREATE OR REPLACE FUNCTION sp_listar_tipos_convenio_diversos() RETURNS TABLE (
    tipo INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_subtipos_convenio_diversos(p_tipo INTEGER) RETURNS TABLE (
    subtipo INTEGER,
    desc_subtipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = p_tipo ORDER BY subtipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tipos()
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;