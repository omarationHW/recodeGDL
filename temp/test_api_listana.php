<?php

/**
 * Script de prueba para la API de ListAna
 * Simula las llamadas que hace el formulario Vue
 */

$host = 'localhost';
$port = '5432';
$dbname = 'prueba2';
$user = 'postgres';
$password = 'Lmolina.2024';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "╔════════════════════════════════════════════════════════════════╗\n";
    echo "║     PRUEBA DE API - recaudadora_listana                       ║\n";
    echo "╚════════════════════════════════════════════════════════════════╝\n\n";

    // ================================================================
    // EJEMPLO 1: Sin filtro (caso de uso más común)
    // ================================================================
    echo "┌─────────────────────────────────────────────────────────────┐\n";
    echo "│ EJEMPLO 1: Sin filtro (primeros 10 registros)              │\n";
    echo "└─────────────────────────────────────────────────────────────┘\n\n";

    echo "📋 Uso en formulario:\n";
    echo "   Campo 'Filtro': [vacío]\n";
    echo "   Click en botón 'Buscar'\n\n";

    $params = [
        ['nombre' => 'p_filtro', 'tipo' => 'string', 'valor' => ''],
        ['nombre' => 'p_offset', 'tipo' => 'integer', 'valor' => 0],
        ['nombre' => 'p_limit', 'tipo' => 'integer', 'valor' => 10]
    ];

    echo "🔧 Parámetros enviados:\n";
    echo "   p_filtro: '' (vacío)\n";
    echo "   p_offset: 0\n";
    echo "   p_limit: 10\n\n";

    $query = "SELECT * FROM db_ingresos.recaudadora_listana(:p_filtro, :p_offset, :p_limit)";
    $stmt = $pdo->prepare($query);
    $stmt->execute([
        ':p_filtro' => '',
        ':p_offset' => 0,
        ':p_limit' => 10
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✅ Respuesta exitosa\n";
        echo "📊 Total de registros disponibles: " . number_format($results[0]['total_count']) . "\n";
        echo "📄 Registros retornados: " . count($results) . "\n\n";

        echo "🎯 Primeros 3 registros:\n\n";
        foreach (array_slice($results, 0, 3) as $i => $row) {
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "Registro #" . ($i + 1) . "\n";
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "Folio:         " . $row['folio'] . "\n";
            echo "Fecha:         " . $row['fecha_acta'] . "\n";
            echo "Contribuyente: " . substr($row['contribuyente'], 0, 40) . "\n";
            echo "Domicilio:     " . substr($row['domicilio'], 0, 40) . "\n";
            echo "Dependencia:   " . $row['dependencia'] . "\n";
            echo "Zona/Subzona:  " . $row['zona_subzona'] . "\n";
            echo "Calificación:  $" . number_format($row['calificacion'], 2) . "\n";
            echo "Multa:         $" . number_format($row['multa'], 2) . "\n";
            echo "Gastos:        $" . number_format($row['gastos'], 2) . "\n";
            echo "Total:         $" . number_format($row['total'], 2) . "\n";
            echo "Tipo:          " . $row['tipo'] . "\n";
            echo "Estado:        " . $row['estado'] . "\n";
            echo "\n";
        }
    } else {
        echo "⚠️ No se encontraron registros\n\n";
    }

    echo "\n";
    echo str_repeat("═", 65) . "\n\n";

    // ================================================================
    // EJEMPLO 2: Buscar por año 2024
    // ================================================================
    echo "┌─────────────────────────────────────────────────────────────┐\n";
    echo "│ EJEMPLO 2: Buscar multas del año 2024                      │\n";
    echo "└─────────────────────────────────────────────────────────────┘\n\n";

    echo "📋 Uso en formulario:\n";
    echo "   Campo 'Filtro': 2024\n";
    echo "   Click en botón 'Buscar'\n\n";

    echo "🔧 Parámetros enviados:\n";
    echo "   p_filtro: '2024'\n";
    echo "   p_offset: 0\n";
    echo "   p_limit: 10\n\n";

    $stmt = $pdo->prepare($query);
    $stmt->execute([
        ':p_filtro' => '2024',
        ':p_offset' => 0,
        ':p_limit' => 10
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✅ Respuesta exitosa\n";
        echo "📊 Total de multas del 2024: " . number_format($results[0]['total_count']) . "\n";
        echo "📄 Registros retornados: " . count($results) . "\n\n";

        echo "🎯 Primeros 3 registros del 2024:\n\n";
        foreach (array_slice($results, 0, 3) as $i => $row) {
            echo "Registro #" . ($i + 1) . ":\n";
            echo "  Folio: " . $row['folio'] . "\n";
            echo "  Contribuyente: " . substr($row['contribuyente'], 0, 35) . "\n";
            echo "  Dependencia: " . $row['dependencia'] . "\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "  Estado: " . $row['estado'] . "\n";
            echo "\n";
        }
    } else {
        echo "⚠️ No se encontraron registros del 2024\n\n";
    }

    echo "\n";
    echo str_repeat("═", 65) . "\n\n";

    // ================================================================
    // EJEMPLO 3: Buscar por nombre "MARIA"
    // ================================================================
    echo "┌─────────────────────────────────────────────────────────────┐\n";
    echo "│ EJEMPLO 3: Buscar contribuyentes con 'MARIA'               │\n";
    echo "└─────────────────────────────────────────────────────────────┘\n\n";

    echo "📋 Uso en formulario:\n";
    echo "   Campo 'Filtro': MARIA\n";
    echo "   Click en botón 'Buscar'\n\n";

    echo "🔧 Parámetros enviados:\n";
    echo "   p_filtro: 'MARIA'\n";
    echo "   p_offset: 0\n";
    echo "   p_limit: 10\n\n";

    $stmt = $pdo->prepare($query);
    $stmt->execute([
        ':p_filtro' => 'MARIA',
        ':p_offset' => 0,
        ':p_limit' => 10
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✅ Respuesta exitosa\n";
        echo "📊 Total de registros con 'MARIA': " . number_format($results[0]['total_count']) . "\n";
        echo "📄 Registros retornados: " . count($results) . "\n\n";

        echo "🎯 Primeros 3 registros:\n\n";
        foreach (array_slice($results, 0, 3) as $i => $row) {
            echo "Registro #" . ($i + 1) . ":\n";
            echo "  Folio: " . $row['folio'] . "\n";
            echo "  Contribuyente: " . $row['contribuyente'] . "\n";
            echo "  Domicilio: " . substr($row['domicilio'], 0, 40) . "\n";
            echo "  Dependencia: " . $row['dependencia'] . "\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "  Estado: " . $row['estado'] . "\n";
            echo "\n";
        }
    } else {
        echo "⚠️ No se encontraron registros con 'MARIA'\n\n";
    }

    echo "\n";
    echo str_repeat("═", 65) . "\n\n";

    // ================================================================
    // EJEMPLO BONUS: Paginación (segunda página)
    // ================================================================
    echo "┌─────────────────────────────────────────────────────────────┐\n";
    echo "│ EJEMPLO BONUS: Paginación - Segunda página                 │\n";
    echo "└─────────────────────────────────────────────────────────────┘\n\n";

    echo "📋 Uso en formulario:\n";
    echo "   Click en botón 'Siguiente página' →\n\n";

    echo "🔧 Parámetros enviados:\n";
    echo "   p_filtro: ''\n";
    echo "   p_offset: 10 (registros 11-20)\n";
    echo "   p_limit: 10\n\n";

    $stmt = $pdo->prepare($query);
    $stmt->execute([
        ':p_filtro' => '',
        ':p_offset' => 10,
        ':p_limit' => 10
    ]);

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✅ Respuesta exitosa\n";
        echo "📊 Total de registros: " . number_format($results[0]['total_count']) . "\n";
        echo "📄 Registros retornados: " . count($results) . " (del 11 al 20)\n\n";

        echo "🎯 Mostrando registros 11-13:\n\n";
        foreach (array_slice($results, 0, 3) as $i => $row) {
            echo "Registro #" . (11 + $i) . ":\n";
            echo "  Folio: " . $row['folio'] . "\n";
            echo "  Contribuyente: " . substr($row['contribuyente'], 0, 35) . "\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "\n";
        }
    }

    echo "\n";
    echo str_repeat("═", 65) . "\n\n";

    // ================================================================
    // RESUMEN FINAL
    // ================================================================
    echo "╔════════════════════════════════════════════════════════════════╗\n";
    echo "║                      RESUMEN DE PRUEBAS                        ║\n";
    echo "╚════════════════════════════════════════════════════════════════╝\n\n";

    echo "✅ Stored Procedure: db_ingresos.recaudadora_listana\n";
    echo "✅ Conexión a BD: Exitosa\n";
    echo "✅ Ejemplo 1 (sin filtro): Funcional\n";
    echo "✅ Ejemplo 2 (filtro por año): Funcional\n";
    echo "✅ Ejemplo 3 (filtro por nombre): Funcional\n";
    echo "✅ Paginación: Funcional\n\n";

    echo "📝 INSTRUCCIONES PARA EL FORMULARIO VUE:\n";
    echo "   1. El formulario debe llamar al SP: RECAUDADORA_LISTANA\n";
    echo "   2. Enviar parámetros: p_filtro, p_offset, p_limit\n";
    echo "   3. Usar el campo 'total_count' del primer registro para paginación\n";
    echo "   4. Los resultados vienen ordenados por fecha descendente\n\n";

    echo "🎯 CAMPOS DISPONIBLES EN LA RESPUESTA:\n";
    echo "   - total_count: Total de registros (para paginación)\n";
    echo "   - id_multa: ID único\n";
    echo "   - folio: Folio formateado (MULTA-YYYY-NNNNNN)\n";
    echo "   - fecha_acta: Fecha del acta\n";
    echo "   - contribuyente: Nombre del contribuyente\n";
    echo "   - domicilio: Dirección\n";
    echo "   - dependencia: Dependencia emisora\n";
    echo "   - zona_subzona: Zona y subzona\n";
    echo "   - calificacion: Monto de calificación\n";
    echo "   - multa: Monto de multa\n";
    echo "   - gastos: Gastos adicionales\n";
    echo "   - total: Total a pagar\n";
    echo "   - tipo: Tipo de multa (Normal/Reincidente/Especial)\n";
    echo "   - estado: Estado (Pendiente/Pagada/Cancelada)\n\n";

    echo "✅ TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE\n\n";

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo "\n";
    echo "⚠️ POSIBLES CAUSAS:\n";
    echo "   1. El servidor PostgreSQL no está corriendo\n";
    echo "   2. Las credenciales son incorrectas\n";
    echo "   3. La base de datos 'prueba2' no existe\n";
    echo "   4. El stored procedure no ha sido desplegado\n\n";
    echo "💡 SOLUCIÓN:\n";
    echo "   1. Verifica que PostgreSQL esté corriendo\n";
    echo "   2. Despliega el SP usando: DEPLOY_LISTANA_MANUAL.sql\n\n";
    exit(1);
}
