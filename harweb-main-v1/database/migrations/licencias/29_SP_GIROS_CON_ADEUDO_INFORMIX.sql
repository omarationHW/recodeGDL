-- =====================================================================================
-- STORED PROCEDURES PARA GESTIÓN DE GIROS CON ADEUDOS
-- Módulo: LICENCIAS - Gestión de Adeudos y Cobranza
-- Fecha: 2024-12-28
-- =====================================================================================

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_LIST: Lista giros con adeudos
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_LIST(
    p_year INT DEFAULT NULL,
    p_giro VARCHAR(100) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT 'PENDIENTE'
)
RETURNING
    VARCHAR(20) AS licencia,
    VARCHAR(200) AS propietarionvo,
    VARCHAR(300) AS domCompleto,
    VARCHAR(150) AS descripcion,
    INT AS axo,
    DECIMAL(12,2) AS monto_adeudo,
    VARCHAR(20) AS estado_adeudo,
    DATE AS fecha_vencimiento,
    INT AS dias_vencido;

DEFINE v_licencia VARCHAR(20);
DEFINE v_propietarionvo VARCHAR(200);
DEFINE v_domCompleto VARCHAR(300);
DEFINE v_descripcion VARCHAR(150);
DEFINE v_axo INT;
DEFINE v_monto_adeudo DECIMAL(12,2);
DEFINE v_estado_adeudo VARCHAR(20);
DEFINE v_fecha_vencimiento DATE;
DEFINE v_dias_vencido INT;

-- Cursor para giros con adeudos
FOREACH
    SELECT
        l.licencia,
        l.propietarionvo,
        TRIM(l.calle) || ' ' || TRIM(l.numero) || ', ' || TRIM(l.colonia) AS domCompleto,
        g.descripcion,
        COALESCE(a.axo, p_year) AS axo,
        COALESCE(a.monto_adeudo, l.cuota_anual * 1.25) AS monto_adeudo,
        COALESCE(a.estado, 'PENDIENTE') AS estado_adeudo,
        COALESCE(a.fecha_vencimiento, MDY(12, 31, p_year)) AS fecha_vencimiento,
        (TODAY - COALESCE(a.fecha_vencimiento, MDY(12, 31, p_year))) AS dias_vencido
    FROM licencias l
    LEFT JOIN giros g ON l.giro = g.clave
    LEFT JOIN adeudos_licencias a ON l.licencia = a.licencia
        AND (p_year IS NULL OR a.axo = p_year)
    WHERE l.estatus = 'VIGENTE'
        AND (p_giro IS NULL OR g.descripcion LIKE '%' || p_giro || '%')
        AND (p_estado IS NULL OR COALESCE(a.estado, 'PENDIENTE') = p_estado)
        AND (p_year IS NULL OR
             (a.axo = p_year AND a.estado != 'PAGADO') OR
             (a.licencia IS NULL AND p_year <= YEAR(TODAY)))
    ORDER BY l.licencia, axo DESC

    INTO v_licencia, v_propietarionvo, v_domCompleto, v_descripcion,
         v_axo, v_monto_adeudo, v_estado_adeudo, v_fecha_vencimiento, v_dias_vencido

    RETURN v_licencia, v_propietarionvo, v_domCompleto, v_descripcion,
           v_axo, v_monto_adeudo, v_estado_adeudo, v_fecha_vencimiento, v_dias_vencido;

END FOREACH;

END PROCEDURE;

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_GET: Obtiene detalle de adeudo específico
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_GET(
    p_licencia VARCHAR(20),
    p_year INT DEFAULT NULL
)
RETURNING
    VARCHAR(20) AS licencia,
    VARCHAR(200) AS propietarionvo,
    VARCHAR(300) AS domCompleto,
    VARCHAR(150) AS giro_descripcion,
    INT AS axo,
    DECIMAL(12,2) AS monto_original,
    DECIMAL(12,2) AS recargos,
    DECIMAL(12,2) AS monto_total,
    VARCHAR(20) AS estado,
    DATE AS fecha_vencimiento,
    DATE AS fecha_pago,
    VARCHAR(50) AS referencia_pago,
    TEXT AS observaciones;

