<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-days" /></div>
      <div class="module-view-info">
        <h1>Hasta Formulario</h1>
        <p>Parámetros de operación por fecha</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Desde</label>
              <input type="date" class="municipal-form-control" v-model="filters.desde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Hasta</label>
              <input type="date" class="municipal-form-control" v-model="filters.hasta" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="ejecutar">
              <font-awesome-icon :icon="loading ? 'spinner' : 'check'" :spin="loading" />
              {{ loading ? 'Procesando...' : 'Ejecutar' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado -->
      <div class="municipal-card" v-if="result">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle"/> Resultado</h5>
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
              <strong>{{ result[0].mensaje || 'Operación completada exitosamente' }}</strong>
              <div class="result-details" v-if="result[0].registros_procesados">
                <p>Registros procesados: <strong>{{ result[0].registros_procesados }}</strong></p>
                <p>Periodo: <strong>{{ filters.desde }}</strong> a <strong>{{ filters.hasta }}</strong></p>
              </div>
            </div>
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

const BASE_DB = 'multas_reglamentos'
const OP_EJEC = 'RECAUDADORA_HASTAFRM'

const { loading, execute } = useApi()

const filters = ref({ desde: '', hasta: '' })
const result = ref(null)

async function ejecutar() {
  const params = [
    { nombre: 'p_fecha_desde', tipo: 'date', valor: String(filters.value.desde || '') },
    { nombre: 'p_fecha_hasta', tipo: 'date', valor: String(filters.value.hasta || '') }
  ]
  try {
    const response = await execute(OP_EJEC, BASE_DB, params)
    if (response?.result) {
      result.value = response.result
    } else {
      result.value = response
    }
  } catch (e) {
    result.value = { error: e?.message || 'Error desconocido' }
  }
}
</script>

<style scoped>
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

