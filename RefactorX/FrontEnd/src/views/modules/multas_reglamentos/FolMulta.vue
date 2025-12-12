<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="hashtag" /></div>
      <div class="module-view-info"><h1>Folio de Multa</h1><p>Gestión de folios</p></div>
    </div>
    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Acta</label>
              <input class="municipal-form-control" v-model="form.clave_cuenta" placeholder="Ej: 586"/>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="form.ejercicio" placeholder="Ej: 2002"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="generar">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading"/>
              {{ loading ? 'Buscando...' : 'Buscar Folio' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados en tabla -->
      <div class="municipal-card" v-if="result && !result.error">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table"/> Información del Folio ({{ result.length }} {{ result.length === 1 ? 'registro' : 'registros' }})</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Si hay resultados -->
          <div v-if="Array.isArray(result) && result.length > 0">
            <div v-for="(folio, idx) in paginatedResults" :key="idx" :class="{'mb-4': paginatedResults.length > 1}">
              <div class="table-responsive">
                <table class="folio-table">
                  <tbody>
                    <tr>
                      <th colspan="2" class="table-section-header">
                        <font-awesome-icon icon="file-alt"/> Información General
                      </th>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Folio:</strong></td>
                      <td class="value-cell folio-number">{{ folio.folio }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Número de Acta:</strong></td>
                      <td class="value-cell">{{ folio.numero_acta }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Año del Acta:</strong></td>
                      <td class="value-cell">{{ folio.axo_acta }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Estado:</strong></td>
                      <td class="value-cell">
                        <span class="badge" :class="getBadgeClass(folio.estado)">
                          {{ folio.estado }}
                        </span>
                      </td>
                    </tr>

                    <tr>
                      <th colspan="2" class="table-section-header">
                        <font-awesome-icon icon="user"/> Datos del Contribuyente
                      </th>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Nombre:</strong></td>
                      <td class="value-cell">{{ folio.nombre }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Domicilio:</strong></td>
                      <td class="value-cell">{{ folio.domicilio }}</td>
                    </tr>
                    <tr v-if="folio.actividad_giro">
                      <td class="label-cell"><strong>Actividad/Giro:</strong></td>
                      <td class="value-cell">{{ folio.actividad_giro }}</td>
                    </tr>
                    <tr v-if="folio.numero_licencia">
                      <td class="label-cell"><strong>Número de Licencia:</strong></td>
                      <td class="value-cell">{{ folio.numero_licencia }}</td>
                    </tr>

                    <tr>
                      <th colspan="2" class="table-section-header">
                        <font-awesome-icon icon="dollar-sign"/> Información Financiera
                      </th>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Importe Inicial:</strong></td>
                      <td class="value-cell amount">{{ formatCurrency(folio.importe_inicial) }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Importe a Pagar:</strong></td>
                      <td class="value-cell amount-highlight">{{ formatCurrency(folio.importe_pagar) }}</td>
                    </tr>
                    <tr v-if="folio.importe_pago && folio.importe_pago !== '0.00'">
                      <td class="label-cell"><strong>Importe Pagado:</strong></td>
                      <td class="value-cell amount-success">{{ formatCurrency(folio.importe_pago) }}</td>
                    </tr>

                    <tr>
                      <th colspan="2" class="table-section-header">
                        <font-awesome-icon icon="calendar"/> Fechas
                      </th>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Fecha de Alta:</strong></td>
                      <td class="value-cell">{{ formatDate(folio.fecha_alta) }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Fecha de Recepción:</strong></td>
                      <td class="value-cell">{{ formatDate(folio.fecha_recepcion) }}</td>
                    </tr>
                    <tr v-if="folio.fecha_pago">
                      <td class="label-cell"><strong>Fecha de Pago:</strong></td>
                      <td class="value-cell date-success">{{ formatDate(folio.fecha_pago) }}</td>
                    </tr>

                    <tr>
                      <th colspan="2" class="table-section-header">
                        <font-awesome-icon icon="map-marker-alt"/> Ubicación
                      </th>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Sector:</strong></td>
                      <td class="value-cell">{{ folio.sector }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Zona:</strong></td>
                      <td class="value-cell">{{ folio.numero_zona }}</td>
                    </tr>
                    <tr>
                      <td class="label-cell"><strong>Sub-zona:</strong></td>
                      <td class="value-cell">{{ folio.sub_zona }}</td>
                    </tr>
                    <tr v-if="folio.recaudadora">
                      <td class="label-cell"><strong>Recaudadora:</strong></td>
                      <td class="value-cell">{{ folio.recaudadora }}</td>
                    </tr>
                    <tr v-if="folio.operacion && folio.operacion !== 0">
                      <td class="label-cell"><strong>Número de Operación:</strong></td>
                      <td class="value-cell">{{ folio.operacion }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Pagination Controls -->
            <div v-if="result.length > pageSize" class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; border-top: 1px solid #dee2e6; margin-top: 1rem;">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ result.length }} registros
                </span>
              </div>
              <div class="pagination-controls" style="display: flex; gap: 0.5rem;">
                <button
                  class="btn-municipal-secondary"
                  :disabled="currentPage === 1"
                  @click="goToPage(1)"
                  style="padding: 0.5rem 0.75rem;">
                  <font-awesome-icon icon="angles-left" />
                </button>
                <button
                  class="btn-municipal-secondary"
                  :disabled="currentPage === 1"
                  @click="prevPage"
                  style="padding: 0.5rem 0.75rem;">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span style="display: flex; align-items: center; padding: 0 1rem; font-weight: 500;">
                  Página {{ currentPage }} de {{ totalPages }}
                </span>
                <button
                  class="btn-municipal-secondary"
                  :disabled="currentPage === totalPages"
                  @click="nextPage"
                  style="padding: 0.5rem 0.75rem;">
                  <font-awesome-icon icon="chevron-right" />
                </button>
                <button
                  class="btn-municipal-secondary"
                  :disabled="currentPage === totalPages"
                  @click="goToPage(totalPages)"
                  style="padding: 0.5rem 0.75rem;">
                  <font-awesome-icon icon="angles-right" />
                </button>
              </div>
            </div>
          </div>

          <!-- Si no hay resultados -->
          <div v-else-if="Array.isArray(result) && result.length === 0" class="no-results">
            <font-awesome-icon icon="exclamation-triangle" size="3x" class="text-warning"/>
            <h4>No se encontraron resultados</h4>
            <p>No existe una multa con el acta <strong>{{ form.clave_cuenta }}</strong> del año <strong>{{ form.ejercicio }}</strong></p>
          </div>

          <!-- Si hay error -->
          <div v-else class="no-results">
            <font-awesome-icon icon="times-circle" size="3x" class="text-danger"/>
            <h4>Sin datos</h4>
            <p class="text-muted">Ingrese un número de acta y año para buscar</p>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="result && result.error">
        <div class="municipal-card-body">
          <div class="alert-danger">
            <font-awesome-icon icon="exclamation-circle"/>
            <strong>Error:</strong> {{ result.error }}
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
const OP_GEN = 'RECAUDADORA_FOL_MULTA'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const form = ref({ clave_cuenta: '', ejercicio: new Date().getFullYear() })
const result = ref('')
const currentPage = ref(1)
const pageSize = ref(10)

// Computed properties para paginación
const totalPages = computed(() => {
  if (!Array.isArray(result.value)) return 0
  return Math.ceil(result.value.length / pageSize.value)
})

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)

const endIndex = computed(() => {
  if (!Array.isArray(result.value)) return 0
  const end = startIndex.value + pageSize.value
  return end > result.value.length ? result.value.length : end
})

const paginatedResults = computed(() => {
  if (!Array.isArray(result.value)) return []
  return result.value.slice(startIndex.value, endIndex.value)
})

// Funciones de paginación
function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

async function generar() {
  currentPage.value = 1 // Reset a la primera página al buscar

  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(form.value.clave_cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(form.value.ejercicio || 0) }
  ]
  try {
    const response = await execute(OP_GEN, BASE_DB, params, '', null, SCHEMA)
    console.log('📥 Respuesta de useApi:', response)

    // useApi ya extrae 'data' de eResponse, así que response = { result: [...], count: 1, debug: {...} }
    if (response?.result && Array.isArray(response.result)) {
      result.value = response.result
      console.log('✅ Datos extraídos:', result.value)
    } else if (Array.isArray(response)) {
      result.value = response
      console.log('✅ Respuesta es array directo:', result.value)
    } else {
      result.value = []
      console.log('⚠️ No se encontraron datos en response.result')
    }

    console.log('🔍 Es array?', Array.isArray(result.value), '| Longitud:', result.value?.length)
  } catch (e) {
    console.error('❌ Error:', e)
    result.value = { error: e?.message || 'Error' }
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

function formatDate(date) {
  if (!date) return 'N/A'
  return new Date(date + 'T00:00:00').toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function getBadgeClass(estado) {
  const classes = {
    'PAGADO': 'badge-success',
    'ACTIVO': 'badge-warning',
    'CANCELADO': 'badge-danger',
    'PENDIENTE': 'badge-info'
  }
  return classes[estado] || 'badge-secondary'
}
</script>

<style scoped>
.folio-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.folio-table tbody tr {
  border-bottom: 1px solid #e9ecef;
}

.folio-table tbody tr:last-child {
  border-bottom: none;
}

.folio-table tbody tr:hover:not(.table-section-header) {
  background-color: #f8f9fa;
}

.table-section-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 12px 16px;
  font-size: 1rem;
  font-weight: 600;
  text-align: left;
}

.table-section-header svg {
  margin-right: 8px;
}

.label-cell {
  padding: 12px 16px;
  width: 35%;
  color: #495057;
  background-color: #f8f9fa;
  font-size: 0.95rem;
}

.value-cell {
  padding: 12px 16px;
  color: #212529;
  font-size: 0.95rem;
}

.folio-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: #667eea;
}

.amount {
  color: #495057;
  font-weight: 600;
  font-size: 1.1rem;
}

.amount-highlight {
  color: #ff6b6b;
  font-weight: 700;
  font-size: 1.3rem;
}

.amount-success {
  color: #51cf66;
  font-weight: 700;
  font-size: 1.1rem;
}

.date-success {
  color: #51cf66;
  font-weight: 600;
}

.badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-success {
  background-color: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.badge-warning {
  background-color: #fff3cd;
  color: #856404;
  border: 1px solid #ffeeba;
}

.badge-danger {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.badge-info {
  background-color: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.badge-secondary {
  background-color: #e2e3e5;
  color: #383d41;
  border: 1px solid #d6d8db;
}

.no-results {
  text-align: center;
  padding: 40px 20px;
  color: #6c757d;
}

.no-results svg {
  margin-bottom: 20px;
  opacity: 0.7;
}

.no-results h4 {
  margin-bottom: 10px;
  color: #495057;
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

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

@media (max-width: 768px) {
  .label-cell {
    width: 45%;
    font-size: 0.85rem;
    padding: 10px 12px;
  }

  .value-cell {
    font-size: 0.85rem;
    padding: 10px 12px;
  }

  .folio-number {
    font-size: 1.2rem;
  }

  .amount-highlight {
    font-size: 1.1rem;
  }
}
</style>