SELECT
    l.licencia,
    l.propietarionvo,
    TRIM(l.calle) || ' ' || TRIM(l.numero) || ', ' || TRIM(l.colonia) AS domCompleto,
    g.descripcion AS giro_descripcion,
    COALESCE(a.axo, p_year) AS axo,
    COALESCE(a.monto_original, l.cuota_anual) AS monto_original,
    COALESCE(a.recargos, 0) AS recargos,
    COALESCE(a.monto_total, l.cuota_anual) AS monto_total,
    COALESCE(a.estado, 'PENDIENTE') AS estado,
    COALESCE(a.fecha_vencimiento, MDY(12, 31, p_year)) AS fecha_vencimiento,
    a.fecha_pago,
    a.referencia_pago,
    a.observaciones
FROM licencias l
LEFT JOIN giros g ON l.giro = g.clave
LEFT JOIN adeudos_licencias a ON l.licencia = a.licencia
    AND (p_year IS NULL OR a.axo = p_year)
WHERE l.licencia = p_licencia
ORDER BY a.axo DESC
LIMIT 1;

END PROCEDURE;

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_CREATE: Crea nuevo registro de adeudo
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_CREATE(
    p_licencia VARCHAR(20),
    p_year INT,
    p_monto_original DECIMAL(12,2),
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNING
    INT AS id,
    VARCHAR(50) AS mensaje;

DEFINE v_id INT;
DEFINE v_exists INT;
DEFINE v_cuota_anual DECIMAL(12,2);

-- Verificar si la licencia existe
SELECT COUNT(*) INTO v_exists
FROM licencias
WHERE licencia = p_licencia AND estatus = 'VIGENTE';

IF v_exists = 0 THEN
    RETURN 0, 'Licencia no encontrada o no vigente';
END IF;

-- Verificar si ya existe adeudo para ese año
SELECT COUNT(*) INTO v_exists
FROM adeudos_licencias
WHERE licencia = p_licencia AND axo = p_year;

IF v_exists > 0 THEN
    RETURN 0, 'Ya existe un adeudo registrado para esta licencia en el año ' || p_year;
END IF;

-- Obtener cuota anual si no se especifica monto
IF p_monto_original IS NULL THEN
    SELECT cuota_anual INTO v_cuota_anual
    FROM licencias
    WHERE licencia = p_licencia;
    LET p_monto_original = v_cuota_anual;
END IF;

-- Insertar nuevo adeudo
INSERT INTO adeudos_licencias (
    licencia,
    axo,
    monto_original,
    monto_total,
    estado,
    fecha_vencimiento,
    fecha_creacion,
    observaciones
) VALUES (
    p_licencia,
    p_year,
    p_monto_original,
    p_monto_original,
    'PENDIENTE',
    COALESCE(p_fecha_vencimiento, MDY(12, 31, p_year)),
    TODAY,
    p_observaciones
);

SELECT MAX(id) INTO v_id FROM adeudos_licencias WHERE licencia = p_licencia;

RETURN v_id, 'Adeudo creado exitosamente';

END PROCEDURE;

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_UPDATE: Actualiza registro de adeudo
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_UPDATE(
    p_id INT,
    p_monto_original DECIMAL(12,2) DEFAULT NULL,
    p_recargos DECIMAL(12,2) DEFAULT NULL,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNING VARCHAR(50) AS mensaje;

DEFINE v_exists INT;
DEFINE v_estado VARCHAR(20);
DEFINE v_monto_total DECIMAL(12,2);

-- Verificar si existe el adeudo
SELECT COUNT(*), estado INTO v_exists, v_estado
FROM adeudos_licencias
WHERE id = p_id;

IF v_exists = 0 THEN
    RETURN 'Adeudo no encontrado';
END IF;

IF v_estado = 'PAGADO' THEN
    RETURN 'No se puede modificar un adeudo ya pagado';
END IF;

-- Calcular monto total
LET v_monto_total = COALESCE(p_monto_original, 0) + COALESCE(p_recargos, 0);

-- Actualizar adeudo
UPDATE adeudos_licencias
SET
    monto_original = COALESCE(p_monto_original, monto_original),
    recargos = COALESCE(p_recargos, recargos),
    monto_total = v_monto_total,
    fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
    observaciones = COALESCE(p_observaciones, observaciones),
    fecha_modificacion = TODAY
WHERE id = p_id;

RETURN 'Adeudo actualizado exitosamente';

END PROCEDURE;

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_PAGAR: Registra pago de adeudo
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_PAGAR(
    p_id INT,
    p_monto_pagado DECIMAL(12,2),
    p_referencia_pago VARCHAR(50),
    p_fecha_pago DATE DEFAULT NULL,
    p_observaciones_pago TEXT DEFAULT NULL
)
RETURNING VARCHAR(50) AS mensaje;

DEFINE v_exists INT;
DEFINE v_estado VARCHAR(20);
DEFINE v_monto_total DECIMAL(12,2);

-- Verificar si existe el adeudo
SELECT COUNT(*), estado, monto_total
INTO v_exists, v_estado, v_monto_total
FROM adeudos_licencias
WHERE id = p_id;

IF v_exists = 0 THEN
    RETURN 'Adeudo no encontrado';
END IF;

IF v_estado = 'PAGADO' THEN
    RETURN 'Este adeudo ya fue pagado anteriormente';
END IF;

IF p_monto_pagado <= 0 THEN
    RETURN 'El monto pagado debe ser mayor a cero';
END IF;

-- Registrar pago
UPDATE adeudos_licencias
SET
    estado = 'PAGADO',
    monto_pagado = p_monto_pagado,
    referencia_pago = p_referencia_pago,
    fecha_pago = COALESCE(p_fecha_pago, TODAY),
    observaciones_pago = p_observaciones_pago,
    fecha_modificacion = TODAY
WHERE id = p_id;

-- Insertar en historial de pagos
INSERT INTO historial_pagos_adeudos (
    adeudo_id,
    monto_pagado,
    referencia_pago,
    fecha_pago,
    observaciones
) VALUES (
    p_id,
    p_monto_pagado,
    p_referencia_pago,
    COALESCE(p_fecha_pago, TODAY),
    p_observaciones_pago
);

RETURN 'Pago registrado exitosamente';

END PROCEDURE;

-- =====================================================================================
-- SP_GIROS_CON_ADEUDO_ESTADISTICAS: Estadísticas de adeudos
-- =====================================================================================
CREATE PROCEDURE SP_GIROS_CON_ADEUDO_ESTADISTICAS(
    p_year INT DEFAULT NULL,
    p_mes INT DEFAULT NULL
)
RETURNING
    VARCHAR(50) AS concepto,
    INT AS cantidad,
    DECIMAL(15,2) AS monto_total;

DEFINE v_concepto VARCHAR(50);
DEFINE v_cantidad INT;
DEFINE v_monto_total DECIMAL(15,2);

-- Adeudos pendientes por año
LET v_concepto = 'Adeudos Pendientes ' || COALESCE(p_year, YEAR(TODAY));
SELECT COUNT(*), COALESCE(SUM(monto_total), 0)
INTO v_cantidad, v_monto_total
FROM adeudos_licencias
WHERE estado = 'PENDIENTE'
    AND (p_year IS NULL OR axo = p_year);
RETURN v_concepto, v_cantidad, v_monto_total;

-- Adeudos pagados por año
LET v_concepto = 'Adeudos Pagados ' || COALESCE(p_year, YEAR(TODAY));
SELECT COUNT(*), COALESCE(SUM(monto_pagado), 0)
INTO v_cantidad, v_monto_total
FROM adeudos_licencias
WHERE estado = 'PAGADO'
    AND (p_year IS NULL OR axo = p_year)
    AND (p_mes IS NULL OR MONTH(fecha_pago) = p_mes);
RETURN v_concepto, v_cantidad, v_monto_total;

-- Adeudos vencidos
LET v_concepto = 'Adeudos Vencidos';
SELECT COUNT(*), COALESCE(SUM(monto_total), 0)
INTO v_cantidad, v_monto_total
FROM adeudos_licencias
WHERE estado = 'PENDIENTE'
    AND fecha_vencimiento < TODAY
    AND (p_year IS NULL OR axo = p_year);
RETURN v_concepto, v_cantidad, v_monto_total;

-- Recaudación del mes actual
IF p_mes IS NOT NULL THEN
    LET v_concepto = 'Recaudación Mes ' || p_mes;
    SELECT COUNT(*), COALESCE(SUM(monto_pagado), 0)
    INTO v_cantidad, v_monto_total
    FROM adeudos_licencias
    WHERE estado = 'PAGADO'
        AND YEAR(fecha_pago) = COALESCE(p_year, YEAR(TODAY))
        AND MONTH(fecha_pago) = p_mes;
    RETURN v_concepto, v_cantidad, v_monto_total;
END IF;

-- Promedio de adeudo por licencia
LET v_concepto = 'Promedio Adeudo por Licencia';
SELECT COUNT(DISTINCT licencia), AVG(monto_total)
INTO v_cantidad, v_monto_total
FROM adeudos_licencias
WHERE estado = 'PENDIENTE'
    AND (p_year IS NULL OR axo = p_year);
RETURN v_concepto, v_cantidad, v_monto_total;

END PROCEDURE;

-- =====================================================================================
-- TABLAS NECESARIAS (si no existen)
-- =====================================================================================

-- Tabla de adeudos de licencias
CREATE TABLE IF NOT EXISTS adeudos_licencias (
    id SERIAL PRIMARY KEY,
    licencia VARCHAR(20) NOT NULL,
    axo INT NOT NULL,
    monto_original DECIMAL(12,2) NOT NULL DEFAULT 0,
    recargos DECIMAL(12,2) NOT NULL DEFAULT 0,
    monto_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    monto_pagado DECIMAL(12,2) DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE, PAGADO, CANCELADO
    fecha_vencimiento DATE,
    fecha_pago DATE,
    referencia_pago VARCHAR(50),
    observaciones TEXT,
    observaciones_pago TEXT,
    fecha_creacion DATE NOT NULL DEFAULT TODAY,
    fecha_modificacion DATE,
    UNIQUE(licencia, axo)
);

-- Tabla de historial de pagos
CREATE TABLE IF NOT EXISTS historial_pagos_adeudos (
    id SERIAL PRIMARY KEY,
    adeudo_id INT NOT NULL,
    monto_pagado DECIMAL(12,2) NOT NULL,
    referencia_pago VARCHAR(50),
    fecha_pago DATE NOT NULL DEFAULT TODAY,
    observaciones TEXT,
    fecha_registro DATETIME YEAR TO SECOND NOT NULL DEFAULT CURRENT YEAR TO SECOND,
    FOREIGN KEY (adeudo_id) REFERENCES adeudos_licencias(id)
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_adeudos_licencia ON adeudos_licencias(licencia);
CREATE INDEX IF NOT EXISTS idx_adeudos_year ON adeudos_licencias(axo);
CREATE INDEX IF NOT EXISTS idx_adeudos_estado ON adeudos_licencias(estado);
CREATE INDEX IF NOT EXISTS idx_adeudos_vencimiento ON adeudos_licencias(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_historial_adeudo ON historial_pagos_adeudos(adeudo_id);
CREATE INDEX IF NOT EXISTS idx_historial_fecha ON historial_pagos_adeudos(fecha_pago);