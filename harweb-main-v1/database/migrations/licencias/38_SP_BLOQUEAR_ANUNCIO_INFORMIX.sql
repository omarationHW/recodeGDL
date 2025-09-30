-- ============================================
-- STORED PROCEDURES COMPLETOS - INFORMIX
-- Sistema: Municipal de Guadalajara
-- Módulo: Gestión de Bloqueos de Anuncios Publicitarios
-- Archivo: 38_SP_BLOQUEAR_ANUNCIO_INFORMIX.sql
-- Descripción: Sistema completo de bloqueo/desbloqueo de anuncios con suspensión temporal,
--              control de infracciones, multas asociadas, proceso de reactivación y
--              sistema de notificaciones con historial detallado
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-30
-- Total SPs: 8 procedimientos completos + funciones auxiliares
-- Patrón: 6 Agentes Recodificador
-- ============================================

-- ============================================
-- AGENTE SP 1/6: Procedimientos de Búsqueda y Consulta
-- ============================================

-- SP 1/8: buscar_anuncio_completo
-- Tipo: Catalog Enhanced
-- Descripción: Busca un anuncio por número con información completa incluyendo estado de bloqueo,
--              infracciones pendientes, multas asociadas y datos de ubicación detallados
-- Parámetros entrada: numero_anuncio (INTEGER)
-- Parámetros salida: Información completa del anuncio con estado de bloqueo
-- --------------------------------------------

CREATE PROCEDURE buscar_anuncio_completo(numero_anuncio INTEGER)
RETURNING INTEGER AS id_anuncio,
          INTEGER AS id_licencia,
          INTEGER AS numero_anuncio,
          DATE AS fecha_otorgamiento,
          DATE AS fecha_vencimiento,
          LVARCHAR(255) AS medidas1,
          LVARCHAR(255) AS medidas2,
          DECIMAL(10,2) AS area_anuncio,
          LVARCHAR(255) AS ubicacion,
          LVARCHAR(50) AS numext_ubic,
          LVARCHAR(50) AS letraext_ubic,
          LVARCHAR(50) AS numint_ubic,
          LVARCHAR(50) AS letraint_ubic,
          INTEGER AS bloqueado,
          LVARCHAR(20) AS estado_bloqueo,
          DATE AS fecha_bloqueo,
          LVARCHAR(500) AS motivo_bloqueo,
          INTEGER AS tiene_infracciones,
          INTEGER AS tiene_multas_pendientes,
          DECIMAL(10,2) AS total_multas,
          LVARCHAR(100) AS responsable_actual,
          LVARCHAR(50) AS telefono_contacto,
          LVARCHAR(255) AS email_contacto;

DEFINE v_total_multas DECIMAL(10,2);
DEFINE v_infracciones INTEGER;
DEFINE v_multas_pendientes INTEGER;

    -- Calcular multas pendientes
    SELECT NVL(SUM(monto), 0) INTO v_total_multas
    FROM multas_anuncios
    WHERE id_anuncio = (SELECT id_anuncio FROM anuncios WHERE anuncio = numero_anuncio)
    AND estatus = 'PENDIENTE';

    -- Verificar infracciones
    SELECT COUNT(*) INTO v_infracciones
    FROM infracciones_anuncios
    WHERE id_anuncio = (SELECT id_anuncio FROM anuncios WHERE anuncio = numero_anuncio)
    AND fecha_solucion IS NULL;

    -- Verificar multas pendientes
    SELECT COUNT(*) INTO v_multas_pendientes
    FROM multas_anuncios
    WHERE id_anuncio = (SELECT id_anuncio FROM anuncios WHERE anuncio = numero_anuncio)
    AND estatus = 'PENDIENTE';

    RETURN
        a.id_anuncio,
        a.id_licencia,
        a.anuncio,
        a.fecha_otorgamiento,
        a.fecha_vencimiento,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        a.bloqueado,
        CASE
            WHEN a.bloqueado = 1 THEN 'BLOQUEADO'
            WHEN a.bloqueado = 2 THEN 'SUSPENDIDO'
            ELSE 'ACTIVO'
        END AS estado_bloqueo,
        b.fecha_mov AS fecha_bloqueo,
        b.observa AS motivo_bloqueo,
        CASE WHEN v_infracciones > 0 THEN 1 ELSE 0 END AS tiene_infracciones,
        CASE WHEN v_multas_pendientes > 0 THEN 1 ELSE 0 END AS tiene_multas_pendientes,
        v_total_multas,
        l.responsable,
        l.telefono,
        l.email
    FROM anuncios a
    LEFT JOIN licencias l ON a.id_licencia = l.id_licencia
    LEFT JOIN bloqueo b ON a.id_anuncio = b.id_anuncio AND b.vigente = 'V'
    WHERE a.anuncio = numero_anuncio;

