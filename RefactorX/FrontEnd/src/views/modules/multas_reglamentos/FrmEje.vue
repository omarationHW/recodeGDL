<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gears" /></div>
      <div class="module-view-info"><h1>Ejecutor de Procesos</h1><p>Ejecución genérica de comandos</p></div>
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
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'FrmEje'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Ejecutor de Procesos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'FrmEje'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Ejecutor de Procesos'"
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
const OP = 'RECAUDADORA_FRMEJE'
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


