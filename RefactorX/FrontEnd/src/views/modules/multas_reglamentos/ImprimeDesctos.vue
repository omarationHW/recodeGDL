<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Imprime Descuentos</h1>
        <p>Generación e impresión de reportes de descuentos</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Datos de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave de Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                placeholder="Ej: CTA-001-2025"
                @keyup.enter="generar"
              />
              <small class="form-text">Ingrese la clave de cuenta</small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año (Ejercicio)</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="2025"
                @keyup.enter="generar"
              />
              <small class="form-text">Año del ejercicio fiscal</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta || !filters.ejercicio"
              @click="generar"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'print'" :spin="loading"/>
              {{ loading ? 'Procesando...' : 'Generar Reporte' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado -->
      <div class="municipal-card" v-if="result">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-pdf"/> Resultado</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Error genérico -->
          <div v-if="result.error" class="alert-danger">
            <font-awesome-icon icon="times-circle"/>
            <strong>Error:</strong> {{ result.error }}
          </div>

          <!-- Resultado del SP -->
          <div v-else-if="Array.isArray(result) && result.length > 0">
            <!-- Error de validación del SP -->
            <div v-if="result[0].status === 'error'" class="alert-danger">
              <font-awesome-icon icon="times-circle"/>
              <strong>{{ result[0].mensaje }}</strong>
            </div>
            <!-- Éxito -->
            <div v-else class="alert-success">
              <font-awesome-icon icon="check-circle"/>
              <strong>{{ result[0].mensaje || 'Reporte generado exitosamente' }}</strong>
              <div class="result-details" v-if="result[0].folio_reporte">
                <p>Folio del Reporte: <strong>{{ result[0].folio_reporte }}</strong></p>
                <p>Clave de Cuenta: <strong>{{ filters.cuenta }}</strong></p>
                <p>Ejercicio: <strong>{{ filters.ejercicio }}</strong></p>
                <p v-if="result[0].fecha_generacion">Fecha de Generación: <strong>{{ result[0].fecha_generacion }}</strong></p>
                <p v-if="result[0].total_descuentos">Total de Descuentos: <strong>{{ result[0].total_descuentos }}</strong></p>
                <p v-if="result[0].monto_total">Monto Total: <strong>{{ formatCurrency(result[0].monto_total) }}</strong></p>
              </div>
            </div>
          </div>

          <!-- Resultado genérico -->
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

const BASE_DB = 'multas_reglamentos'
const OP_REPORTE = 'RECAUDADORA_IMPRIME_DESCTOS'
const SCHEMA = 'publico'

const { loading, execute } = useApi()

const filters = ref({
  cuenta: '',
  ejercicio: new Date().getFullYear()
})
const result = ref(null)

async function generar() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const response = await execute(OP_REPORTE, BASE_DB, params, '', null, SCHEMA)
    if (response?.result) {
      result.value = response.result
    } else {
      result.value = response
    }
  } catch (e) {
    result.value = { error: e?.message || 'Error desconocido' }
  }
}

function formatCurrency(value) {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}
</script>

<style scoped>
.form-text {
  color: #6c757d;
  font-size: 0.85rem;
  margin-top: 4px;
  display: block;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 8px;
  padding: 16px;
  color: #155724;
}

.alert-success svg {
  margin-right: 8px;
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

.result-details {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #c3e6cb;
}

.result-details p {
  margin: 4px 0;
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
</style>
