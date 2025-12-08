-- =====================================================
-- STORED PROCEDURES FALTANTES - MÓDULO CONTRATOS
-- ASEO CONTRATADO
-- =====================================================
-- Fecha: 2025-12-02
-- Basado en: AUDITORIA_CONTRATOS_ASEO_CONTRATADO.md
-- =====================================================

USE RefactorX_Guadalajara;

-- =====================================================
-- 1. SP_ASEO_CONTRATOS_CREATE
-- Reemplaza: SpdGenContrato + QryPagos de Delphi
-- Función: Crear contrato y generar pagos automáticamente
-- =====================================================

DROP PROCEDURE IF EXISTS SP_ASEO_CONTRATOS_CREATE;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_CONTRATOS_CREATE(
  IN p_num_contrato INT,
  IN p_ctrol_aseo INT,
  IN p_num_empresa INT,
  IN p_ctrol_emp INT,           -- Default 9 para privadas
  IN p_ctrol_recolec INT,
  IN p_cve_recolec CHAR(1),     -- Clave de recolección
  IN p_cantidad_recolec INT,
  IN p_domicilio VARCHAR(100),
  IN p_calle VARCHAR(100),
  IN p_numext VARCHAR(10),
  IN p_numint VARCHAR(10),
  IN p_colonia VARCHAR(100),
  IN p_sector CHAR(2),          -- H, J, R, L
  IN p_cp VARCHAR(5),
  IN p_municipio VARCHAR(100),
  IN p_estado VARCHAR(50),
  IN p_ctrol_zona INT,
  IN p_id_rec INT,
  IN p_aso_mes_oblig DATE,
  IN p_rfc VARCHAR(13),
  IN p_curp VARCHAR(18),
  IN p_cve CHAR(1),             -- 'A' = Alta
  IN p_usuario INT,
  OUT p_control_contrato INT,
  OUT p_status INT,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_ejercicio_actual INT;
  DECLARE v_ejercicio_siguiente INT;
  DECLARE v_mes_inicio INT;
  DECLARE v_mes INT;
  DECLARE v_costo_unidad DECIMAL(10,2);
  DECLARE v_costo_unidad_sig DECIMAL(10,2);
  DECLARE v_importe DECIMAL(10,2);
  DECLARE v_num_contrato_auto INT;
  DECLARE v_existe_contrato INT;
  DECLARE v_domicilio_completo VARCHAR(150);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
    SET p_status = 1;
    SET p_message = CONCAT('Error SQL: ', @errno, ' - ', @text);
  END;

  START TRANSACTION;

  -- Validaciones iniciales
  IF p_ctrol_aseo IS NULL OR p_num_empresa IS NULL OR p_ctrol_recolec IS NULL THEN
    SET p_status = 1;
    SET p_message = 'Faltan campos obligatorios';
    ROLLBACK;
  END IF;

  IF p_sector NOT IN ('H', 'J', 'R', 'L') THEN
    SET p_status = 1;
    SET p_message = 'Sector debe ser H, J, R o L';
    ROLLBACK;
  END IF;

  -- Construir domicilio completo
  SET v_domicilio_completo = p_domicilio;
  IF v_domicilio_completo IS NULL OR TRIM(v_domicilio_completo) = '' THEN
    SET v_domicilio_completo = CONCAT_WS(' ', p_calle, p_numext, p_numint, p_colonia);
  END IF;

  -- Generar número de contrato automático si no se proporciona
  IF p_num_contrato IS NULL OR p_num_contrato = 0 THEN
    SELECT COALESCE(MAX(Num_Contrato), 0) + 1 INTO v_num_contrato_auto
    FROM ta_16_Contratos;
  ELSE
    SET v_num_contrato_auto = p_num_contrato;

    -- Verificar que no exista ya ese número
    SELECT COUNT(*) INTO v_existe_contrato
    FROM ta_16_Contratos
    WHERE Num_Contrato = v_num_contrato_auto;

    IF v_existe_contrato > 0 THEN
      SET p_status = 1;
      SET p_message = CONCAT('Ya existe un contrato con el número ', v_num_contrato_auto);
      ROLLBACK;
    END IF;
  END IF;

  SET v_ejercicio_actual = YEAR(p_aso_mes_oblig);
  SET v_ejercicio_siguiente = v_ejercicio_actual + 1;
  SET v_mes_inicio = MONTH(p_aso_mes_oblig);

  -- Validar año (solo actual o anterior)
  IF v_ejercicio_actual < YEAR(CURDATE()) - 1 OR v_ejercicio_actual > YEAR(CURDATE()) THEN
    SET p_status = 1;
    SET p_message = 'El año de inicio debe ser el actual o el anterior';
    ROLLBACK;
  END IF;

  -- Insertar contrato
  INSERT INTO ta_16_Contratos (
    Num_Contrato, Ctrol_Aseo, Num_Empresa, Ctrol_Emp,
    Ctrol_recolec, Cantidad_recolec, Domicilio, Sector,
    Ctrol_zona, Id_rec, Fecha_hora_alta, Status_vigencia,
    Aso_mes_oblig, Cve, Usuario, rfc, curp
  ) VALUES (
    v_num_contrato_auto, p_ctrol_aseo, p_num_empresa, COALESCE(p_ctrol_emp, 9),
    p_ctrol_recolec, p_cantidad_recolec, v_domicilio_completo, p_sector,
    p_ctrol_zona, p_id_rec, NOW(), 'N',
    p_aso_mes_oblig, COALESCE(p_cve, 'A'), p_usuario, p_rfc, p_curp
  );

  SET p_control_contrato = LAST_INSERT_ID();

  -- Obtener costo de unidad para ejercicio actual
  SELECT costo_unidad INTO v_costo_unidad
  FROM ta_16_unidades
  WHERE ctrol_recolec = p_ctrol_recolec
    AND ejercicio_recolec = v_ejercicio_actual
  LIMIT 1;

  IF v_costo_unidad IS NULL THEN
    SET p_status = 1;
    SET p_message = CONCAT('No existe tarifa para la unidad en el ejercicio ', v_ejercicio_actual);
    ROLLBACK;
  END IF;

  -- Generar pagos para ejercicio actual (desde mes inicio hasta diciembre)
  SET v_mes = v_mes_inicio;
  WHILE v_mes <= 12 DO
    SET v_importe = p_cantidad_recolec * v_costo_unidad;

    INSERT INTO ta_16_pagos (
      Control_contrato,
      Aso_mes_pago,
      Ctrol_operacion,
      Importe,
      Status_vigencia,
      Usuario,
      Fecha_hora_operacion,
      Exed
    ) VALUES (
      p_control_contrato,
      STR_TO_DATE(CONCAT(v_ejercicio_actual, '-', LPAD(v_mes, 2, '0'), '-01'), '%Y-%m-%d'),
      6, -- Cuota normal
      v_importe,
      'D', -- Debe
      p_usuario,
      NOW(),
      p_cantidad_recolec
    );

    SET v_mes = v_mes + 1;
  END WHILE;

  -- Obtener costo para ejercicio siguiente
  SELECT costo_unidad INTO v_costo_unidad_sig
  FROM ta_16_unidades
  WHERE ctrol_recolec = p_ctrol_recolec
    AND ejercicio_recolec = v_ejercicio_siguiente
  LIMIT 1;

  -- Generar pagos para ejercicio siguiente (enero a diciembre) si existe tarifa
  IF v_costo_unidad_sig IS NOT NULL THEN
    SET v_mes = 1;
    WHILE v_mes <= 12 DO
      SET v_importe = p_cantidad_recolec * v_costo_unidad_sig;

      INSERT INTO ta_16_pagos (
        Control_contrato,
        Aso_mes_pago,
        Ctrol_operacion,
        Importe,
        Status_vigencia,
        Usuario,
        Fecha_hora_operacion,
        Exed
      ) VALUES (
        p_control_contrato,
        STR_TO_DATE(CONCAT(v_ejercicio_siguiente, '-', LPAD(v_mes, 2, '0'), '-01'), '%Y-%m-%d'),
        6,
        v_importe,
        'D',
        p_usuario,
        NOW(),
        p_cantidad_recolec
      );

      SET v_mes = v_mes + 1;
    END WHILE;
  END IF;

  COMMIT;

  SET p_status = 0;
  SET p_message = CONCAT('Contrato #', v_num_contrato_auto, ' creado exitosamente con pagos automáticos');
END$$

DELIMITER ;

-- =====================================================
-- 2. SP_ASEO_CONTRATOS_UPDATE
-- Reemplaza: spupd16_contrato_01 de Delphi
-- Función: Modificar contrato con opciones específicas
-- =====================================================

DROP PROCEDURE IF EXISTS SP_ASEO_CONTRATOS_UPDATE;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_CONTRATOS_UPDATE(
  IN p_control_contrato INT,
  IN p_opcion INT,              -- 0-8 según tipo de modificación
  IN p_documento VARCHAR(50),
  IN p_descripcion TEXT,
  IN p_periodo VARCHAR(7),      -- YYYY-MM
  -- Parámetros opcionales según opción
  IN p_ctrol_aseo INT,
  IN p_ctrol_recolec INT,
  IN p_cantidad_recolec INT,
  IN p_aso_mes_oblig DATE,
  IN p_num_empresa INT,
  IN p_domicilio VARCHAR(100),
  IN p_calle VARCHAR(100),
  IN p_numext VARCHAR(10),
  IN p_numint VARCHAR(10),
  IN p_colonia VARCHAR(100),
  IN p_ctrol_zona INT,
  IN p_sector CHAR(2),
  IN p_id_rec INT,
  IN p_rfc VARCHAR(13),
  IN p_curp VARCHAR(18),
  IN p_usuario INT,
  OUT p_status INT,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_existe_contrato INT;
  DECLARE v_domicilio_completo VARCHAR(150);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
    SET p_status = 1;
    SET p_message = CONCAT('Error SQL: ', @errno, ' - ', @text);
  END;

  START TRANSACTION;

  -- Validaciones
  IF p_documento IS NULL OR LENGTH(p_documento) < 10 THEN
    SET p_status = 1;
    SET p_message = 'El documento debe tener al menos 10 caracteres';
    ROLLBACK;
  END IF;

  IF p_descripcion IS NULL OR LENGTH(p_descripcion) < 10 THEN
    SET p_status = 1;
    SET p_message = 'La descripción debe tener al menos 10 caracteres';
    ROLLBACK;
  END IF;

  -- Verificar que el contrato existe
  SELECT COUNT(*) INTO v_existe_contrato
  FROM ta_16_Contratos
  WHERE Control_contrato = p_control_contrato;

  IF v_existe_contrato = 0 THEN
    SET p_status = 1;
    SET p_message = 'El contrato no existe';
    ROLLBACK;
  END IF;

  -- Registrar cambio en historial (crear tabla si no existe)
  -- Nota: Esta tabla debe crearse previamente
  /*
  INSERT INTO ta_16_contratos_historial (
    Control_contrato, Tipo_cambio, Documento, Descripcion,
    Periodo, Usuario, Fecha_hora
  ) VALUES (
    p_control_contrato, p_opcion, p_documento, p_descripcion,
    p_periodo, p_usuario, NOW()
  );
  */

  -- Aplicar cambio según opción
  CASE p_opcion
    WHEN 0 THEN -- Tipo y Unidad de Recolección
      UPDATE ta_16_Contratos
      SET Ctrol_Aseo = COALESCE(p_ctrol_aseo, Ctrol_Aseo),
          Ctrol_recolec = COALESCE(p_ctrol_recolec, Ctrol_recolec)
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Tipo y unidad de recolección actualizados';

    WHEN 1 THEN -- Cantidad de Unidades
      UPDATE ta_16_Contratos
      SET Cantidad_recolec = p_cantidad_recolec
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Cantidad de unidades actualizada';

    WHEN 2 THEN -- Periodo Inicio Obligación
      UPDATE ta_16_Contratos
      SET Aso_mes_oblig = p_aso_mes_oblig
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Periodo de inicio actualizado';

    WHEN 3 THEN -- Datos de Empresa
      UPDATE ta_16_Contratos
      SET Num_Empresa = p_num_empresa,
          rfc = COALESCE(p_rfc, rfc),
          curp = COALESCE(p_curp, curp)
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Datos de empresa actualizados';

    WHEN 4 THEN -- Cambio de Domicilio
      SET v_domicilio_completo = p_domicilio;
      IF v_domicilio_completo IS NULL OR TRIM(v_domicilio_completo) = '' THEN
        SET v_domicilio_completo = CONCAT_WS(' ', p_calle, p_numext, p_numint, p_colonia);
      END IF;

      UPDATE ta_16_Contratos
      SET Domicilio = v_domicilio_completo
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Domicilio actualizado';

    WHEN 5 THEN -- Cambio de Zona
      UPDATE ta_16_Contratos
      SET Ctrol_zona = p_ctrol_zona
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Zona actualizada';

    WHEN 6 THEN -- Cambio de Sector
      IF p_sector NOT IN ('H', 'J', 'R', 'L') THEN
        SET p_status = 1;
        SET p_message = 'Sector debe ser H, J, R o L';
        ROLLBACK;
      END IF;

      UPDATE ta_16_Contratos
      SET Sector = p_sector
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Sector actualizado';

    WHEN 7 THEN -- Cambio de Recaudadora
      UPDATE ta_16_Contratos
      SET Id_rec = p_id_rec
      WHERE Control_contrato = p_control_contrato;
      SET p_message = 'Recaudadora actualizada';

    WHEN 8 THEN -- Licencias/Giros
      -- Esta opción se maneja por separado
      SET p_message = 'Opción de licencias/giros';

    ELSE
      SET p_status = 1;
      SET p_message = 'Opción de modificación no válida';
      ROLLBACK;
  END CASE;

  COMMIT;

  SET p_status = 0;
  SET p_message = CONCAT('Contrato actualizado: ', p_message);
END$$

DELIMITER ;

-- =====================================================
-- 3. SP_ASEO_CONTRATOS_BAJA
-- Función: Dar de baja un contrato
-- =====================================================

DROP PROCEDURE IF EXISTS SP_ASEO_CONTRATOS_BAJA;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_CONTRATOS_BAJA(
  IN p_control_contrato INT,
  IN p_documento VARCHAR(50),
  IN p_motivo VARCHAR(50),
  IN p_observaciones TEXT,
  IN p_fecha_baja DATE,
  IN p_usuario_id INT,
  OUT p_status INT,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_existe_contrato INT;
  DECLARE v_inicio_oblig DATE;
  DECLARE v_num_contrato INT;
  DECLARE v_adeudos_pendientes INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
    SET p_status = 1;
    SET p_message = CONCAT('Error SQL: ', @errno, ' - ', @text);
  END;

  START TRANSACTION;

  -- Validaciones
  IF p_documento IS NULL OR LENGTH(p_documento) < 10 THEN
    SET p_status = 1;
    SET p_message = 'El documento debe tener al menos 10 caracteres';
    ROLLBACK;
  END IF;

  IF p_observaciones IS NULL OR LENGTH(p_observaciones) < 10 THEN
    SET p_status = 1;
    SET p_message = 'Las observaciones deben tener al menos 10 caracteres';
    ROLLBACK;
  END IF;

  IF p_fecha_baja > CURDATE() THEN
    SET p_status = 1;
    SET p_message = 'La fecha de baja no puede ser futura';
    ROLLBACK;
  END IF;

  -- Verificar que el contrato existe y obtener datos
  SELECT COUNT(*), MAX(Num_Contrato), MAX(Aso_mes_oblig)
  INTO v_existe_contrato, v_num_contrato, v_inicio_oblig
  FROM ta_16_Contratos
  WHERE Control_contrato = p_control_contrato;

  IF v_existe_contrato = 0 THEN
    SET p_status = 1;
    SET p_message = 'El contrato no existe';
    ROLLBACK;
  END IF;

  -- Validar que fecha de baja >= inicio obligación
  IF p_fecha_baja < v_inicio_oblig THEN
    SET p_status = 1;
    SET p_message = 'La fecha de baja no puede ser anterior al inicio de obligación';
    ROLLBACK;
  END IF;

  -- Verificar adeudos pendientes
  SELECT COUNT(*) INTO v_adeudos_pendientes
  FROM ta_16_pagos
  WHERE Control_contrato = p_control_contrato
    AND Status_vigencia = 'D'; -- Debe

  IF v_adeudos_pendientes > 0 THEN
    -- Advertencia pero se permite continuar
    SET p_message = CONCAT('ADVERTENCIA: Existen ', v_adeudos_pendientes, ' adeudos pendientes. ');
  ELSE
    SET p_message = '';
  END IF;

  -- Dar de baja el contrato
  UPDATE ta_16_Contratos
  SET Status_vigencia = 'B',
      Fecha_hora_baja = NOW(),
      Usuario = p_usuario_id
  WHERE Control_contrato = p_control_contrato;

  -- Registrar en historial
  /*
  INSERT INTO ta_16_contratos_historial (
    Control_contrato, Tipo_cambio, Documento, Descripcion,
    Periodo, Usuario, Fecha_hora
  ) VALUES (
    p_control_contrato, 99, p_documento,
    CONCAT('BAJA - Motivo: ', p_motivo, ' - ', p_observaciones),
    DATE_FORMAT(p_fecha_baja, '%Y-%m'), p_usuario_id, NOW()
  );
  */

  COMMIT;

  SET p_status = 0;
  SET p_message = CONCAT(p_message, 'Contrato #', v_num_contrato, ' dado de baja exitosamente');
END$$

DELIMITER ;

-- =====================================================
-- 4. SP_ASEO_INSERTAR_CONTRATO_RAPIDO
-- Función: Alta rápida desde catastro (Ins_b.vue)
-- =====================================================

DROP PROCEDURE IF EXISTS SP_ASEO_INSERTAR_CONTRATO_RAPIDO;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_INSERTAR_CONTRATO_RAPIDO(
  IN p_cuenta_catastral VARCHAR(12),
  IN p_ctrol_aseo INT,
  IN p_num_empresa INT,
  IN p_num_unidad INT,
  IN p_cuota_mensual DECIMAL(10,2),
  IN p_contribuyente VARCHAR(200),
  IN p_rfc VARCHAR(13),
  IN p_telefono VARCHAR(20),
  IN p_fecha_alta DATE,
  IN p_periodo_inicial VARCHAR(6),  -- YYYYMM
  IN p_observaciones TEXT,
  IN p_zona VARCHAR(10),
  IN p_colonia VARCHAR(100),
  IN p_domicilio VARCHAR(150),
  IN p_usuario_id INT,
  OUT p_num_contrato INT,
  OUT p_status INT,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_control_contrato INT;
  DECLARE v_ctrol_zona INT;
  DECLARE v_id_rec INT;
  DECLARE v_aso_mes_oblig DATE;
  DECLARE v_anio INT;
  DECLARE v_mes INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
    SET p_status = 1;
    SET p_message = CONCAT('Error SQL: ', @errno, ' - ', @text);
  END;

  START TRANSACTION;

  -- Validar cuenta catastral
  IF p_cuenta_catastral IS NULL OR LENGTH(p_cuenta_catastral) <> 12 THEN
    SET p_status = 1;
    SET p_message = 'Cuenta catastral inválida (debe ser 12 dígitos)';
    ROLLBACK;
  END IF;

  -- Extraer año y mes del período inicial
  IF p_periodo_inicial IS NOT NULL AND LENGTH(p_periodo_inicial) = 6 THEN
    SET v_anio = CAST(SUBSTRING(p_periodo_inicial, 1, 4) AS UNSIGNED);
    SET v_mes = CAST(SUBSTRING(p_periodo_inicial, 5, 2) AS UNSIGNED);
    SET v_aso_mes_oblig = STR_TO_DATE(CONCAT(v_anio, '-', LPAD(v_mes, 2, '0'), '-01'), '%Y-%m-%d');

    -- Validar año (solo actual o anterior)
    IF v_anio < YEAR(CURDATE()) - 1 OR v_anio > YEAR(CURDATE()) THEN
      SET p_status = 1;
      SET p_message = 'El año de inicio debe ser el actual o el anterior';
      ROLLBACK;
    END IF;
  ELSE
    SET v_aso_mes_oblig = p_fecha_alta;
  END IF;

  -- Obtener ctrol_zona de la zona (simplificado - debe buscar en tabla de zonas)
  SELECT ctrol_zona INTO v_ctrol_zona
  FROM ta_16_zonas
  WHERE zona = p_zona
  LIMIT 1;

  IF v_ctrol_zona IS NULL THEN
    SET v_ctrol_zona = 1; -- Default
  END IF;

  -- Obtener recaudadora (simplificado - debe buscar por zona)
  SELECT id_rec INTO v_id_rec
  FROM ta_16_recaudadoras
  WHERE id_zona = v_ctrol_zona
  LIMIT 1;

  IF v_id_rec IS NULL THEN
    SET v_id_rec = 1; -- Default
  END IF;

  -- Llamar al SP de creación completo
  CALL SP_ASEO_CONTRATOS_CREATE(
    NULL,                       -- p_num_contrato (autogenerar)
    p_ctrol_aseo,
    p_num_empresa,
    9,                          -- p_ctrol_emp (privadas)
    p_num_unidad,
    'T',                        -- p_cve_recolec (default)
    1,                          -- p_cantidad_recolec (default)
    p_domicilio,
    NULL,                       -- p_calle
    NULL,                       -- p_numext
    NULL,                       -- p_numint
    p_colonia,
    'H',                        -- p_sector (default)
    NULL,                       -- p_cp
    'Guadalajara',              -- p_municipio
    'Jalisco',                  -- p_estado
    v_ctrol_zona,
    v_id_rec,
    v_aso_mes_oblig,
    p_rfc,
    NULL,                       -- p_curp
    'A',                        -- p_cve (Alta)
    p_usuario_id,
    v_control_contrato,
    p_status,
    p_message
  );

  IF p_status = 0 THEN
    SELECT Num_Contrato INTO p_num_contrato
    FROM ta_16_Contratos
    WHERE Control_contrato = v_control_contrato;
  END IF;

  COMMIT;
END$$

DELIMITER ;

-- =====================================================
-- 5. STORED PROCEDURES AUXILIARES
-- =====================================================

-- Listar recaudadoras
DROP PROCEDURE IF EXISTS SP_ASEO_RECAUDADORAS_LIST;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_RECAUDADORAS_LIST()
BEGIN
  SELECT
    id_rec,
    id_zona,
    recaudadora,
    domicilio,
    tel,
    recaudador,
    sector
  FROM ta_16_recaudadoras
  WHERE activo = 1 OR activo IS NULL
  ORDER BY recaudadora;
END$$

DELIMITER ;

-- Listar zonas con control
DROP PROCEDURE IF EXISTS SP_ASEO_ZONAS_CONTROLES_LIST;

DELIMITER $$

CREATE PROCEDURE SP_ASEO_ZONAS_CONTROLES_LIST()
BEGIN
  SELECT
    ctrol_zona,
    zona,
    sub_zona,
    descripcion
  FROM ta_16_zonas
  WHERE activo = 1 OR activo IS NULL
  ORDER BY zona, sub_zona;
END$$

DELIMITER ;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Verificar creación de SPs
SELECT
  ROUTINE_NAME AS 'Stored Procedure',
  CREATED AS 'Fecha Creación'
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'RefactorX_Guadalajara'
  AND ROUTINE_TYPE = 'PROCEDURE'
  AND ROUTINE_NAME LIKE '%CONTRATOS%'
ORDER BY ROUTINE_NAME;

-- Nota: Crear tabla de historial si no existe
/*
CREATE TABLE IF NOT EXISTS ta_16_contratos_historial (
  id_historial INT AUTO_INCREMENT PRIMARY KEY,
  Control_contrato INT NOT NULL,
  Tipo_cambio INT NOT NULL COMMENT '0-8 según opción de cambio, 99=baja',
  Documento VARCHAR(50) NOT NULL,
  Descripcion TEXT,
  Periodo VARCHAR(7) COMMENT 'YYYY-MM',
  Usuario INT,
  Fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_contrato (Control_contrato),
  INDEX idx_fecha (Fecha_hora),
  FOREIGN KEY (Control_contrato) REFERENCES ta_16_Contratos(Control_contrato)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Historial de cambios en contratos';
*/
