<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file" />
      </div>
      <div class="module-view-info">
        <h1>Registro</h1>
        <p>Registrar información en el sistema</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Registro (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="8"
                v-model="jsonPayload"
                placeholder='{"campo1": "valor1", "campo2": "valor2"}'
              ></textarea>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" v-if="!loading" />
              <span v-if="loading">Guardando...</span>
              <span v-else>Guardar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>Éxito:</strong> {{ success }}
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="(value, key) in resultado[0]" :key="key">
                    {{ key }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultado" :key="idx" class="row-hover">
                  <td v-for="(value, key) in row" :key="key">
                    {{ value }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REG'
const { loading, execute } = useApi()

const jsonPayload = ref('')
const resultado = ref(null)
const success = ref(null)
const error = ref(null)

async function guardar() {
  error.value = null
  success.value = null
  resultado.value = null

  try {
    // Validar JSON
    let jsonData
    try {
      jsonData = JSON.parse(jsonPayload.value)
    } catch (e) {
      error.value = 'El JSON no es válido: ' + e.message
      return
    }

    console.log('🔍 Ejecutando SP:', OP)
    console.log('🔍 Datos:', jsonData)

    // Enviar parámetros en el formato correcto
    const params = [
      {
        nombre: 'p_registro',
        valor: jsonPayload.value,
        tipo: 'string'
      }
    ]

    const data = await execute(OP, BASE_DB, params)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    resultado.value = arr
    success.value = 'Registro guardado exitosamente'

  } catch (e) {
    error.value = e.message || 'Error al guardar el registro'
    console.error('❌ Error:', e)
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
  success.value = null
  error.value = null
}
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  margin-bottom: 15px;
}

.form-group.full-width {
  width: 100%;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
  display: block;
}

.municipal-form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-family: monospace;
  font-size: 13px;
  resize: vertical;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.municipal-table th {
  font-weight: bold;
  color: white;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.table-responsive {
  overflow-x: auto;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}
</style>
