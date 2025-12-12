<?php
// Script para crear el SP modif_masiva con manejo de JSON

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear tablas para los 3 tipos de requerimientos
    echo "1. Creando tablas de requerimientos...\n";

    // Tabla de predial
    $pdo->exec("DROP TABLE IF EXISTS publico.req_predial CASCADE");
    $sql = "
    CREATE TABLE publico.req_predial (
        folio INTEGER PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        clave_cuenta VARCHAR(50),
        contribuyente VARCHAR(200),
        monto NUMERIC(12,2),
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) DEFAULT 'ACTIVO',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_predial creada.\n";

    // Tabla de multas
    $pdo->exec("DROP TABLE IF EXISTS publico.req_multa CASCADE");
    $sql = "
    CREATE TABLE publico.req_multa (
        folio INTEGER PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        num_acta VARCHAR(50),
        contribuyente VARCHAR(200),
        monto NUMERIC(12,2),
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) DEFAULT 'ACTIVO',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_multa creada.\n";

    // Tabla de licencias
    $pdo->exec("DROP TABLE IF EXISTS publico.req_licencia CASCADE");
    $sql = "
    CREATE TABLE publico.req_licencia (
        folio INTEGER PRIMARY KEY,
        recaudadora INTEGER NOT NULL,
        num_licencia VARCHAR(50),
        contribuyente VARCHAR(200),
        monto NUMERIC(12,2),
        fecha_practica DATE,
        fecha_entrega DATE,
        estado VARCHAR(20) DEFAULT 'ACTIVO',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla req_licencia creada.\n\n";

    // 2. Insertar datos de prueba
    echo "2. Insertando datos de prueba...\n";

    $contribuyentes = [
        'MARIA GUADALUPE HERNANDEZ LOPEZ',
        'JUAN CARLOS MARTINEZ GARCIA',
        'ANA PATRICIA RODRIGUEZ SANCHEZ',
        'JOSE LUIS GONZALEZ RAMIREZ',
        'CARMEN ROSA LOPEZ FERNANDEZ'
    ];

    // Insertar prediales (folios 1328820-1328850)
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_predial
        (folio, recaudadora, clave_cuenta, contribuyente, monto, fecha_practica, fecha_entrega, estado)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 1328820; $i <= 1328850; $i++) {
        $rec = ((($i - 1328820) % 5) + 1);
        $cuenta = "PRED-" . str_pad($i - 1328800, 5, '0', STR_PAD_LEFT);
        $contrib = $contribuyentes[($i - 1328820) % 5];
        $monto = 1500.00 + (($i - 1328820) * 50);
        $fecha_p = date('Y-m-d', strtotime("2024-01-01 +" . ($i - 1328820) . " days"));
        $fecha_e = date('Y-m-d', strtotime($fecha_p . " +15 days"));
        $estado = ($i % 3 == 0) ? 'CANCELADO' : 'ACTIVO';
        $stmt->execute([$i, $rec, $cuenta, $contrib, $monto, $fecha_p, $fecha_e, $estado]);
    }
    echo "   ✓ 31 registros de predial insertados (folios 1328820-1328850).\n";

    // Insertar multas (folios 100635-100665)
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_multa
        (folio, recaudadora, num_acta, contribuyente, monto, fecha_practica, fecha_entrega, estado)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 100635; $i <= 100665; $i++) {
        $rec = ((($i - 100635) % 5) + 1);
        $acta = "ACTA-" . ($i - 100000);
        $contrib = $contribuyentes[($i - 100635) % 5];
        $monto = 800.00 + (($i - 100635) * 35);
        $fecha_p = date('Y-m-d', strtotime("2024-04-01 +" . ($i - 100635) . " days"));
        $fecha_e = date('Y-m-d', strtotime($fecha_p . " +10 days"));
        $estado = ($i % 4 == 0) ? 'CANCELADO' : 'ACTIVO';
        $stmt->execute([$i, $rec, $acta, $contrib, $monto, $fecha_p, $fecha_e, $estado]);
    }
    echo "   ✓ 31 registros de multa insertados (folios 100635-100665).\n";

    // Insertar licencias (folios 28745-28775)
    $stmt = $pdo->prepare("
        INSERT INTO publico.req_licencia
        (folio, recaudadora, num_licencia, contribuyente, monto, fecha_practica, fecha_entrega, estado)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    for ($i = 28745; $i <= 28775; $i++) {
        $rec = ((($i - 28745) % 5) + 1);
        $lic = "LIC-" . ($i - 28000);
        $contrib = $contribuyentes[($i - 28745) % 5];
        $monto = 500.00 + (($i - 28745) * 25);
        $fecha_p = date('Y-m-d', strtotime("2024-01-01 +" . ($i - 28745) . " days"));
        $fecha_e = date('Y-m-d', strtotime($fecha_p . " +20 days"));
        $estado = ($i % 5 == 0) ? 'CANCELADO' : 'ACTIVO';
        $stmt->execute([$i, $rec, $lic, $contrib, $monto, $fecha_p, $fecha_e, $estado]);
    }
    echo "   ✓ 31 registros de licencia insertados (folios 28745-28775).\n\n";

    // 3. Crear el stored procedure
    echo "3. Creando stored procedure publico.recaudadora_modif_masiva...\n";
    $sql = "
    CREATE OR REPLACE FUNCTION publico.recaudadora_modif_masiva(
        datos TEXT
    )
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
        v_json JSONB;
        v_tipo VARCHAR;
        v_recaud INTEGER;
        v_folio_ini INTEGER;
        v_folio_fin INTEGER;
        v_fecha DATE;
        v_accion VARCHAR;
        v_count INTEGER;
        v_updated INTEGER;
    BEGIN
        -- Parsear el JSON de entrada
        BEGIN
            v_json := datos::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT
                'error'::VARCHAR,
                0,
                0,
                0,
                'Error: JSON inválido'::TEXT;
            RETURN;
        END;

        -- Extraer valores del JSON
        v_tipo := v_json->>'tipo';
        v_recaud := (v_json->>'recaud')::INTEGER;
        v_folio_ini := (v_json->>'folio_ini')::INTEGER;
        v_folio_fin := (v_json->>'folio_fin')::INTEGER;
        v_fecha := (v_json->>'fecha')::DATE;
        v_accion := COALESCE(v_json->>'accion', 'consultar');

        -- Validar tipo
        IF v_tipo NOT IN ('predial', 'multa', 'licencia') THEN
            RETURN QUERY SELECT
                'error'::VARCHAR,
                0,
                v_folio_ini,
                v_folio_fin,
                ('Error: Tipo inválido. Debe ser: predial, multa o licencia')::TEXT;
            RETURN;
        END IF;

        -- Procesar según el tipo y acción
        IF v_tipo = 'predial' THEN
            IF v_accion = 'consultar' THEN
                SELECT COUNT(*) INTO v_count
                FROM publico.req_predial
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                RETURN QUERY SELECT
                    'predial'::VARCHAR,
                    v_count,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta: ' || v_count || ' registros encontrados')::TEXT;

            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_predial
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '15 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'predial'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación exitosa: ' || v_updated || ' registros actualizados')::TEXT;

            ELSIF v_accion = 'cancelar' THEN
                UPDATE publico.req_predial
                SET estado = 'CANCELADO'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'predial'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('Cancelación exitosa: ' || v_updated || ' registros cancelados')::TEXT;
            END IF;

        ELSIF v_tipo = 'multa' THEN
            IF v_accion = 'consultar' THEN
                SELECT COUNT(*) INTO v_count
                FROM publico.req_multa
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                RETURN QUERY SELECT
                    'multa'::VARCHAR,
                    v_count,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta: ' || v_count || ' registros encontrados')::TEXT;

            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_multa
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '10 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'multa'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación exitosa: ' || v_updated || ' registros actualizados')::TEXT;

            ELSIF v_accion = 'cancelar' THEN
                DELETE FROM publico.req_multa
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'multa'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('⚠️ Eliminación exitosa: ' || v_updated || ' registros eliminados permanentemente')::TEXT;
            END IF;

        ELSIF v_tipo = 'licencia' THEN
            IF v_accion = 'consultar' THEN
                SELECT COUNT(*) INTO v_count
                FROM publico.req_licencia
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                RETURN QUERY SELECT
                    'licencia'::VARCHAR,
                    v_count,
                    v_folio_ini,
                    v_folio_fin,
                    ('Consulta: ' || v_count || ' registros encontrados')::TEXT;

            ELSIF v_accion = 'modificar' THEN
                UPDATE publico.req_licencia
                SET fecha_practica = v_fecha,
                    fecha_entrega = v_fecha + INTERVAL '20 days'
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'licencia'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('Modificación exitosa: ' || v_updated || ' registros actualizados')::TEXT;

            ELSIF v_accion = 'cancelar' THEN
                DELETE FROM publico.req_licencia
                WHERE recaudadora = v_recaud
                  AND folio BETWEEN v_folio_ini AND v_folio_fin
                  AND estado = 'ACTIVO';

                GET DIAGNOSTICS v_updated = ROW_COUNT;

                RETURN QUERY SELECT
                    'licencia'::VARCHAR,
                    v_updated,
                    v_folio_ini,
                    v_folio_fin,
                    ('⚠️ Eliminación exitosa: ' || v_updated || ' registros eliminados permanentemente')::TEXT;
            END IF;
        END IF;

        RETURN;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 4. Probar el SP con varios ejemplos
    echo "4. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Consultar prediales en recaudadora 3, folios 1328820-1328830',
            'json' => '{"tipo":"predial","recaud":3,"folio_ini":1328820,"folio_fin":1328830,"fecha":"2025-01-17","accion":"consultar"}'
        ],
        [
            'nombre' => 'Consultar multas en recaudadora 2, folios 100635-100650',
            'json' => '{"tipo":"multa","recaud":2,"folio_ini":100635,"folio_fin":100650,"fecha":"2024-04-29","accion":"consultar"}'
        ],
        [
            'nombre' => 'Consultar licencias en recaudadora 2, folios 28745-28755',
            'json' => '{"tipo":"licencia","recaud":2,"folio_ini":28745,"folio_fin":28755,"fecha":"2024-01-01","accion":"consultar"}'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_modif_masiva(?)");
        $stmt->execute([$test['json']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($rows) > 0) {
            foreach ($rows as $row) {
                echo "      - Tipo: " . $row['tipo_req'] . "\n";
                echo "      - Registros: " . $row['registros_actualizados'] . "\n";
                echo "      - Rango: " . $row['folio_inicio'] . " - " . $row['folio_final'] . "\n";
                echo "      - Mensaje: " . $row['mensaje'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 NOTA: El SP maneja 3 tipos (predial, multa, licencia) y 3 acciones:\n";
    echo "   - consultar: Solo cuenta registros\n";
    echo "   - modificar: Actualiza fechas de práctica y entrega\n";
    echo "   - cancelar: Marca como cancelado (predial) o elimina (multa, licencia)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
