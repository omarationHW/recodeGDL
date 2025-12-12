<?php
/**
 * Script de prueba para el módulo de cambio de contraseña
 * Ejecuta diferentes casos de prueba contra el stored procedure
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$username = 'refact';
$password = 'FF)-BQk2';

$dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
$pdo = new PDO($dsn, $username, $password);
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║           PRUEBA DEL MÓDULO DE CAMBIO DE CONTRASEÑA                      ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

// Función auxiliar para probar
function testCambioPassword($pdo, $usuario, $password, $descripcion) {
    echo "┌─────────────────────────────────────────────────────────────────────────┐\n";
    echo "│ TEST: " . str_pad($descripcion, 68) . "│\n";
    echo "├─────────────────────────────────────────────────────────────────────────┤\n";
    echo "│ Usuario:  " . str_pad($usuario, 63) . "│\n";
    echo "│ Password: " . str_pad(str_repeat('*', strlen($password)), 63) . "│\n";
    echo "└─────────────────────────────────────────────────────────────────────────┘\n";

    try {
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sfrm_chgpass(?, ?)");
        $stmt->execute([$usuario, $password]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result['success']) {
            echo "✅ ÉXITO\n";
            echo "   Mensaje: " . $result['message'] . "\n";
        } else {
            echo "❌ ERROR\n";
            echo "   Mensaje: " . $result['message'] . "\n";
        }
    } catch (Exception $e) {
        echo "❌ EXCEPCIÓN\n";
        echo "   Error: " . $e->getMessage() . "\n";
    }

    echo "\n";
}

// ============================================================================
// CASOS DE PRUEBA
// ============================================================================

// Test 1: Campos vacíos
testCambioPassword($pdo, '', '', 'Ambos campos vacíos');

// Test 2: Usuario vacío
testCambioPassword($pdo, '', 'test123456', 'Usuario vacío');

// Test 3: Password vacío
testCambioPassword($pdo, 'admin', '', 'Password vacío');

// Test 4: Password muy corto
testCambioPassword($pdo, 'admin', '12345', 'Password de 5 caracteres (mínimo 6)');

// Test 5: Usuario muy corto (no existe)
testCambioPassword($pdo, 'ab', 'test123456', 'Usuario de 2 caracteres (simulado como no existente)');

// Test 6: Cambio exitoso con usuario admin
testCambioPassword($pdo, 'admin', 'nuevapass123', 'Usuario: admin - Password válido');

// Test 7: Cambio exitoso con otro usuario
testCambioPassword($pdo, 'operador', 'secreto2024', 'Usuario: operador - Password válido');

// Test 8: Cambio exitoso con usuario largo
testCambioPassword($pdo, 'administrador_sistema', 'MiPasswordSeguro123!', 'Usuario largo - Password seguro');

// Test 9: Password en el límite (6 caracteres)
testCambioPassword($pdo, 'test', '123456', 'Password de exactamente 6 caracteres');

// Test 10: Password muy largo
testCambioPassword($pdo, 'usuario', 'EstoEsUnPasswordMuyLargoParaProbarElSistema123456789!', 'Password muy largo (debería funcionar)');

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║                         PRUEBAS COMPLETADAS                               ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "📝 NOTAS:\n";
echo "   - El SP actualmente usa lógica de simulación\n";
echo "   - Usuarios con 3+ caracteres son considerados válidos\n";
echo "   - Passwords deben tener mínimo 6 caracteres\n";
echo "   - Para producción, conectar con el sistema real de autenticación\n\n";

echo "🌐 CÓMO PROBAR EN EL NAVEGADOR:\n";
echo "   1. Asegúrate que el backend esté corriendo:\n";
echo "      cd RefactorX/BackEnd && php artisan serve\n\n";
echo "   2. Asegúrate que el frontend esté corriendo:\n";
echo "      cd RefactorX/FrontEnd && npm run dev\n\n";
echo "   3. Abre en el navegador:\n";
echo "      http://localhost:3000\n\n";
echo "   4. Navega al módulo 'Cambio de Password' en multas_reglamentos\n\n";
echo "   5. Prueba con:\n";
echo "      - Usuario: admin\n";
echo "      - Password: test123456\n\n";
