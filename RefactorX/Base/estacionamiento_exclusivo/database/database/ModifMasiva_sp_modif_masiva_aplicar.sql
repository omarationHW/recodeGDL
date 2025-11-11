-- =====================================================
-- SP: sp_modif_masiva_aplicar
-- Descripción: Aplicar modificación masiva en apremios según criterios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_modif_masiva_aplicar(
    p_criterio VARCHAR(100),
    p_campo VARCHAR(50),
    p_valor VARCHAR(255)
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR(255),
    rows_affected INTEGER
) AS $$
DECLARE
    v_affected INTEGER;
    v_sql TEXT;
BEGIN
    -- Validar campo permitido
    IF p_campo NOT IN ('vigencia', 'ejecutor', 'clave_practicado', 'zona_apremio', 'observaciones') THEN
        RETURN QUERY SELECT FALSE, 'Campo no permitido para modificación masiva'::VARCHAR(255), 0;
        RETURN;
    END IF;

    -- Construir y ejecutar UPDATE dinámico
    v_sql := 'UPDATE ta_15_apremios SET ' || p_campo || ' = $1, fecha_actualiz = CURRENT_DATE WHERE ' || p_criterio;

    BEGIN
        EXECUTE v_sql USING p_valor;
        GET DIAGNOSTICS v_affected = ROW_COUNT;

        RETURN QUERY SELECT
            TRUE,
            'Modificación masiva aplicada exitosamente'::VARCHAR(255),
            v_affected;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: ' || SQLERRM)::VARCHAR(255),
            0;
    END;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_modif_masiva_aplicar('zona = 1 AND modulo = 5', 'vigencia', '3');
-- SELECT * FROM sp_modif_masiva_aplicar('fecha_emision < ''2025-01-01''', 'ejecutor', '10');
-- SELECT * FROM sp_modif_masiva_aplicar('vigencia = ''1'' AND fecha_pago IS NULL', 'clave_practicado', 'NOTIF');
