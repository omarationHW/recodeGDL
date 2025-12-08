-- ============================================
-- DEPLOY CONSOLIDADO: regHfrm
-- Componente 83/95 - BATCH 17
-- Generado: 2025-11-20
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_reg_h_list
CREATE OR REPLACE FUNCTION public.sp_reg_h_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.axocomp, h.nocomp
    FROM h_catastro h
    WHERE h.cvecuenta = p_cvecuenta
    ORDER BY h.axocomp DESC, h.nocomp DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_reg_h_show
CREATE OR REPLACE FUNCTION public.sp_reg_h_show(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    axocomp INTEGER,
    nocomp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.cvecuenta, h.axocomp, h.nocomp
    FROM h_catastro h
    WHERE h.cvecuenta = p_cvecuenta AND h.axocomp = p_axocomp AND h.nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_reg_h_create
CREATE OR REPLACE FUNCTION public.sp_reg_h_create(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS JSON AS $$
BEGIN
    INSERT INTO h_catastro (cvecuenta, axocomp, nocomp)
    VALUES (p_cvecuenta, p_axocomp, p_nocomp);

    RETURN json_build_object('success', true, 'message', 'Registro histórico creado correctamente');
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_reg_h_update
CREATE OR REPLACE FUNCTION public.sp_reg_h_update(
    p_cvecuenta INTEGER,
    p_axocomp INTEGER,
    p_nocomp INTEGER,
    p_new_axocomp INTEGER,
    p_new_nocomp INTEGER
) RETURNS JSON AS $$
BEGIN
    UPDATE h_catastro
    SET axocomp = p_new_axocomp, nocomp = p_new_nocomp
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;

    RETURN json_build_object('success', true, 'message', 'Registro histórico actualizado correctamente');
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_reg_h_delete
CREATE OR REPLACE FUNCTION public.sp_reg_h_delete(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS JSON AS $$
BEGIN
    DELETE FROM h_catastro WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;

    RETURN json_build_object('success', true, 'message', 'Registro histórico eliminado correctamente');
END;
$$ LANGUAGE plpgsql;
