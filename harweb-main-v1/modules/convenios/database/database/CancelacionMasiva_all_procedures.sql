-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CancelacionMasiva
-- Generado: 2025-08-27 14:01:48
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_cancelacionmasiva_listar
-- Tipo: Report
-- Descripción: Lista los convenios cancelados hoy (vigencia = 'B')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelacionmasiva_listar()
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    letras_exp varchar(4),
    numero_exp integer,
    axo_exp smallint,
    id_conv_resto integer,
    fecha_inicio date,
    fecha_venc date,
    modulo smallint,
    referencia varchar(30),
    usuario varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.tipo, d.subtipo, d.letras_exp, d.numero_exp, d.axo_exp,
           a.id_conv_resto, a.fecha_inicio, a.fecha_venc,
           b.modulo, b.referencia, p.usuario
    FROM ta_17_conv_diverso d
    JOIN ta_17_conv_d_resto a ON a.tipo = d.tipo AND a.id_conv_diver = d.id_conv_diver
    JOIN ta_17_referencia b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_12_passwords p ON p.id_usuario = a.id_usuario
    WHERE a.vigencia = 'B' AND a.fecha_actual::date = CURRENT_DATE
    ORDER BY 1,2,3,4,5;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_cancelacionmasiva_ejecutar
-- Tipo: CRUD
-- Descripción: Ejecuta la cancelación masiva de convenios con n parcialidades vencidas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelacionmasiva_ejecutar(
    ptipo integer DEFAULT 0,
    pvencidas integer DEFAULT 2,
    pfecven date DEFAULT CURRENT_DATE,
    piduser integer DEFAULT 0,
    pusuario varchar DEFAULT NULL
)
RETURNS TABLE (
    totbajas integer,
    estado integer,
    mensaje varchar
) AS $$
DECLARE
    v_totbajas integer := 0;
BEGIN
    -- Cancelar convenios que cumplen el criterio
    -- (Ejemplo: convenios con al menos pvencidas parcialidades vencidas y no sean licencias de construcción)
    -- Aquí se asume que existe una lógica para identificar los convenios a cancelar
    -- y que la cancelación consiste en actualizar vigencia = 'B' y fecha_actual = now()
    WITH to_cancel AS (
        SELECT a.id_conv_resto
        FROM ta_17_conv_d_resto a
        WHERE a.vigencia = 'A'
          AND a.tipo <> 4 -- Excluir licencias de construcción
          AND (
            SELECT COUNT(*)
            FROM ta_17_adeudos_div ad
            WHERE ad.id_conv_resto = a.id_conv_resto
              AND ad.clave_pago IS DISTINCT FROM 'P'
              AND ad.fecha_venc < pfecven
          ) >= pvencidas
    )
    UPDATE ta_17_conv_d_resto
    SET vigencia = 'B', fecha_actual = now(), id_usuario = piduser
    WHERE id_conv_resto IN (SELECT id_conv_resto FROM to_cancel)
    RETURNING id_conv_resto INTO v_totbajas;

    GET DIAGNOSTICS v_totbajas = ROW_COUNT;
    RETURN QUERY SELECT v_totbajas, 0, 'SE CANCELARON ' || v_totbajas || ' CONVENIOS';
END;
$$ LANGUAGE plpgsql;

-- ============================================

