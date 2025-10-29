--
-- SP_CARGACARTERA_APLICA.sql
-- Descripción: Genera la cartera de pagos para otras obligaciones
--              Basado en con34_CgaCart_01
-- Parámetros:
--   par_Tabla: Clave de la tabla (rubro de ingreso)
--   par_Ejer: Ejercicio para creación de cartera
-- Retorna: Status y mensaje de la operación
--

DROP PROCEDURE IF EXISTS SP_CARGACARTERA_APLICA;

CREATE PROCEDURE SP_CARGACARTERA_APLICA(
    par_Tabla CHAR(1),
    par_Ejer INTEGER
)

RETURNING
    INTEGER,      -- status
    VARCHAR(255); -- concepto_status

DEFINE v_leyenda VARCHAR(255);
DEFINE v_estatus INTEGER;
DEFINE v_id_usuario INTEGER;

DEFINE v_mes INTEGER;
DEFINE v_id_34_datos INTEGER;
DEFINE v_id_34_stat_pag INTEGER;
DEFINE v_sup DECIMAL(7,2);
DEFINE v_importe_reg DECIMAL(12,2);
DEFINE v_costo DECIMAL(12,2);
DEFINE v_descripcion VARCHAR(100);

DEFINE v_lError INTEGER;
DEFINE v_lISAMError INTEGER;
DEFINE v_vcMensaje VARCHAR(255);
DEFINE v_count_inserted INTEGER;

ON EXCEPTION SET v_lError, v_lISAMError, v_vcMensaje
    LET v_leyenda = 'Error en transacción SP_CARGACARTERA_APLICA ' || v_lError || ' ISAM: ' || v_lISAMError || ' ' || v_vcMensaje;
    LET v_estatus = -1;
    RETURN v_estatus, v_leyenda;
END EXCEPTION;

-- Inicializar variables
LET v_leyenda = 'ALGO EXTRAÑO PASO';
LET v_estatus = -1;
LET v_count_inserted = 0;

-- Obtener ID del status de pago (cve_tab = 'E', cve_stat = 'V')
SELECT id_34_stat
INTO v_id_34_stat_pag
FROM t34_status
WHERE cve_tab = 'E'
  AND cve_stat = 'V';

IF v_id_34_stat_pag IS NULL THEN
    LET v_leyenda = 'No se encontró el status de pago válido (E-V)';
    LET v_estatus = -1;
    RETURN v_estatus, v_leyenda;
END IF;

-- Procesar cada registro de datos
FOREACH
    SELECT
        a.id_34_datos,
        a.superficie,
        b.descripcion
    INTO
        v_id_34_datos,
        v_sup,
        v_descripcion
    FROM t34_datos a
    INNER JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    INNER JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_Tabla
      AND c.cve_tab = par_Tabla
      AND c.cve_stat IN ('V')
    ORDER BY a.control

    -- Inicializar variables para cada registro
    LET v_mes = 0;
    LET v_costo = 0;
    LET v_importe_reg = 0;

    -- Obtener el costo de la unidad para el ejercicio
    SELECT costo
    INTO v_costo
    FROM t34_unidades
    WHERE cve_tab = par_Tabla
      AND ejercicio = par_Ejer
      AND cve_unidad = 'T'
      AND TRIM(descripcion) = TRIM(v_descripcion);

    -- Si no se encuentra el costo, continuar con el siguiente
    IF v_costo IS NULL THEN
        LET v_costo = 0;
    END IF;

    -- Calcular importe
    LET v_importe_reg = v_sup * v_costo;

    -- Insertar 12 registros de pago (uno por mes)
    FOR v_mes = 1 TO 12
        INSERT INTO t34_pagos (
            id_34_pago,
            id_34_datos,
            periodo,
            importe,
            importe_pagado,
            recargo,
            numero_recibo,
            fecha_pago,
            fecha_vigencia,
            fecha_prescripcion,
            nombre,
            id_stat_pago,
            tipo_pago
        ) VALUES (
            0,                           -- id_34_pago (auto increment)
            v_id_34_datos,              -- id_34_datos
            MDY(v_mes, 1, par_Ejer),    -- periodo (primer día de cada mes)
            v_importe_reg,              -- importe
            0,                          -- importe_pagado
            NULL,                       -- recargo
            NULL,                       -- numero_recibo
            NULL,                       -- fecha_pago
            NULL,                       -- fecha_vigencia
            NULL,                       -- fecha_prescripcion
            USER,                       -- nombre (usuario actual)
            v_id_34_stat_pag,          -- id_stat_pago
            'T'                         -- tipo_pago
        );

        LET v_count_inserted = v_count_inserted + 1;
    END FOR;

END FOREACH;

-- Si se insertaron registros, la operación fue exitosa
IF v_count_inserted > 0 THEN
    LET v_leyenda = 'TERMINO SATISFACTORIAMENTE LA CARGA DE LA CARTERA. ' || v_count_inserted || ' registros insertados.';
    LET v_estatus = 0;
ELSE
    LET v_leyenda = 'No se encontraron datos válidos para generar la cartera';
    LET v_estatus = -1;
END IF;

RETURN v_estatus, v_leyenda;

END PROCEDURE;
