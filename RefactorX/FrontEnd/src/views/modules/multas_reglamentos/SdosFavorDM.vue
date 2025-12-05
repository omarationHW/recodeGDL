<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="piggy-bank" /></div>
      <div class="module-view-info">
        <h1>Saldos a Favor DM</h1>
        <p>Consulta de saldos a favor (Derechos Municipales)</p>
      </div>
    </div>
    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="reload"
                placeholder="Ingrese cuenta"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Saldos a Favor DM ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Saldo Inicial</th>
                  <th>Importe Aplicado</th>
                  <th>Saldo Restante</th>
                  <th>Estado</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.cvecuenta}-${r.folio}`" class="row-hover">
                  <td><strong>{{ r.cvecuenta }}</strong></td>
                  <td>{{ r.folio }}</td>
                  <td class="text-right">${{ formatMoney(r.saldo_inicial) }}</td>
                  <td class="text-right">${{ formatMoney(r.importe_aplicado) }}</td>
                  <td class="text-right">
                    <span :class="getSaldoClass(r.saldo_restante)">
                      ${{ formatMoney(r.saldo_restante) }}
                    </span>
                  </td>
                  <td><span :class="getEstadoClass(r.estado)">{{ r.estado }}</span></td>
                  <td>{{ formatDate(r.fecha_alta) }}</td>
                  <td>{{ r.usuario_alta || 'N/A' }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="8" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_SDOSFAVOR_DM'
const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Formatear moneda
function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX')
}

// Clase CSS según saldo restante
function getSaldoClass(saldo) {
  const s = parseFloat(saldo || 0)
  if (s > 0) return 'saldo-pendiente'
  return 'saldo-liquidado'
}

// Clase CSS según estado
function getEstadoClass(estado) {
  if (estado === 'Pendiente') return 'badge badge-warning'
  if (estado === 'Liquidado') return 'badge badge-success'
  if (estado === 'Cancelado') return 'badge badge-danger'
  return 'badge badge-secondary'
}

// Recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]

  try {
    const response = await execute(OP_LIST, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta según la estructura de la API
    let arr = []

    // La API puede retornar diferentes estructuras
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar saldos a favor:', e)
    rows.value = []
  }
}

// No cargar automáticamente
// reload()
</script>

<style scoped>
.text-right {
  text-align: right;
}

.saldo-pendiente {
  color: #28a745;
  font-weight: 600;
}

.saldo-liquidado {
  color: #6c757d;
}

.badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.badge-success {
  background-color: #28a745;
  color: #fff;
}

.badge-warning {
  background-color: #ffc107;
  color: #000;
}

.badge-danger {
  background-color: #dc3545;
  color: #fff;
}

.badge-secondary {
  background-color: #6c757d;
  color: #fff;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 14px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 15px;
}

.pagination-page {
  color: #495057;
  font-weight: 500;
}

.btn-pagination {
  padding: 8px 16px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
