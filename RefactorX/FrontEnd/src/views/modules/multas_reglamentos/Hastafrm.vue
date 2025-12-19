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
            <div v-else>
              <div class="alert-success">
                <font-awesome-icon icon="check-circle"/>
                <strong>{{ result[0].mensaje || 'Operación completada exitosamente' }}</strong>
                <div class="result-details" v-if="result[0].total_registros">
                  <p>Total de registros: <strong>{{ result[0].total_registros }}</strong></p>
                  <p>Periodo: <strong>{{ filters.desde }}</strong> a <strong>{{ filters.hasta }}</strong></p>
                </div>
              </div>

              <!-- Tabla de registros -->
              <div class="table-container" v-if="result[0].total_registros > 0">
                <table class="municipal-table">
                  <thead>
                    <tr>
                      <th>Fecha Emisión</th>
                      <th>Criterio</th>
                      <th>Recaud</th>
                      <th>Urb/Rus</th>
                      <th>Cuenta Inicio</th>
                      <th>Cuenta Final</th>
                      <th>Zona</th>
                      <th>Subzona</th>
                      <th>Monto Mín</th>
                      <th>Monto Máx</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(registro, index) in paginatedResults" :key="index">
                      <td>{{ formatDate(registro.fecha_emision) }}</td>
                      <td>{{ registro.criterio }}</td>
                      <td>{{ registro.recaud }}</td>
                      <td>{{ registro.urbrus }}</td>
                      <td>{{ registro.cuenta_inicio }}</td>
                      <td>{{ registro.cuenta_final }}</td>
                      <td>{{ registro.zona }}</td>
                      <td>{{ registro.subzona }}</td>
                      <td class="text-right">{{ formatCurrency(registro.monto_min) }}</td>
                      <td class="text-right">{{ formatCurrency(registro.monto_max) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <!-- Paginación -->
              <div class="pagination-container" v-if="result[0].total_registros > itemsPerPage">
                <div class="pagination-info">
                  Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ result[0].total_registros }} registros
                </div>
                <div class="pagination-controls">
                  <button
                    class="pagination-btn"
                    :disabled="currentPage === 1"
                    @click="currentPage = 1">
                    <font-awesome-icon icon="angles-left" />
                  </button>
                  <button
                    class="pagination-btn"
                    :disabled="currentPage === 1"
                    @click="currentPage--">
                    <font-awesome-icon icon="angle-left" />
                  </button>

                  <span class="pagination-page">
                    Página {{ currentPage }} de {{ totalPages }}
                  </span>

                  <button
                    class="pagination-btn"
                    :disabled="currentPage === totalPages"
                    @click="currentPage++">
                    <font-awesome-icon icon="angle-right" />
                  </button>
                  <button
                    class="pagination-btn"
                    :disabled="currentPage === totalPages"
                    @click="currentPage = totalPages">
                    <font-awesome-icon icon="angles-right" />
                  </button>
                </div>
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
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_EJEC = 'RECAUDADORA_HASTAFRM'

const { loading, execute } = useApi()

const filters = ref({ desde: '', hasta: '' })
const result = ref(null)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed properties para paginación
const totalPages = computed(() => {
  if (!result.value || result.value.length === 0) return 0
  return Math.ceil(result.value[0].total_registros / itemsPerPage.value)
})

const startIndex = computed(() => {
  return (currentPage.value - 1) * itemsPerPage.value
})

const endIndex = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  if (!result.value || result.value.length === 0) return 0
  return Math.min(end, result.value[0].total_registros)
})

const paginatedResults = computed(() => {
  if (!result.value || result.value.length === 0) return []
  const start = startIndex.value
  const end = start + itemsPerPage.value
  return result.value.slice(start, end)
})

async function ejecutar() {
  const params = [
    { nombre: 'p_fecha_desde', tipo: 'date', valor: String(filters.value.desde || '') },
    { nombre: 'p_fecha_hasta', tipo: 'date', valor: String(filters.value.hasta || '') }
  ]
  try {
    const response = await execute(OP_EJEC, BASE_DB, params)
    if (response?.result) {
      result.value = response.result
      currentPage.value = 1 // Resetear a la primera página cuando se ejecuta una nueva búsqueda
    } else {
      result.value = response
    }
  } catch (e) {
    result.value = { error: e?.message || 'Error desconocido' }
  }
}

function formatDate(date) {
  if (!date) return ''
  const d = new Date(date + 'T00:00:00')
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

function formatCurrency(value) {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
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

.table-container {
  margin-top: 20px;
  overflow-x: auto;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  font-size: 0.9rem;
}

.municipal-table thead {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.municipal-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.5px;
  border-bottom: 2px solid #5568d3;
}

.municipal-table tbody tr {
  border-bottom: 1px solid #e9ecef;
  transition: background-color 0.2s ease;
}

.municipal-table tbody tr:hover {
  background-color: #f8f9fa;
}

.municipal-table tbody tr:last-child {
  border-bottom: none;
}

.municipal-table tbody td {
  padding: 12px 16px;
  color: #495057;
}

.municipal-table .text-right {
  text-align: right;
}

.municipal-table tbody tr:nth-child(even) {
  background-color: #f8f9fa;
}

.municipal-table tbody tr:nth-child(even):hover {
  background-color: #e9ecef;
}

@media (max-width: 768px) {
  .municipal-table {
    font-size: 0.8rem;
  }

  .municipal-table thead th,
  .municipal-table tbody td {
    padding: 8px 12px;
  }
}

/* Paginación */
.pagination-container {
  margin-top: 20px;
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8f9fa;
  border-radius: 8px;
  border-top: 2px solid #dee2e6;
}

.pagination-info {
  color: #495057;
  font-size: 0.9rem;
  font-weight: 500;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #667eea;
  font-size: 14px;
}

.pagination-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  background: #f8f9fa;
}

.pagination-page {
  padding: 0 16px;
  color: #495057;
  font-weight: 600;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
    gap: 12px;
  }

  .pagination-info {
    font-size: 0.8rem;
  }

  .pagination-btn {
    width: 32px;
    height: 32px;
    font-size: 12px;
  }

  .pagination-page {
    padding: 0 12px;
    font-size: 0.8rem;
  }
}
</style>

