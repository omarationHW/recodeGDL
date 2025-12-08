<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gears" /></div>
      <div class="module-view-info"><h1>Ejecutor de Procesos</h1><p>Ejecución genérica de comandos</p></div>
    </div>
    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Parámetros de Entrada</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Comando / Parámetros (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="10"
                v-model="jsonPayload"
                placeholder='{"comando": "test", "parametros": {}}'
              ></textarea>
              <small class="form-text">Ingrese un objeto JSON válido</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="ejecutar"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading"/>
              {{ loading ? 'Ejecutando...' : 'Ejecutar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="trash"/>
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado -->
      <div class="municipal-card" v-if="result">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle"/> Resultado de la Ejecución</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Error -->
          <div v-if="result.error" class="alert-danger">
            <font-awesome-icon icon="exclamation-circle"/>
            <strong>Error:</strong> {{ result.error }}
          </div>

          <!-- Resultado exitoso -->
          <div v-else-if="Array.isArray(result) && result.length > 0">
            <div class="result-summary">
              <div class="summary-item status-success">
                <font-awesome-icon icon="check-circle"/>
                <div>
                  <strong>Estado:</strong>
                  <span>{{ result[0].status || 'success' }}</span>
                </div>
              </div>
              <div class="summary-item">
                <font-awesome-icon icon="info-circle"/>
                <div>
                  <strong>Mensaje:</strong>
                  <span>{{ result[0].message || 'Proceso completado' }}</span>
                </div>
              </div>
              <div class="summary-item">
                <font-awesome-icon icon="clock"/>
                <div>
                  <strong>Hora de Ejecución:</strong>
                  <span>{{ formatTime(result[0].execution_time) }}</span>
                </div>
              </div>
              <div class="summary-item">
                <font-awesome-icon icon="user"/>
                <div>
                  <strong>Usuario:</strong>
                  <span>{{ result[0].user_info || 'N/A' }}</span>
                </div>
              </div>
            </div>

            <!-- Parámetros recibidos -->
            <div class="params-section" v-if="result[0].received_params">
              <h6><font-awesome-icon icon="terminal"/> Parámetros Recibidos</h6>
              <div class="params-content">
                <pre>{{ JSON.stringify(result[0].received_params, null, 2) }}</pre>
              </div>
            </div>

            <!-- JSON Raw (colapsable) -->
            <details class="json-raw">
              <summary><font-awesome-icon icon="code"/> Ver JSON Completo</summary>
              <pre>{{ JSON.stringify(result, null, 2) }}</pre>
            </details>
          </div>

          <!-- Resultado sin formato específico -->
          <div v-else class="result-box">
            <pre>{{ JSON.stringify(result, null, 2) }}</pre>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_FRMEJE'
const jsonPayload = ref('')
const result = ref(null)

async function ejecutar() {
  try {
    // Validar JSON
    let parsedPayload
    try {
      parsedPayload = JSON.parse(jsonPayload.value)
    } catch (e) {
      result.value = { error: 'JSON inválido: ' + e.message }
      return
    }

    const params = [
      { nombre: 'p_params', tipo: 'json', valor: JSON.stringify(parsedPayload) }
    ]

    const response = await execute(OP, BASE_DB, params)

    if (response?.result) {
      result.value = response.result
    } else {
      result.value = response
    }
  } catch (e) {
    result.value = { error: e?.message || 'Error desconocido' }
  }
}

function limpiar() {
  jsonPayload.value = ''
  result.value = null
}

function formatTime(timestamp) {
  if (!timestamp) return 'N/A'
  return new Date(timestamp).toLocaleString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}
</script>

<style scoped>
.form-group.full-width {
  width: 100%;
}

.municipal-form-control {
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
}

.form-text {
  color: #6c757d;
  font-size: 0.85rem;
  margin-top: 4px;
  display: block;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  margin-left: 10px;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 16px;
  color: #721c24;
}

.alert-danger svg {
  margin-right: 8px;
}

.result-box {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  padding: 16px;
}

.result-box pre {
  margin: 0;
  font-family: 'Courier New', monospace;
  font-size: 0.85rem;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.result-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #dee2e6;
}

.summary-item svg {
  font-size: 1.5rem;
  color: #6c757d;
}

.summary-item.status-success {
  background: #d4edda;
  border-left-color: #28a745;
}

.summary-item.status-success svg {
  color: #28a745;
}

.summary-item div {
  flex: 1;
}

.summary-item strong {
  display: block;
  color: #495057;
  font-size: 0.85rem;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.summary-item span {
  display: block;
  color: #212529;
  font-size: 1rem;
  font-weight: 600;
}

.params-section {
  margin-bottom: 24px;
}

.params-section h6 {
  margin: 0 0 12px 0;
  padding: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 600;
}

.params-section h6 svg {
  margin-right: 8px;
}

.params-content {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  padding: 16px;
  overflow-x: auto;
}

.params-content pre {
  margin: 0;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
  color: #212529;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.json-raw {
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  overflow: hidden;
}

.json-raw summary {
  padding: 14px 16px;
  background: #f8f9fa;
  cursor: pointer;
  font-weight: 600;
  color: #495057;
  user-select: none;
  transition: all 0.2s ease;
}

.json-raw summary:hover {
  background: #e9ecef;
  color: #212529;
}

.json-raw summary svg {
  margin-right: 8px;
  color: #667eea;
}

.json-raw pre {
  margin: 0;
  padding: 16px;
  font-family: 'Courier New', monospace;
  font-size: 0.85rem;
  background: #2d2d2d;
  color: #f8f9fa;
  overflow-x: auto;
  white-space: pre;
}

.json-raw[open] summary {
  border-bottom: 1px solid #dee2e6;
}
</style>

