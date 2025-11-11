-- =============================================
-- Stored Procedure: spget_lic_detalles
-- Descripción: Obtiene el desglose de conceptos de una licencia
-- Basado en: sp_lictotales del archivo sfrm_consultapublicos.dfm (Delphi)
-- Uso: ReportesPublicos.vue (línea 87)
-- Parámetros:
--   id_licencia: ID interno de la licencia
--   tipo_l: Tipo de licencia ('L' = Licencia, etc.)
--   redon: Indica si redondear valores ('S'/'N')
-- =============================================

CREATE OR REPLACE FUNCTION public.spget_lic_detalles(
    p_id_licencia INTEGER,
    p_tipo_l VARCHAR(1) DEFAULT 'L',
    p_redon VARCHAR(1) DEFAULT 'N'
)
RETURNS TABLE(
    cuenta INTEGER,
    obliga VARCHAR(1),
    concepto VARCHAR(150),
    importe NUMERIC(12,2),
    licanun INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_licencia INTEGER;
    v_cupo INTEGER;
    v_categoria_id INTEGER;
BEGIN
    -- Obtener información básica de la licencia
    SELECT numlicencia, cupo, pubcategoria_id
    INTO v_licencia, v_cupo, v_categoria_id
    FROM pubmain
    WHERE id = p_id_licencia
    LIMIT 1;

    -- Si no existe la licencia, retornar vacío
    IF v_licencia IS NULL THEN
        RETURN;
    END IF;

    -- Retornar conceptos base (esto es un ejemplo, se debe ajustar según la lógica real)
    -- En el sistema original, esto probablemente consulta una tabla de conceptos/tarifas

    -- Concepto 1: Cuota anual
    RETURN QUERY SELECT
        1::INTEGER AS cuenta,
        'S'::VARCHAR(1) AS obliga,  -- S = obligatorio
        'CUOTA ANUAL ESTACIONAMIENTO PUBLICO'::VARCHAR(150) AS concepto,
        CASE
            WHEN p_redon = 'S' THEN ROUND(v_cupo * 100.00)
            ELSE v_cupo * 100.00
        END AS importe,
        v_licencia AS licanun;

    -- Concepto 2: Derechos de licencia
    RETURN QUERY SELECT
        2::INTEGER AS cuenta,
        'S'::VARCHAR(1) AS obliga,
        'DERECHOS DE LICENCIA'::VARCHAR(150) AS concepto,
        CASE
            WHEN p_redon = 'S' THEN ROUND(500.00)
            ELSE 500.00
        END AS importe,
        v_licencia AS licanun;

    -- Concepto 3: Actualización (opcional)
    RETURN QUERY SELECT
        3::INTEGER AS cuenta,
        'N'::VARCHAR(1) AS obliga,  -- N = opcional
        'ACTUALIZACION'::VARCHAR(150) AS concepto,
        CASE
            WHEN p_redon = 'S' THEN ROUND(250.00)
            ELSE 250.00
        END AS importe,
        v_licencia AS licanun;

    -- Concepto 4: Recargos (opcional)
    RETURN QUERY SELECT
        4::INTEGER AS cuenta,
        'N'::VARCHAR(1) AS obliga,
        'RECARGOS'::VARCHAR(150) AS concepto,
        0.00::NUMERIC(12,2) AS importe,
        v_licencia AS licanun;

    -- Concepto 5: Multas (opcional)
    RETURN QUERY SELECT
        5::INTEGER AS cuenta,
        'N'::VARCHAR(1) AS obliga,
        'MULTAS'::VARCHAR(150) AS concepto,
        0.00::NUMERIC(12,2) AS importe,
        v_licencia AS licanun;

END;
$$;

-- Comentarios y metadatos
COMMENT ON FUNCTION public.spget_lic_detalles(INTEGER, VARCHAR, VARCHAR) IS
'SP que obtiene el desglose de conceptos y montos de una licencia de estacionamiento.
Basado en sp_lictotales del sistema Delphi original.
Usado por: ReportesPublicos.vue
Nota: Los montos deben ser ajustados según las tarifas reales del municipio';