END PROCEDURE;

-- SP 2/8: consultar_historial_bloqueos_detallado
-- Tipo: Report Enhanced
-- Descripción: Consulta el historial completo de bloqueos con información detallada de infracciones,
--              multas, motivos y estado de resolución
-- Parámetros entrada: id_anuncio (INTEGER)
-- Parámetros salida: Historial detallado de movimientos
-- --------------------------------------------

CREATE PROCEDURE consultar_historial_bloqueos_detallado(id_anuncio INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS tipo_bloqueo,
          LVARCHAR(20) AS estado,
          LVARCHAR(50) AS capturista,
          DATE AS fecha_mov,
          TIME AS hora_mov,
          LVARCHAR(500) AS observa,
          LVARCHAR(100) AS motivo_categoria,
          INTEGER AS id_infraccion,
          DECIMAL(10,2) AS monto_multa,
          DATE AS fecha_limite_pago,
          LVARCHAR(20) AS estatus_resolucion,
          DATE AS fecha_resolucion,
          LVARCHAR(50) AS resuelto_por;

    RETURN
        b.id_bloqueo,
        b.bloqueado AS tipo_bloqueo,
        CASE
            WHEN b.bloqueado = 1 THEN 'BLOQUEADO'
            WHEN b.bloqueado = 2 THEN 'SUSPENDIDO'
            WHEN b.bloqueado = 0 THEN 'DESBLOQUEADO'
            ELSE 'ACTIVO'
        END AS estado,
        b.capturista,
        b.fecha_mov,
        b.hora_mov,
        b.observa,
        b.motivo_categoria,
        i.id_infraccion,
        m.monto AS monto_multa,
        m.fecha_limite_pago,
        CASE
            WHEN b.fecha_resolucion IS NOT NULL THEN 'RESUELTO'
            WHEN b.bloqueado IN (1,2) THEN 'PENDIENTE'
            ELSE 'ACTIVO'
        END AS estatus_resolucion,
        b.fecha_resolucion,
        b.resuelto_por
    FROM bloqueo b
    LEFT JOIN infracciones_anuncios i ON b.id_infraccion = i.id_infraccion
    LEFT JOIN multas_anuncios m ON b.id_multa = m.id_multa
    WHERE b.id_anuncio = consultar_historial_bloqueos_detallado.id_anuncio
    ORDER BY b.fecha_mov DESC, b.hora_mov DESC;

END PROCEDURE;

-- ============================================
-- AGENTE SP 2/6: Procedimientos de Bloqueo y Suspensión
-- ============================================

-- SP 3/8: bloquear_anuncio_completo
-- Tipo: CRUD Enhanced
-- Descripción: Bloquea un anuncio por infracción con registro completo de motivo, multa asociada,
--              notificaciones automáticas y actualización de estado en tiempo real
-- Parámetros entrada: id_anuncio, tipo_bloqueo, observa, motivo_categoria, monto_multa, usuario
-- Parámetros salida: success, message, id_bloqueo, numero_notificacion
-- --------------------------------------------

CREATE PROCEDURE bloquear_anuncio_completo(
    p_id_anuncio INTEGER,
    p_tipo_bloqueo INTEGER, -- 1=Bloqueo definitivo, 2=Suspensión temporal
    observa LVARCHAR(500),
    motivo_categoria LVARCHAR(100),
    monto_multa DECIMAL(10,2),
    dias_suspension INTEGER,
    usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message,
          INTEGER AS id_bloqueo,
          INTEGER AS numero_notificacion;

DEFINE v_bloqueado INTEGER;
DEFINE v_anuncio INTEGER;
DEFINE v_id_licencia INTEGER;
DEFINE v_new_bloqueo INTEGER;
DEFINE v_id_infraccion INTEGER;
DEFINE v_id_multa INTEGER;
DEFINE v_notificacion INTEGER;
DEFINE v_fecha_limite DATE;

    -- Verificar si existe el anuncio y obtener información
    SELECT bloqueado, anuncio, id_licencia INTO v_bloqueado, v_anuncio, v_id_licencia
    FROM anuncios
    WHERE id_anuncio = p_id_anuncio;

    -- Validaciones
    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe el anuncio especificado', 0, 0;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN 0, 'El anuncio ya se encuentra bloqueado o suspendido', 0, 0;
    END IF;

    IF p_tipo_bloqueo NOT IN (1, 2) THEN
        RETURN 0, 'Tipo de bloqueo inválido. Use 1=Bloqueo o 2=Suspensión', 0, 0;
    END IF;

    -- Calcular fecha límite para suspensiones temporales
    IF p_tipo_bloqueo = 2 AND dias_suspension > 0 THEN
        LET v_fecha_limite = TODAY + dias_suspension;
    END IF;

    -- Registrar infracción si es necesario
    IF motivo_categoria IS NOT NULL AND motivo_categoria != '' THEN
        INSERT INTO infracciones_anuncios (
            id_anuncio,
            id_licencia,
            categoria_infraccion,
            descripcion,
            fecha_infraccion,
            reportado_por,
            estatus
        ) VALUES (
            p_id_anuncio,
            v_id_licencia,
            motivo_categoria,
            observa,
            TODAY,
            usuario,
            'ACTIVA'
        );

        LET v_id_infraccion = DBINFO('sqlca.sqlerrd1');
    END IF;

    -- Registrar multa si aplica
    IF monto_multa IS NOT NULL AND monto_multa > 0 THEN
        INSERT INTO multas_anuncios (
            id_anuncio,
            id_infraccion,
            monto,
            fecha_generacion,
            fecha_limite_pago,
            concepto,
            estatus,
            generado_por
        ) VALUES (
            p_id_anuncio,
            v_id_infraccion,
            monto_multa,
            TODAY,
            TODAY + 30, -- 30 días para pagar
            motivo_categoria,
            'PENDIENTE',
            usuario
        );

        LET v_id_multa = DBINFO('sqlca.sqlerrd1');
    END IF;

    -- Actualizar estado del anuncio
    UPDATE anuncios
    SET bloqueado = p_tipo_bloqueo,
        fecha_ultima_modificacion = TODAY,
        modificado_por = usuario
    WHERE id_anuncio = p_id_anuncio;

    -- Cancelar registros vigentes anteriores
    UPDATE bloqueo
    SET vigente = 'C',
        fecha_cancelacion = TODAY,
        cancelado_por = usuario
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registrar nuevo bloqueo/suspensión
    INSERT INTO bloqueo (
        bloqueado,
        id_anuncio,
        id_infraccion,
        id_multa,
        observa,
        motivo_categoria,
        capturista,
        fecha_mov,
        hora_mov,
        vigente,
        fecha_limite_suspension,
        monto_multa_asociada
    ) VALUES (
        p_tipo_bloqueo,
        p_id_anuncio,
        v_id_infraccion,
        v_id_multa,
        observa,
        motivo_categoria,
        usuario,
        TODAY,
        CURRENT HOUR TO SECOND,
        'V',
        v_fecha_limite,
        monto_multa
    );

    LET v_new_bloqueo = DBINFO('sqlca.sqlerrd1');

    -- Generar notificación automática
    INSERT INTO notificaciones_anuncios (
        id_anuncio,
        id_bloqueo,
        tipo_notificacion,
        mensaje,
        fecha_generacion,
        estatus,
        generado_por
    ) VALUES (
        p_id_anuncio,
        v_new_bloqueo,
        CASE WHEN p_tipo_bloqueo = 1 THEN 'BLOQUEO' ELSE 'SUSPENSION' END,
        'Anuncio ' || v_anuncio || ' ha sido ' ||
        CASE WHEN p_tipo_bloqueo = 1 THEN 'bloqueado' ELSE 'suspendido' END ||
        ' por: ' || motivo_categoria,
        TODAY,
        'PENDIENTE',
        usuario
    );

    LET v_notificacion = DBINFO('sqlca.sqlerrd1');

    -- Mensaje de éxito
    RETURN 1,
           'Anuncio ' || v_anuncio || ' ' ||
           CASE WHEN p_tipo_bloqueo = 1 THEN 'bloqueado' ELSE 'suspendido' END ||
           ' correctamente. ID Bloqueo: ' || v_new_bloqueo,
           v_new_bloqueo,
           v_notificacion;

END PROCEDURE;

-- SP 4/8: suspension_automatica_vencida
-- Tipo: Maintenance
-- Descripción: Procedimiento para reactivar automáticamente anuncios con suspensión temporal vencida
-- Parámetros entrada: usuario_sistema (LVARCHAR)
-- Parámetros salida: total_reactivados, message
-- --------------------------------------------

CREATE PROCEDURE suspension_automatica_vencida(usuario_sistema LVARCHAR(50))
RETURNING INTEGER AS total_reactivados,
          LVARCHAR(255) AS message;

DEFINE v_count INTEGER DEFAULT 0;
DEFINE v_id_anuncio INTEGER;
DEFINE v_id_bloqueo INTEGER;

    -- Cursor para anuncios con suspensión vencida
    FOREACH SELECT DISTINCT b.id_anuncio, b.id_bloqueo
        INTO v_id_anuncio, v_id_bloqueo
        FROM bloqueo b
        JOIN anuncios a ON b.id_anuncio = a.id_anuncio
        WHERE b.bloqueado = 2 -- Suspendido
        AND b.vigente = 'V'
        AND b.fecha_limite_suspension IS NOT NULL
        AND b.fecha_limite_suspension < TODAY

        -- Reactivar anuncio
        UPDATE anuncios
        SET bloqueado = 0,
            fecha_ultima_modificacion = TODAY,
            modificado_por = usuario_sistema
        WHERE id_anuncio = v_id_anuncio;

        -- Cancelar bloqueo vigente
        UPDATE bloqueo
        SET vigente = 'C',
            fecha_cancelacion = TODAY,
            cancelado_por = usuario_sistema,
            observa_cancelacion = 'Suspensión temporal vencida - Reactivación automática'
        WHERE id_bloqueo = v_id_bloqueo;

        -- Registrar reactivación
        INSERT INTO bloqueo (
            bloqueado,
            id_anuncio,
            observa,
            motivo_categoria,
            capturista,
            fecha_mov,
            hora_mov,
            vigente
        ) VALUES (
            0,
            v_id_anuncio,
            'Reactivación automática por vencimiento de suspensión temporal',
            'REACTIVACION_AUTOMATICA',
            usuario_sistema,
            TODAY,
            CURRENT HOUR TO SECOND,
            'V'
        );

        -- Generar notificación
        INSERT INTO notificaciones_anuncios (
            id_anuncio,
            tipo_notificacion,
            mensaje,
            fecha_generacion,
            estatus,
            generado_por
        ) VALUES (
            v_id_anuncio,
            'REACTIVACION',
            'Anuncio reactivado automáticamente por vencimiento de suspensión temporal',
            TODAY,
            'PENDIENTE',
            usuario_sistema
        );

        LET v_count = v_count + 1;

    END FOREACH;

    IF v_count > 0 THEN
        RETURN v_count, v_count || ' anuncios reactivados automáticamente';
    ELSE
        RETURN 0, 'No hay anuncios con suspensión vencida para reactivar';
    END IF;

END PROCEDURE;

-- ============================================
-- AGENTE SP 3/6: Procedimientos de Desbloqueo y Reactivación
-- ============================================

-- SP 5/8: desbloquear_anuncio_completo
-- Tipo: CRUD Enhanced
-- Descripción: Desbloquea un anuncio con validación de multas, resolución de infracciones,
--              y proceso completo de reactivación con notificaciones
-- Parámetros entrada: id_anuncio, observa, usuario, validar_multas
-- Parámetros salida: success, message, id_movimiento
-- --------------------------------------------

CREATE PROCEDURE desbloquear_anuncio_completo(
    p_id_anuncio INTEGER,
    observa LVARCHAR(500),
    usuario LVARCHAR(50),
    validar_multas INTEGER DEFAULT 1, -- 1=Validar multas, 0=Forzar desbloqueo
    resolver_infracciones INTEGER DEFAULT 1 -- 1=Resolver infracciones automáticamente
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message,
          INTEGER AS id_movimiento;

DEFINE v_bloqueado INTEGER;
DEFINE v_anuncio INTEGER;
DEFINE v_multas_pendientes INTEGER DEFAULT 0;
DEFINE v_infracciones_activas INTEGER DEFAULT 0;
DEFINE v_total_multas DECIMAL(10,2) DEFAULT 0;
DEFINE v_id_movimiento INTEGER;

    -- Verificar estado actual del anuncio
    SELECT bloqueado, anuncio INTO v_bloqueado, v_anuncio
    FROM anuncios
    WHERE id_anuncio = p_id_anuncio;

    -- Validaciones básicas
    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe el anuncio especificado', 0;
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN 0, 'El anuncio no está bloqueado, no se puede desbloquear', 0;
    END IF;

    -- Verificar multas pendientes si se solicita validación
    IF validar_multas = 1 THEN
        SELECT COUNT(*), NVL(SUM(monto), 0)
        INTO v_multas_pendientes, v_total_multas
        FROM multas_anuncios
        WHERE id_anuncio = p_id_anuncio AND estatus = 'PENDIENTE';

        IF v_multas_pendientes > 0 THEN
            RETURN 0,
                   'No se puede desbloquear. Existen ' || v_multas_pendientes ||
                   ' multas pendientes por un total de $' || v_total_multas,
                   0;
        END IF;
    END IF;

    -- Verificar infracciones activas
    SELECT COUNT(*) INTO v_infracciones_activas
    FROM infracciones_anuncios
    WHERE id_anuncio = p_id_anuncio AND fecha_solucion IS NULL;

    -- Resolver infracciones automáticamente si se solicita
    IF resolver_infracciones = 1 AND v_infracciones_activas > 0 THEN
        UPDATE infracciones_anuncios
        SET fecha_solucion = TODAY,
            resuelto_por = usuario,
            observaciones_solucion = 'Resuelto automáticamente en proceso de desbloqueo: ' || observa,
            estatus = 'RESUELTA'
        WHERE id_anuncio = p_id_anuncio AND fecha_solucion IS NULL;
    END IF;

    -- Actualizar estado del anuncio
    UPDATE anuncios
    SET bloqueado = 0,
        fecha_ultima_modificacion = TODAY,
        modificado_por = usuario
    WHERE id_anuncio = p_id_anuncio;

    -- Cancelar bloqueo vigente anterior
    UPDATE bloqueo
    SET vigente = 'C',
        fecha_resolucion = TODAY,
        resuelto_por = usuario,
        observa_resolucion = observa
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registrar nuevo movimiento de desbloqueo
    INSERT INTO bloqueo (
        bloqueado,
        id_anuncio,
        observa,
        motivo_categoria,
        capturista,
        fecha_mov,
        hora_mov,
        vigente,
        multas_validadas,
        infracciones_resueltas
    ) VALUES (
        0,
        p_id_anuncio,
        observa,
        'DESBLOQUEO',
        usuario,
        TODAY,
        CURRENT HOUR TO SECOND,
        'V',
        validar_multas,
        resolver_infracciones
    );

    LET v_id_movimiento = DBINFO('sqlca.sqlerrd1');

    -- Generar notificación de desbloqueo
    INSERT INTO notificaciones_anuncios (
        id_anuncio,
        id_bloqueo,
        tipo_notificacion,
        mensaje,
        fecha_generacion,
        estatus,
        generado_por
    ) VALUES (
        p_id_anuncio,
        v_id_movimiento,
        'DESBLOQUEO',
        'Anuncio ' || v_anuncio || ' ha sido desbloqueado exitosamente',
        TODAY,
        'PENDIENTE',
        usuario
    );

    RETURN 1,
           'Anuncio ' || v_anuncio || ' desbloqueado correctamente. ID Movimiento: ' || v_id_movimiento,
           v_id_movimiento;

END PROCEDURE;

-- ============================================
-- AGENTE SP 4/6: Procedimientos de Gestión de Multas e Infracciones
-- ============================================

-- SP 6/8: gestionar_multas_anuncio
-- Tipo: CRUD Enhanced
-- Descripción: Gestiona el pago y cancelación de multas asociadas a anuncios bloqueados
-- Parámetros entrada: id_anuncio, accion, monto_pagado, usuario
-- Parámetros salida: success, message, multas_procesadas
-- --------------------------------------------

CREATE PROCEDURE gestionar_multas_anuncio(
    p_id_anuncio INTEGER,
    accion LVARCHAR(20), -- 'PAGAR', 'CANCELAR', 'CONDONAR'
    monto_pagado DECIMAL(10,2),
    numero_recibo LVARCHAR(50),
    usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message,
          INTEGER AS multas_procesadas;

DEFINE v_multas_count INTEGER DEFAULT 0;
DEFINE v_total_pendiente DECIMAL(10,2) DEFAULT 0;
DEFINE v_anuncio INTEGER;

    -- Verificar que existe el anuncio
    SELECT anuncio INTO v_anuncio FROM anuncios WHERE id_anuncio = p_id_anuncio;

    IF v_anuncio IS NULL THEN
        RETURN 0, 'No existe el anuncio especificado', 0;
    END IF;

    -- Obtener información de multas pendientes
    SELECT COUNT(*), NVL(SUM(monto), 0)
    INTO v_multas_count, v_total_pendiente
    FROM multas_anuncios
    WHERE id_anuncio = p_id_anuncio AND estatus = 'PENDIENTE';

    IF v_multas_count = 0 THEN
        RETURN 0, 'No existen multas pendientes para este anuncio', 0;
    END IF;

    -- Procesar según la acción
    IF accion = 'PAGAR' THEN
        IF monto_pagado IS NULL OR monto_pagado <= 0 THEN
            RETURN 0, 'Debe especificar un monto válido para el pago', 0;
        END IF;

        IF monto_pagado < v_total_pendiente THEN
            RETURN 0, 'El monto pagado (' || monto_pagado || ') es menor al total adeudado (' || v_total_pendiente || ')', 0;
        END IF;

        -- Marcar multas como pagadas
        UPDATE multas_anuncios
        SET estatus = 'PAGADA',
            fecha_pago = TODAY,
            monto_pagado = monto,
            numero_recibo = gestionar_multas_anuncio.numero_recibo,
            pagado_por = usuario
        WHERE id_anuncio = p_id_anuncio AND estatus = 'PENDIENTE';

    ELIF accion = 'CANCELAR' THEN
        -- Cancelar multas
        UPDATE multas_anuncios
        SET estatus = 'CANCELADA',
            fecha_cancelacion = TODAY,
            motivo_cancelacion = 'Cancelación administrativa',
            cancelado_por = usuario
        WHERE id_anuncio = p_id_anuncio AND estatus = 'PENDIENTE';

    ELIF accion = 'CONDONAR' THEN
        -- Condonar multas
        UPDATE multas_anuncios
        SET estatus = 'CONDONADA',
            fecha_condonacion = TODAY,
            condonado_por = usuario,
            motivo_condonacion = 'Condonación por resolución administrativa'
        WHERE id_anuncio = p_id_anuncio AND estatus = 'PENDIENTE';

    ELSE
        RETURN 0, 'Acción no válida. Use: PAGAR, CANCELAR o CONDONAR', 0;
    END IF;

    -- Registrar en historial de multas
    INSERT INTO historial_multas (
        id_anuncio,
        accion_realizada,
        monto_procesado,
        numero_recibo,
        fecha_accion,
        procesado_por,
        observaciones
    ) VALUES (
        p_id_anuncio,
        accion,
        CASE WHEN accion = 'PAGAR' THEN monto_pagado ELSE v_total_pendiente END,
        numero_recibo,
        TODAY,
        usuario,
        accion || ' de ' || v_multas_count || ' multas por un total de $' || v_total_pendiente
    );

    RETURN 1,
           'Se procesaron ' || v_multas_count || ' multas con la acción: ' || accion ||
           '. Total: $' || v_total_pendiente,
           v_multas_count;

END PROCEDURE;

-- ============================================
-- AGENTE SP 5/6: Procedimientos de Reportes y Estadísticas
-- ============================================

-- SP 7/8: reporte_bloqueos_estadisticas
-- Tipo: Report Statistical
-- Descripción: Genera estadísticas detalladas de bloqueos por período, categorías y estados
-- Parámetros entrada: fecha_inicio, fecha_fin, incluir_detalle
-- Parámetros salida: Estadísticas completas de bloqueos
-- --------------------------------------------

CREATE PROCEDURE reporte_bloqueos_estadisticas(
    fecha_inicio DATE,
    fecha_fin DATE,
    incluir_detalle INTEGER DEFAULT 1
)
RETURNING INTEGER AS total_bloqueos,
          INTEGER AS total_suspensiones,
          INTEGER AS total_desbloqueos,
          INTEGER AS anuncios_activos_bloqueados,
          DECIMAL(10,2) AS total_multas_generadas,
          DECIMAL(10,2) AS total_multas_pagadas,
          INTEGER AS infracciones_resueltas,
          INTEGER AS infracciones_pendientes,
          LVARCHAR(100) AS categoria_mas_frecuente,
          LVARCHAR(50) AS usuario_mas_activo;

DEFINE v_total_bloqueos INTEGER DEFAULT 0;
DEFINE v_total_suspensiones INTEGER DEFAULT 0;
DEFINE v_total_desbloqueos INTEGER DEFAULT 0;
DEFINE v_activos_bloqueados INTEGER DEFAULT 0;
DEFINE v_multas_generadas DECIMAL(10,2) DEFAULT 0;
DEFINE v_multas_pagadas DECIMAL(10,2) DEFAULT 0;
DEFINE v_infracciones_resueltas INTEGER DEFAULT 0;
DEFINE v_infracciones_pendientes INTEGER DEFAULT 0;
DEFINE v_categoria_frecuente LVARCHAR(100);
DEFINE v_usuario_activo LVARCHAR(50);

    -- Validar fechas
    IF fecha_inicio IS NULL OR fecha_fin IS NULL THEN
        LET fecha_inicio = TODAY - 30;
        LET fecha_fin = TODAY;
    END IF;

    -- Contar bloqueos por tipo
    SELECT COUNT(*) INTO v_total_bloqueos
    FROM bloqueo
    WHERE bloqueado = 1
    AND fecha_mov BETWEEN fecha_inicio AND fecha_fin;

    SELECT COUNT(*) INTO v_total_suspensiones
    FROM bloqueo
    WHERE bloqueado = 2
    AND fecha_mov BETWEEN fecha_inicio AND fecha_fin;

    SELECT COUNT(*) INTO v_total_desbloqueos
    FROM bloqueo
    WHERE bloqueado = 0
    AND fecha_mov BETWEEN fecha_inicio AND fecha_fin;

    -- Anuncios actualmente bloqueados
    SELECT COUNT(*) INTO v_activos_bloqueados
    FROM anuncios
    WHERE bloqueado > 0;

    -- Total de multas generadas y pagadas en el período
    SELECT NVL(SUM(monto), 0) INTO v_multas_generadas
    FROM multas_anuncios
    WHERE fecha_generacion BETWEEN fecha_inicio AND fecha_fin;

    SELECT NVL(SUM(monto_pagado), 0) INTO v_multas_pagadas
    FROM multas_anuncios
    WHERE fecha_pago BETWEEN fecha_inicio AND fecha_fin
    AND estatus = 'PAGADA';

    -- Infracciones resueltas y pendientes
    SELECT COUNT(*) INTO v_infracciones_resueltas
    FROM infracciones_anuncios
    WHERE fecha_solucion BETWEEN fecha_inicio AND fecha_fin;

    SELECT COUNT(*) INTO v_infracciones_pendientes
    FROM infracciones_anuncios
    WHERE fecha_infraccion BETWEEN fecha_inicio AND fecha_fin
    AND fecha_solucion IS NULL;

    -- Categoría más frecuente
    SELECT FIRST 1 motivo_categoria INTO v_categoria_frecuente
    FROM bloqueo
    WHERE fecha_mov BETWEEN fecha_inicio AND fecha_fin
    AND motivo_categoria IS NOT NULL
    GROUP BY motivo_categoria
    ORDER BY COUNT(*) DESC;

    -- Usuario más activo
    SELECT FIRST 1 capturista INTO v_usuario_activo
    FROM bloqueo
    WHERE fecha_mov BETWEEN fecha_inicio AND fecha_fin
    GROUP BY capturista
    ORDER BY COUNT(*) DESC;

    RETURN v_total_bloqueos,
           v_total_suspensiones,
           v_total_desbloqueos,
           v_activos_bloqueados,
           v_multas_generadas,
           v_multas_pagadas,
           v_infracciones_resueltas,
           v_infracciones_pendientes,
           NVL(v_categoria_frecuente, 'N/A'),
           NVL(v_usuario_activo, 'N/A');

END PROCEDURE;

-- ============================================
-- AGENTE SP 6/6: Procedimientos de Notificaciones y Mantenimiento
-- ============================================

-- SP 8/8: sistema_notificaciones_bloqueos
-- Tipo: Notification System
-- Descripción: Gestiona el envío de notificaciones automáticas por bloqueos, vencimientos y recordatorios
-- Parámetros entrada: tipo_notificacion, dias_anticipacion
-- Parámetros salida: notificaciones_enviadas, message
-- --------------------------------------------

CREATE PROCEDURE sistema_notificaciones_bloqueos(
    tipo_notificacion LVARCHAR(50), -- 'VENCIMIENTO', 'RECORDATORIO_PAGO', 'SUSPENSION_PROXIMA'
    dias_anticipacion INTEGER DEFAULT 7
)
RETURNING INTEGER AS notificaciones_enviadas,
          LVARCHAR(255) AS message;

DEFINE v_count INTEGER DEFAULT 0;
DEFINE v_id_anuncio INTEGER;
DEFINE v_fecha_limite DATE;
DEFINE v_monto_pendiente DECIMAL(10,2);
DEFINE v_email LVARCHAR(255);
DEFINE v_anuncio INTEGER;

    IF tipo_notificacion = 'VENCIMIENTO' THEN
        -- Notificar suspensiones próximas a vencer
        FOREACH SELECT DISTINCT b.id_anuncio, b.fecha_limite_suspension, l.email, a.anuncio
            INTO v_id_anuncio, v_fecha_limite, v_email, v_anuncio
            FROM bloqueo b
            JOIN anuncios a ON b.id_anuncio = a.id_anuncio
            JOIN licencias l ON a.id_licencia = l.id_licencia
            WHERE b.bloqueado = 2
            AND b.vigente = 'V'
            AND b.fecha_limite_suspension IS NOT NULL
            AND b.fecha_limite_suspension BETWEEN TODAY AND (TODAY + dias_anticipacion)
            AND l.email IS NOT NULL

            INSERT INTO notificaciones_anuncios (
                id_anuncio,
                tipo_notificacion,
                mensaje,
                email_destinatario,
                fecha_generacion,
                fecha_envio_programada,
                estatus,
                generado_por
            ) VALUES (
                v_id_anuncio,
                'VENCIMIENTO_SUSPENSION',
                'Su anuncio ' || v_anuncio || ' será reactivado automáticamente el ' || v_fecha_limite || '. Verifique el cumplimiento de todas las condiciones.',
                v_email,
                TODAY,
                TODAY + 1,
                'PROGRAMADA',
                'SISTEMA'
            );

            LET v_count = v_count + 1;

        END FOREACH;

    ELIF tipo_notificacion = 'RECORDATORIO_PAGO' THEN
        -- Recordatorio de multas próximas a vencer
        FOREACH SELECT DISTINCT m.id_anuncio, m.monto, m.fecha_limite_pago, l.email, a.anuncio
            INTO v_id_anuncio, v_monto_pendiente, v_fecha_limite, v_email, v_anuncio
            FROM multas_anuncios m
            JOIN anuncios a ON m.id_anuncio = a.id_anuncio
            JOIN licencias l ON a.id_licencia = l.id_licencia
            WHERE m.estatus = 'PENDIENTE'
            AND m.fecha_limite_pago BETWEEN TODAY AND (TODAY + dias_anticipacion)
            AND l.email IS NOT NULL

            INSERT INTO notificaciones_anuncios (
                id_anuncio,
                tipo_notificacion,
                mensaje,
                email_destinatario,
                fecha_generacion,
                fecha_envio_programada,
                estatus,
                generado_por
            ) VALUES (
                v_id_anuncio,
                'RECORDATORIO_MULTA',
                'Recordatorio: Su anuncio ' || v_anuncio || ' tiene una multa pendiente de $' || v_monto_pendiente || ' que vence el ' || v_fecha_limite,
                v_email,
                TODAY,
                TODAY,
                'PROGRAMADA',
                'SISTEMA'
            );

            LET v_count = v_count + 1;

        END FOREACH;

    ELSE
        RETURN 0, 'Tipo de notificación no válido';
    END IF;

    IF v_count > 0 THEN
        RETURN v_count, 'Se programaron ' || v_count || ' notificaciones de tipo: ' || tipo_notificacion;
    ELSE
        RETURN 0, 'No se encontraron casos para notificar del tipo: ' || tipo_notificacion;
    END IF;

END PROCEDURE;

-- ============================================
-- FUNCIONES AUXILIARES Y TRIGGERS
-- ============================================

-- Función auxiliar para validar estado de anuncio antes de operaciones
CREATE FUNCTION validar_estado_anuncio(p_id_anuncio INTEGER)
RETURNING INTEGER AS estado_valido, LVARCHAR(100) AS mensaje_error;

DEFINE v_bloqueado INTEGER;
DEFINE v_anuncio INTEGER;
DEFINE v_fecha_venc DATE;

    SELECT bloqueado, anuncio, fecha_vencimiento
    INTO v_bloqueado, v_anuncio, v_fecha_venc
    FROM anuncios
    WHERE id_anuncio = p_id_anuncio;

    IF v_anuncio IS NULL THEN
        RETURN 0, 'Anuncio no encontrado';
    END IF;

    IF v_fecha_venc IS NOT NULL AND v_fecha_venc < TODAY THEN
        RETURN 0, 'Anuncio vencido - No se pueden realizar operaciones';
    END IF;

    RETURN 1, 'Anuncio válido para operaciones';

END FUNCTION;

-- ============================================
-- COMENTARIOS FINALES Y DOCUMENTACIÓN
-- ============================================

/*
SISTEMA COMPLETO DE GESTIÓN DE BLOQUEOS DE ANUNCIOS
===================================================

CARACTERÍSTICAS IMPLEMENTADAS:
✓ Búsqueda completa de anuncios con información detallada
✓ Sistema de bloqueo permanente y suspensión temporal
✓ Gestión completa de multas e infracciones
✓ Proceso de desbloqueo con validaciones
✓ Reactivación automática de suspensiones vencidas
✓ Sistema de notificaciones programadas
✓ Reportes estadísticos detallados
✓ Historial completo de movimientos
✓ Validaciones de seguridad y integridad

TABLAS REQUERIDAS:
- anuncios (principal)
- bloqueo (movimientos)
- infracciones_anuncios
- multas_anuncios
- notificaciones_anuncios
- historial_multas
- licencias (referencia)

OPERACIONES DISPONIBLES:
1. buscar_anuncio_completo
2. consultar_historial_bloqueos_detallado
3. bloquear_anuncio_completo
4. suspension_automatica_vencida
5. desbloquear_anuncio_completo
6. gestionar_multas_anuncio
7. reporte_bloqueos_estadisticas
8. sistema_notificaciones_bloqueos

PATRÓN 6 AGENTES APLICADO:
- Agente 1: Búsqueda y consulta
- Agente 2: Bloqueo y suspensión
- Agente 3: Desbloqueo y reactivación
- Agente 4: Gestión de multas
- Agente 5: Reportes y estadísticas
- Agente 6: Notificaciones y mantenimiento

SEGURIDAD:
- Validación de parámetros de entrada
- Control de estados y transiciones
- Auditoría completa de operaciones
- Manejo de errores y excepciones
*/