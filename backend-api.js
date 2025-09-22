const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Configuración de la base de datos PostgreSQL (usando credenciales del .env)
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

// Endpoint de salud
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'Backend API Server',
    port: PORT
  });
});

// Endpoint genérico para ejecutar stored procedures
app.post('/api/generic', async (req, res) => {
  const { eRequest } = req.body;
  const { Operacion, Parametros = [] } = eRequest;

  console.log(`📨 POST /api/generic - Operacion: ${Operacion}`);

  try {
    console.log(`✅ Conexión a DB exitosa`);

    // Procesar parámetros - extraer valores si son objetos con formato {nombre, valor}
    const processedParams = Parametros.map(param => {
      if (param && typeof param === 'object' && 'valor' in param) {
        return param.valor;
      }
      return param;
    });

    // Convertir nombre de operación a mayúsculas para compatibilidad con stored procedures
    const operacionMayuscula = Operacion.toUpperCase();

    // Construir la consulta SQL
    const placeholders = processedParams.map((_, index) => `$${index + 1}`).join(',');
    const query = `SELECT * FROM informix.${operacionMayuscula}(${placeholders})`;

    console.log(`🔧 Query: ${query}`);
    console.log(`📋 Params:`, processedParams);

    const result = await pool.query(query, processedParams);

    console.log(`✅ SP ${Operacion} ejecutado exitosamente. Filas: ${result.rows.length}`);

    res.json({
      success: true,
      data: result.rows,
      recordCount: result.rows.length
    });

  } catch (error) {
    console.error(`❌ Error: ${error.message}`);

    res.status(500).json({
      success: false,
      error: error.message,
      operation: Operacion
    });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Backend API Server ejecutándose en:`);
  console.log(`📡 API Server: http://localhost:${PORT}`);
  console.log(`🌐 Health: http://localhost:${PORT}/health`);
  console.log(`📋 API: http://localhost:${PORT}/api/generic`);
  console.log(`✅ Configurado para base de datos PostgreSQL`);
});

// Manejo de errores no capturados
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});