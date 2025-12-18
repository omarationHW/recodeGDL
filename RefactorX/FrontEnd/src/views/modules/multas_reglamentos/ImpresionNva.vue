<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Impresión Nueva</h1>
        <p>Generación de impresión de documentos</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Datos de Impresión</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave de Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="imprimir"
              />
              <small class="form-text">Ingrese la clave de cuenta para generar la impresión</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta"
              @click="imprimir"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'print'" :spin="loading"/>
              {{ loading ? 'Procesando...' : 'Generar Impresión' }}
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
              <strong>{{ result[0].mensaje || 'Impresión generada exitosamente' }}</strong>

              <!-- Detalles de la Impresión -->
              <div class="result-details" v-if="result[0].folio_impresion">
                <h6><font-awesome-icon icon="file-pdf"/> Información de la Impresión</h6>

                <div class="detail-grid">
                  <div class="detail-item">
                    <span class="detail-label">Folio:</span>
                    <span class="detail-value">{{ result[0].folio_impresion }}</span>
                  </div>

                  <div class="detail-item">
                    <span class="detail-label">Clave de Cuenta:</span>
                    <span class="detail-value">{{ result[0].clave_cuenta || filters.cuenta }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].fecha_generacion">
                    <span class="detail-label">Fecha de Generación:</span>
                    <span class="detail-value">{{ formatDate(result[0].fecha_generacion) }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].tipo_documento">
                    <span class="detail-label">Tipo de Documento:</span>
                    <span class="detail-value">{{ result[0].tipo_documento }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].numero_paginas">
                    <span class="detail-label">Número de Páginas:</span>
                    <span class="detail-value">{{ result[0].numero_paginas }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].formato">
                    <span class="detail-label">Formato:</span>
                    <span class="detail-value">{{ result[0].formato }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].estado">
                    <span class="detail-label">Estado:</span>
                    <span class="detail-value">
                      <span class="badge-success">{{ result[0].estado }}</span>
                    </span>
                  </div>

                  <div class="detail-item" v-if="result[0].periodo">
                    <span class="detail-label">Periodo:</span>
                    <span class="detail-value">{{ result[0].periodo }}</span>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].contribuyente">
                  <h6><font-awesome-icon icon="user"/> Información del Contribuyente</h6>
                  <div class="detail-grid">
                    <div class="detail-item">
                      <span class="detail-label">Contribuyente:</span>
                      <span class="detail-value">{{ result[0].contribuyente }}</span>
                    </div>

                    <div class="detail-item" v-if="result[0].monto_total !== null && result[0].monto_total !== undefined">
                      <span class="detail-label">Monto Total:</span>
                      <span class="detail-value">{{ formatCurrency(result[0].monto_total) }}</span>
                    </div>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].observaciones">
                  <h6><font-awesome-icon icon="info-circle"/> Observaciones</h6>
                  <p class="observaciones-text">{{ result[0].observaciones }}</p>
                </div>
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

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_IMPRESIONNVA'
const SCHEMA = 'publico'

const filters = ref({ cuenta: '' })
const result = ref(null)

async function imprimir() {
  const params = [
    {
      nombre: 'p_datos',
      tipo: 'string',
      valor: JSON.stringify({
        clave_cuenta: filters.value.cuenta
      })
    }
  ]
  try {
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

function formatCurrency(value) {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
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
  margin-top: 16px;
}

.result-details h6 {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 12px;
  color: #155724;
  display: flex;
  align-items: center;
  gap: 8px;
}

.detail-section {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #c3e6cb;
}

.detail-section:first-child {
  margin-top: 0;
  padding-top: 0;
  border-top: none;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
  margin-bottom: 8px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 0.85rem;
  font-weight: 500;
  color: #155724;
  opacity: 0.8;
}

.detail-value {
  font-size: 0.95rem;
  font-weight: 600;
  color: #155724;
}

.badge-success {
  display: inline-block;
  padding: 4px 12px;
  background-color: #28a745;
  color: white;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.observaciones-text {
  margin: 8px 0 0 0;
  padding: 12px;
  background: rgba(212, 237, 218, 0.3);
  border-radius: 6px;
  font-size: 0.9rem;
  color: #155724;
  line-height: 1.5;
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
