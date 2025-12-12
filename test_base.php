<?php
// Script para crear tablas de requerimientos (predial, multa, licencia) y SP de modificación masiva

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Eliminar función existente si existe
    echo "1. Eliminando función existente si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_modif_masiva(TEXT) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla req_predial
    echo "2. Creando tabla publico.req_predial...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.req_predial CASCADE");
    $sql = "
    CREATE TABLE publico.req_predial (
        id_req SERIAL PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        folio INTEGER NOT NULL,
        clave_cuenta VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        concepto VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
        axo INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_predial creada.\n\n";

    // 3. Crear tabla req_multa
    echo "3. Creando tabla publico.req_multa...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.req_multa CASCADE");
    $sql = "
    CREATE TABLE publico.req_multa (
        id_req SERIAL PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        folio INTEGER NOT NULL,
        num_multa VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        infraccion VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
        axo INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_multa creada.\n\n";

    // 4. Crear tabla req_licencia
    echo "4. Creando tabla publico.req_licencia...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.req_licencia CASCADE");
    $sql = "
    CREATE TABLE publico.req_licencia (
        id_req SERIAL PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        folio INTEGER NOT NULL,
        num_licencia VARCHAR(50) NOT NULL,
        contribuyente VARCHAR(200) NOT NULL,
        tipo_licencia VARCHAR(200) NOT NULL,
        monto NUMERIC(12,2) NOT NULL,
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
        axo INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_licencia creada.\n\n";

    // 5. Insertar datos de prueba
    echo "5. Insertando datos de prueba...\n";

    $contribuyentes = [
        'JUAN CARLOS MARTINEZ GARCIA',
        'MARIA GUADALUPE HERNANDEZ LOPEZ',
        'JOSE LUIS GONZALEZ RAMIREZ',
        'ANA PATRICIA RODRIGUEZ SANCHEZ',
        'ROBERTO CARLOS SANCHEZ MORALES'
    ];

    // Predial: 50 registros
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_predial (recaudadora, folio, clave_cuenta, contribuyente, concepto, monto, estado, axo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 1328820; $i <= 1328870; $i++) {
        $stmt->execute([
            (($i % 5) + 1),  // recaudadora 1-5
            $i,
            'CTA-' . str_pad($i - 1328000, 6, '0', STR_PAD_LEFT),
            $contribuyentes[($i - 1328820) % 5],
            'IMPUESTO PREDIAL',
            rand(500, 5000) + 0.50,
            'ACTIVO',
            2024
        ]);
    }
    echo "   ✓ 51 registros insertados en req_predial (folios 1328820-1328870).\n";

    // Multa: 50 registros
    $infracciones = [
        'EXCESO DE VELOCIDAD',
        'ESTACIONAMIENTO PROHIBIDO',
        'NO RESPETAR SEMAFORO',
        'CIRCULAR SIN PLACAS',
        'CONDUCTOR EBRIO'
    ];
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_multa (recaudadora, folio, num_multa, contribuyente, infraccion, monto, estado, axo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 100635; $i <= 100685; $i++) {
        $stmt->execute([
            (($i % 5) + 1),
            $i,
            'MUL-' . $i,
            $contribuyentes[($i - 100635) % 5],
            $infracciones[($i - 100635) % 5],
            rand(300, 3000) + 0.50,
            'ACTIVO',
            2024
        ]);
    }
    echo "   ✓ 51 registros insertados en req_multa (folios 100635-100685).\n";

    // Licencia: 50 registros
    $tipos_lic = [
        'LICENCIA DE FUNCIONAMIENTO',
        'LICENCIA DE ANUNCIO',
        'LICENCIA ALCOHOLES',
        'LICENCIA DE CONSTRUCCION',
        'LICENCIA TEMPORAL'
    ];
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_licencia (recaudadora, folio, num_licencia, contribuyente, tipo_licencia, monto, estado, axo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 28745; $i <= 28795; $i++) {
        $stmt->execute([
            (($i % 5) + 1),
            $i,
            'LIC-' . $i,
            $contribuyentes[($i - 28745) % 5],
            $tipos_lic[($i - 28745) % 5],
            rand(800, 8000) + 0.50,
            'ACTIVO',
            2024
        ]);
    }
    echo "   ✓ 51 registros insertados en req_licencia (folios 28745-28795).\n\n";

    // 6. Crear índices
    echo "6. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_req_predial_recaud_folio ON publico.req_predial(recaudadora, folio)");
    $pdo->exec("CREATE INDEX idx_req_predial_estado ON publico.req_predial(estado)");
    $pdo->exec("CREATE INDEX idx_req_multa_recaud_folio ON publico.req_multa(recaudadora, folio)");
    $pdo->exec("CREATE INDEX idx_req_multa_estado ON publico.req_multa(estado)");
    $pdo->exec("CREATE INDEX idx_req_licencia_recaud_folio ON publico.req_licencia(recaudadora, folio)");
    $pdo->exec("CREATE INDEX idx_req_licencia_estado ON publico.req_licencia(estado)");
    echo "   ✓ Índices creados.\n\n";

    // 7. Crear el stored procedure
    echo "7. Creando stored procedure publico.recaudadora_modif_masiva...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_modif_masiva(datos TEXT)
    RETURNS TABLE (
        tipo_req VARCHAR,
        registros_actualizados INTEGER,
        folio_inicio INTEGER,
        folio_final INTEGER,
        mensaje TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    DECLARE
        v_json JSON;
        v_tipo TEXT;
        v_recaud INTEGER;
        v_folio_ini INTEGER;
        v_folio_fin INTEGER;
        v_fecha DATE;
        v_accion TEXT;
        v_axo INTEGER;
        v_count INTEGER;
        v_affected INTEGER;
    BEGIN
        -- Parsear JSON
        BEGIN
            v_json := datos::JSON;
            v_tipo := v_json->>'tipo';
            v_recaud := (v_json->>'recaud')::INTEGER;
            v_folio_ini := (v_json->>'folio_ini')::INTEGER;
            v_folio_fin := (v_json->>'folio_fin')::INTEGER;
            v_fecha := (v_json->>'fecha')::DATE;
            v_accion := v_json->>'accion';
            v_axo := EXTRACT(YEAR FROM v_fecha)::INTEGER;
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT
                'error'::VARCHAR,
                0::INTEGER,
                0::INTEGER,
                0::INTEGER,
                ('Error al parsear JSON: ' || SQLERRM)::TEXT;
            RETURN;
        END;

        -- Validar tipo
        IF v_tipo NOT IN ('predial', 'multa', 'licencia') THEN
            RETURN QUERY SELECT
                'error'::VARCHAR,
                0::INTEGER,
                v_folio_ini,
                v_folio_fin,
                ('Tipo inválido: ' || COALESCE(v_tipo, 'null') || '. Debe ser: predial, multa o licencia')::TEXT;
            RETURN;
        END IF;

        -- Procesar según tipo
        IF v_tipo = 'predial' THEN
            -- Contar registros
            SELECT COUNT(*) INTO v_count
            FROM publico.req_predial
            WHERE recaudadora = v_recaud
              AND folio BETWEEN v_folio_ini AND v_folio_fin
              AND estado = 'ACTIVO';

            IF v_accion = 'consultar' THEN
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_count::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta realizada: ' || v_count || ' registros encontrados')::TEXT;
            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_predial
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '7 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación realizada exitosamente: ' || v_affected || ' registros actualizados')::TEXT;
            ELSIF v_accion = 'cancelar' THEN
                UPDATE publico.req_predial
                SET estado = 'CANCELADO'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Cancelación realizada: ' || v_affected || ' registros cancelados')::TEXT;
            END IF;

        ELSIF v_tipo = 'multa' THEN
            SELECT COUNT(*) INTO v_count
            FROM publico.req_multa
            WHERE recaudadora = v_recaud
              AND folio BETWEEN v_folio_ini AND v_folio_fin
              AND estado = 'ACTIVO';

            IF v_accion = 'consultar' THEN
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_count::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta realizada: ' || v_count || ' registros encontrados')::TEXT;
            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_multa
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '7 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación realizada exitosamente: ' || v_affected || ' registros actualizados')::TEXT;
            ELSIF v_accion = 'cancelar' THEN
                DELETE FROM publico.req_multa
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Eliminación realizada: ' || v_affected || ' registros eliminados (irreversible)')::TEXT;
            END IF;

        ELSIF v_tipo = 'licencia' THEN
            SELECT COUNT(*) INTO v_count
            FROM publico.req_licencia
            WHERE recaudadora = v_recaud
              AND folio BETWEEN v_folio_ini AND v_folio_fin
              AND estado = 'ACTIVO';

            IF v_accion = 'consultar' THEN
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_count::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta realizada: ' || v_count || ' registros encontrados')::TEXT;
            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_licencia
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '7 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación realizada exitosamente: ' || v_affected || ' registros actualizados')::TEXT;
            ELSIF v_accion = 'cancelar' THEN
                DELETE FROM publico.req_licencia
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';
                GET DIAGNOSTICS v_affected = ROW_COUNT;
                RETURN QUERY SELECT
                    v_tipo::VARCHAR,
                    v_affected::INTEGER,
                    v_folio_ini,
                    v_folio_fin,
                    ('Eliminación realizada: ' || v_affected || ' registros eliminados (irreversible)')::TEXT;
            END IF;
        END IF;

        RETURN;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 8. Probar el SP
    echo "8. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Consultar predial (recaudadora 3, folios 1328820-1328830)',
            'json' => '{"tipo":"predial","recaud":3,"folio_ini":1328820,"folio_fin":1328830,"fecha":"2025-01-17","accion":"consultar"}'
        ],
        [
            'nombre' => 'Consultar multa (recaudadora 2, folios 100635-100650)',
            'json' => '{"tipo":"multa","recaud":2,"folio_ini":100635,"folio_fin":100650,"fecha":"2024-04-29","accion":"consultar"}'
        ],
        [
            'nombre' => 'Consultar licencia (recaudadora 2, folios 28745-28755)',
            'json' => '{"tipo":"licencia","recaud":2,"folio_ini":28745,"folio_fin":28755,"fecha":"2024-01-01","accion":"consultar"}'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?)");
        $stmt->execute([$test['json']]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            echo "   Tipo: " . $row['tipo_req'] . "\n";
            echo "   Registros: " . $row['registros_actualizados'] . "\n";
            echo "   Folios: " . $row['folio_inicio'] . " - " . $row['folio_final'] . "\n";
            echo "   Mensaje: " . $row['mensaje'] . "\n";
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla req_predial creada con 51 registros (folios 1328820-1328870)\n";
    echo "   - Tabla req_multa creada con 51 registros (folios 100635-100685)\n";
    echo "   - Tabla req_licencia creada con 51 registros (folios 28745-28795)\n";
    echo "   - SP recaudadora_modif_masiva creado\n";
    echo "   - Parámetro: JSON con tipo, recaud, folio_ini, folio_fin, fecha, accion\n";
    echo "   - Acciones: consultar, modificar, cancelar\n";
    echo "   - Tipos: predial (marca CANCELADO), multa (DELETE), licencia (DELETE)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
