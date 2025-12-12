<?php
// Script para crear recaudadora_periodo_inicial con parámetros del sistema

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_periodo_inicial(INTEGER) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Recrear tabla de parámetros del sistema
    echo "2. Recreando tabla publico.parametros_sistema...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.parametros_sistema CASCADE");

    $sql = "
    CREATE TABLE publico.parametros_sistema (
        id_parametro SERIAL PRIMARY KEY,
        municipio VARCHAR(200) NOT NULL,
        ejercicio INTEGER NOT NULL,
        bimestre_inicial INTEGER NOT NULL,
        año_inicial INTEGER NOT NULL,
        bimestre_final INTEGER NOT NULL,
        año_final INTEGER NOT NULL,
        director VARCHAR(200) NOT NULL,
        tesorero VARCHAR(200) NOT NULL,
        presidente VARCHAR(200) NOT NULL,
        salario NUMERIC(12,2) NOT NULL,
        aplica_descuento_recargo CHAR(1) DEFAULT 'S',
        fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(ejercicio)
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla recreada exitosamente.\n\n";

    // 3. Insertar registros de parámetros para varios ejercicios
    echo "3. Insertando parámetros del sistema para varios ejercicios...\n";

    $parametros = [
        [
            'municipio' => 'GUADALAJARA',
            'ejercicio' => 2024,
            'bimestre_inicial' => 1,
            'año_inicial' => 2024,
            'bimestre_final' => 6,
            'año_final' => 2024,
            'director' => 'LIC. JUAN CARLOS RAMIREZ LOPEZ',
            'tesorero' => 'C.P. MARIA GUADALUPE HERNANDEZ GARCIA',
            'presidente' => 'ING. ROBERTO SANCHEZ TORRES',
            'salario' => 207.44,
            'aplica_descuento_recargo' => 'S'
        ],
        [
            'municipio' => 'GUADALAJARA',
            'ejercicio' => 2023,
            'bimestre_inicial' => 1,
            'año_inicial' => 2023,
            'bimestre_final' => 6,
            'año_final' => 2023,
            'director' => 'LIC. JOSE LUIS GONZALEZ RAMIREZ',
            'tesorero' => 'C.P. ANA PATRICIA RODRIGUEZ SANCHEZ',
            'presidente' => 'LIC. FRANCISCO JAVIER PEREZ TORRES',
            'salario' => 172.87,
            'aplica_descuento_recargo' => 'S'
        ],
        [
            'municipio' => 'GUADALAJARA',
            'ejercicio' => 2022,
            'bimestre_inicial' => 1,
            'año_inicial' => 2022,
            'bimestre_final' => 6,
            'año_final' => 2022,
            'director' => 'LIC. MIGUEL ANGEL VAZQUEZ RUIZ',
            'tesorero' => 'C.P. LAURA ELENA JIMENEZ CRUZ',
            'presidente' => 'ING. PEDRO ANTONIO CASTRO REYES',
            'salario' => 141.70,
            'aplica_descuento_recargo' => 'S'
        ],
        [
            'municipio' => 'GUADALAJARA',
            'ejercicio' => 2021,
            'bimestre_inicial' => 1,
            'año_inicial' => 2021,
            'bimestre_final' => 6,
            'año_final' => 2021,
            'director' => 'LIC. MARTHA ELIZABETH RAMOS SILVA',
            'tesorero' => 'C.P. JORGE ALBERTO FLORES DOMINGUEZ',
            'presidente' => 'LIC. SILVIA CRISTINA MORENO GUTIERREZ',
            'salario' => 123.22,
            'aplica_descuento_recargo' => 'N'
        ],
        [
            'municipio' => 'GUADALAJARA',
            'ejercicio' => 2025,
            'bimestre_inicial' => 1,
            'año_inicial' => 2025,
            'bimestre_final' => 6,
            'año_final' => 2025,
            'director' => 'LIC. RICARDO DAVID AGUILAR VARGAS',
            'tesorero' => 'C.P. GABRIELA MENDEZ ORTIZ',
            'presidente' => 'ING. CARMEN ROSA LOPEZ FERNANDEZ',
            'salario' => 248.93,
            'aplica_descuento_recargo' => 'S'
        ]
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.parametros_sistema
        (municipio, ejercicio, bimestre_inicial, año_inicial, bimestre_final, año_final,
         director, tesorero, presidente, salario, aplica_descuento_recargo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    foreach ($parametros as $param) {
        $stmt->execute([
            $param['municipio'],
            $param['ejercicio'],
            $param['bimestre_inicial'],
            $param['año_inicial'],
            $param['bimestre_final'],
            $param['año_final'],
            $param['director'],
            $param['tesorero'],
            $param['presidente'],
            $param['salario'],
            $param['aplica_descuento_recargo']
        ]);
    }

    echo "   ✓ " . count($parametros) . " registros insertados.\n";
    echo "   Ejercicios: 2021, 2022, 2023, 2024, 2025\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_params_ejercicio ON publico.parametros_sistema(ejercicio)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_periodo_inicial...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_periodo_inicial(
        p_ejercicio INTEGER
    )
    RETURNS TABLE (
        municipio VARCHAR,
        ejercicio INTEGER,
        bimestre_inicial INTEGER,
        año_inicial INTEGER,
        bimestre_final INTEGER,
        año_final INTEGER,
        director VARCHAR,
        tesorero VARCHAR,
        presidente VARCHAR,
        salario NUMERIC,
        aplica_descuento_recargo CHAR
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            p.municipio,
            p.ejercicio,
            p.bimestre_inicial,
            p.año_inicial,
            p.bimestre_final,
            p.año_final,
            p.director,
            p.tesorero,
            p.presidente,
            p.salario,
            p.aplica_descuento_recargo
        FROM publico.parametros_sistema p
        WHERE
            p_ejercicio IS NULL OR p.ejercicio = p_ejercicio
        ORDER BY p.ejercicio DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Parámetros del ejercicio 2024',
            'ejercicio' => 2024
        ],
        [
            'nombre' => 'Parámetros del ejercicio 2023',
            'ejercicio' => 2023
        ],
        [
            'nombre' => 'Parámetros del ejercicio 2025',
            'ejercicio' => 2025
        ],
        [
            'nombre' => 'Todos los ejercicios (sin filtro)',
            'ejercicio' => null
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_periodo_inicial(?)");
        $stmt->execute([$test['ejercicio']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " registro(s)\n";

        if (count($rows) > 0) {
            foreach ($rows as $row) {
                echo "      - Municipio: " . $row['municipio'] .
                     " - Ejercicio: " . $row['ejercicio'] .
                     " - Período: Bim " . $row['bimestre_inicial'] . "/" . $row['año_inicial'] .
                     " a Bim " . $row['bimestre_final'] . "/" . $row['año_final'] . "\n";
                echo "        Director: " . $row['director'] . "\n";
                echo "        Tesorero: " . $row['tesorero'] . "\n";
                echo "        Presidente: " . $row['presidente'] . "\n";
                echo "        Salario Mínimo: $" . number_format($row['salario'], 2) . "\n";
                echo "        Aplica Desc/Rec: " . ($row['aplica_descuento_recargo'] === 'S' ? 'Sí' : 'No') . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla parametros_sistema creada con 5 ejercicios (2021-2025)\n";
    echo "   - SP recaudadora_periodo_inicial creado\n";
    echo "   - Retorna parámetros del sistema por ejercicio\n";
    echo "   - Incluye: Director, Tesorero, Presidente\n";
    echo "   - Salario mínimo y configuración de descuentos/recargos\n";
    echo "   - Período bimestral de operación\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
