<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-shield" /></div>
      <div class="module-view-info">
        <h1>FRM Pol</h1>
        <p>Gestión de pólizas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Parámetros de Entrada</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Parámetros (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="8"
                v-model="jsonPayload"
                placeholder='{"parametro": "valor"}'
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
          <h5><font-awesome-icon icon="check-circle"/> Resultado del Proceso</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Error -->
          <div v-if="result.error" class="alert-danger">
            <font-awesome-icon icon="exclamation-circle"/>
            <strong>Error:</strong> {{ result.error }}
          </div>

          <!-- Resultado exitoso -->
          <div v-else-if="Array.isArray(result) && result.length > 0">
            <!-- Resumen del estado -->
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
                  <strong>Fecha de Proceso:</strong>
                  <span>{{ formatDateTime(result[0].fecha_proceso) }}</span>
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

            <!-- Información de la Póliza -->
            <div class="poliza-section" v-if="result[0].poliza_info">
              <h6><font-awesome-icon icon="file-invoice"/> Información de la Póliza</h6>
              <div class="poliza-grid">
                <div class="poliza-item highlight">
                  <div class="poliza-label">Folio de Póliza</div>
                  <div class="poliza-value folio">{{ getPolizaValue('folio_poliza') }}</div>
                </div>
                <div class="poliza-item">
                  <div class="poliza-label">Fecha</div>
                  <div class="poliza-value">{{ getPolizaValue('fecha') }}</div>
                </div>
                <div class="poliza-item">
                  <div class="poliza-label">Recaudadora</div>
                  <div class="poliza-value">{{ getPolizaValue('recaudadora') }}</div>
                </div>
                <div class="poliza-item">
                  <div class="poliza-label">Tipo</div>
                  <div class="poliza-value">{{ getPolizaValue('tipo') }}</div>
                </div>
                <div class="poliza-item amount">
                  <div class="poliza-label">Total Importe</div>
                  <div class="poliza-value total">{{ formatCurrency(getPolizaValue('total_importe')) }}</div>
                </div>
                <div class="poliza-item">
                  <div class="poliza-label">Número de Registros</div>
                  <div class="poliza-value records">{{ getPolizaValue('numero_registros') }}</div>
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

            <!-- JSON completo colapsable -->
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
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'frmpol'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'FRM Pol'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'frmpol'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'FRM Pol'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_FRMPOL'
const SCHEMA = 'publico'
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

    const response = await execute(OP, BASE_DB, params, '', null, SCHEMA)

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

function formatDateTime(timestamp) {
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

function formatCurrency(value) {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}

function getPolizaValue(key) {
  if (!result.value || !result.value[0] || !result.value[0].poliza_info) return 'N/A'
  const polizaInfo = result.value[0].poliza_info

  // Si es string JSON, parsearlo
  if (typeof polizaInfo === 'string') {
    try {
      const parsed = JSON.parse(polizaInfo)
      return parsed[key] || 'N/A'
    } catch (e) {
      return 'N/A'
    }
  }

  // Si es objeto, acceder directamente
  return polizaInfo[key] || 'N/A'
}
</script>

