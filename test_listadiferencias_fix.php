<?php
// Script para crear tabla diferencias y su stored procedure

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
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_lista_diferencias(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada.\n\n";

    // 2. Crear tabla de diferencias
    echo "2. Creando tabla publico.diferencias...\n";
    $pdo->exec("DROP TABLE IF EXISTS publico.diferencias CASCADE");

    $sql = "
    CREATE TABLE publico.diferencias (
        id_diferencia SERIAL PRIMARY KEY,
        tipo_registro VARCHAR(100) NOT NULL,
        campo_afectado VARCHAR(100) NOT NULL,
        valor_sistema VARCHAR(200),
        valor_registrado VARCHAR(200),
        diferencia_monto NUMERIC(12,2),
        folio VARCHAR(50) NOT NULL,
        fecha_deteccion DATE NOT NULL,
        estado VARCHAR(20) NOT NULL,
        responsable VARCHAR(100),
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ";
    $pdo->exec($sql);
    echo "   ✓ Tabla creada exitosamente.\n\n";

    // 3. Insertar registros de diferencias
    echo "3. Insertando 45 registros de diferencias detectadas...\n";

    $tipos_registro = [
        'PAGO DE MULTA',
        'PAGO DE LICENCIA',
        'PAGO PREDIAL',
        'DESCUENTO APLICADO',
        'CONDONACION',
        'RECARGO'
    ];

    $campos_afectados = [
        'MONTO TOTAL',
        'FECHA DE PAGO',
        'NUMERO DE CUENTA',
        'DESCUENTO APLICADO',
        'RECARGO CALCULADO',
        'FOLIO DE REFERENCIA',
        'IMPORTE BASE'
    ];

    $estados = ['PENDIENTE', 'REVISADO', 'CORREGIDO', 'RECHAZADO'];

    $responsables = [
        'CAJERO-01',
        'CAJERO-02',
        'SUPERVISOR-A',
        'SISTEMA AUTO',
        'AUDITOR-01'
    ];

    $stmt = $pdo->prepare("
        INSERT INTO publico.diferencias
        (tipo_registro, campo_afectado, valor_sistema, valor_registrado, diferencia_monto,
         folio, fecha_deteccion, estado, responsable, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $hoy = new DateTime();

    for ($i = 1; $i <= 45; $i++) {
        $tipo_registro = $tipos_registro[$i % 6];
        $campo_afectado = $campos_afectados[$i % 7];

        // Generar valores diferentes para crear diferencias
        $valor_sistema_num = 1000.00 + ($i * 125.50);

        // Crear una diferencia real entre sistema y registrado
        $diferencia_porcentaje = [0.05, 0.10, 0.15, 0.20, 0.25];
        $dif_pct = $diferencia_porcentaje[$i % 5];
        $valor_registrado_num = $valor_sistema_num * (1 + $dif_pct);
        $diferencia_monto = abs($valor_sistema_num - $valor_registrado_num);

        $valor_sistema = "$" . number_format($valor_sistema_num, 2);
        $valor_registrado = "$" . number_format($valor_registrado_num, 2);

        // Para algunos campos no numéricos
        if ($campo_afectado === 'FECHA DE PAGO' || $campo_afectado === 'NUMERO DE CUENTA' || $campo_afectado === 'FOLIO DE REFERENCIA') {
            if ($campo_afectado === 'FECHA DE PAGO') {
                $valor_sistema = "2024-" . str_pad(($i % 12) + 1, 2, '0', STR_PAD_LEFT) . "-15";
                $valor_registrado = "2024-" . str_pad(($i % 12) + 1, 2, '0', STR_PAD_LEFT) . "-" . (15 + ($i % 10));
                $diferencia_monto = null;
            } elseif ($campo_afectado === 'NUMERO DE CUENTA') {
                $valor_sistema = "CTA-" . str_pad(1000 + $i, 6, '0', STR_PAD_LEFT);
                $valor_registrado = "CTA-" . str_pad(1000 + $i + 1, 6, '0', STR_PAD_LEFT);
                $diferencia_monto = null;
            } else {
                $valor_sistema = "FOL-" . str_pad($i * 100, 5, '0', STR_PAD_LEFT);
                $valor_registrado = "FOL-" . str_pad($i * 100 + 1, 5, '0', STR_PAD_LEFT);
                $diferencia_monto = null;
            }
        }

        $folio = "DIF-" . date('Y') . "-" . str_pad($i, 5, '0', STR_PAD_LEFT);

        // Fecha: últimos 60 días
        $fecha_deteccion = clone $hoy;
        $dias_atras = rand(1, 60);
        $fecha_deteccion->modify("-{$dias_atras} days");

        $estado = $estados[$i % 4];
        $responsable = $responsables[$i % 5];

        $observaciones_list = [
            'Diferencia detectada por auditoría automática',
            'Posible error de captura manual',
            'Requiere revisión del cajero',
            'Diferencia en cálculo de recargos',
            null,
            'Verificar con contribuyente',
            'Descuento mal aplicado',
            'Error en sistema de cálculo'
        ];
        $observaciones = $observaciones_list[$i % 8];

        $stmt->execute([
            $tipo_registro,
            $campo_afectado,
            $valor_sistema,
            $valor_registrado,
            $diferencia_monto,
            $folio,
            $fecha_deteccion->format('Y-m-d'),
            $estado,
            $responsable,
            $observaciones
        ]);
    }
    echo "   ✓ 45 registros insertados.\n";
    echo "   Distribución:\n";
    echo "   - Tipos: Pago de Multa, Licencia, Predial, Descuento, Condonación, Recargo\n";
    echo "   - Estados: PENDIENTE, REVISADO, CORREGIDO, RECHAZADO\n";
    echo "   - Responsables: Cajeros, Supervisores, Sistema Auto, Auditor\n\n";

    // 4. Crear índices
    echo "4. Creando índices...\n";
    $pdo->exec("CREATE INDEX idx_diferencias_tipo ON publico.diferencias(tipo_registro)");
    $pdo->exec("CREATE INDEX idx_diferencias_campo ON publico.diferencias(campo_afectado)");
    $pdo->exec("CREATE INDEX idx_diferencias_estado ON publico.diferencias(estado)");
    $pdo->exec("CREATE INDEX idx_diferencias_fecha ON publico.diferencias(fecha_deteccion DESC)");
    echo "   ✓ Índices creados.\n\n";

    // 5. Crear el stored procedure
    echo "5. Creando stored procedure publico.recaudadora_lista_diferencias...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_lista_diferencias(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        id_diferencia INTEGER,
        tipo_registro VARCHAR,
        campo_afectado VARCHAR,
        valor_sistema VARCHAR,
        valor_registrado VARCHAR,
        diferencia_monto NUMERIC,
        folio VARCHAR,
        fecha_deteccion DATE,
        estado VARCHAR,
        responsable VARCHAR,
        observaciones TEXT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            d.id_diferencia,
            d.tipo_registro,
            d.campo_afectado,
            d.valor_sistema,
            d.valor_registrado,
            d.diferencia_monto,
            d.folio,
            d.fecha_deteccion,
            d.estado,
            d.responsable,
            d.observaciones
        FROM publico.diferencias d
        WHERE
            p_filtro = '' OR p_filtro IS NULL
            OR d.tipo_registro ILIKE '%' || p_filtro || '%'
            OR d.campo_afectado ILIKE '%' || p_filtro || '%'
            OR d.valor_sistema ILIKE '%' || p_filtro || '%'
            OR d.valor_registrado ILIKE '%' || p_filtro || '%'
            OR d.folio ILIKE '%' || p_filtro || '%'
            OR d.estado ILIKE '%' || p_filtro || '%'
            OR d.responsable ILIKE '%' || p_filtro || '%'
        ORDER BY d.fecha_deteccion DESC, d.id_diferencia DESC;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 6. Probar el SP con varios ejemplos
    echo "6. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Todas las diferencias (sin filtro)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Filtrar por estado PENDIENTE',
            'filtro' => 'PENDIENTE'
        ],
        [
            'nombre' => 'Filtrar por tipo PAGO DE MULTA',
            'filtro' => 'PAGO DE MULTA'
        ],
        [
            'nombre' => 'Filtrar por campo MONTO TOTAL',
            'filtro' => 'MONTO TOTAL'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_lista_diferencias(?)");
        $stmt->execute([$test['filtro']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " diferencia(s)\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 registros:\n";
            foreach (array_slice($rows, 0, 3) as $row) {
                echo "      - ID: " . $row['id_diferencia'] .
                     " | Tipo: " . $row['tipo_registro'] .
                     " | Campo: " . $row['campo_afectado'] .
                     " | Sistema: " . $row['valor_sistema'] .
                     " | Registrado: " . $row['valor_registrado'];
                if ($row['diferencia_monto']) {
                    echo " | Diferencia: $" . number_format($row['diferencia_monto'], 2);
                }
                echo " | Estado: " . $row['estado'] .
                     " | Responsable: " . $row['responsable'] . "\n";
            }
        }
        echo "\n";
    }

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - Tabla diferencias creada con 45 registros\n";
    echo "   - Tipos de registro: Pago de Multa, Licencia, Predial, Descuento, Condonación, Recargo\n";
    echo "   - Campos afectados: Monto Total, Fecha, Cuenta, Descuento, Recargo, Folio, Importe\n";
    echo "   - Estados: PENDIENTE, REVISADO, CORREGIDO, RECHAZADO\n";
    echo "   - Incluye diferencias monetarias calculadas\n";
    echo "   - SP recaudadora_lista_diferencias creado\n";
    echo "   - Búsqueda por: tipo, campo, valores, folio, estado, responsable\n";
    echo "   - Ordenado por fecha más reciente primero\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
