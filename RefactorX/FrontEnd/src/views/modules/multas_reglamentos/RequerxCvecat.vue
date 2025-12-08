<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Requerimientos por Clave Catastral</h1>
        <p>Consulta por cvecat</p>
      </div>
    </div>
    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Clave Catastral</label>
              <input
                class="municipal-form-control"
                v-model="filters.cvecat"
                @keyup.enter="reload"
                placeholder="Ingrese clave catastral (ej: D65J4262005)"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Folio</th>
                  <th>Cuenta</th>
                  <th>Clave Catastral</th>
                  <th>Ejercicio</th>
                  <th>Fecha Emisión</th>
                  <th>Fecha Entrega</th>
                  <th>Impuesto</th>
                  <th>Recargos</th>
                  <th>Gastos</th>
                  <th>Multas</th>
                  <th>Total</th>
                  <th>Vigencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.cvereq" class="row-hover">
                  <td>{{ r.cvereq }}</td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.cuenta }}</td>
                  <td><strong>{{ r.clave_catastral || 'N/A' }}</strong></td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.fecha_emision || 'N/A' }}</td>
                  <td>{{ r.fecha_entrega || 'N/A' }}</td>
                  <td class="text-right">${{ formatNumber(r.impuesto) }}</td>
                  <td class="text-right">${{ formatNumber(r.recargos) }}</td>
                  <td class="text-right">${{ formatNumber(r.gastos) }}</td>
                  <td class="text-right">${{ formatNumber(r.multas) }}</td>
                  <td class="text-right"><strong>${{ formatNumber(r.total) }}</strong></td>
                  <td><span :class="getVigenciaClass(r.vigencia)">{{ r.vigencia }}</span></td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="13" class="text-center text-muted">Sin resultados</td>
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
const OP_LIST = 'RECAUDADORA_REQUERXCVECAT'

const { loading, execute } = useApi()
const filters = ref({ cvecat: '' })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Función para recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'cvecat', tipo: 'C', valor: String(filters.value.cvecat || '') }
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
    console.error('Error al cargar requerimientos:', e)
    rows.value = []
  }
}

// Formatear números con 2 decimales
function formatNumber(value) {
  if (value === null || value === undefined) return '0.00'
  return Number(value).toFixed(2)
}

// Clase CSS según vigencia
function getVigenciaClass(vigencia) {
  if (vigencia === 'Pendiente') return 'badge badge-warning'
  if (vigencia === 'Cancelado') return 'badge badge-danger'
  if (vigencia === 'Entregado') return 'badge badge-success'
  return 'badge badge-secondary'
}

// Cargar datos al montar (comentado para no cargar automáticamente)
// reload()
</script>

<style scoped>
.full-width {
  flex: 1;
  width: 100%;
}

.text-right {
  text-align: right;
}

.badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.badge-warning {
  background-color: #ffc107;
  color: #000;
}

.badge-danger {
  background-color: #dc3545;
  color: #fff;
}

.badge-success {
  background-color: #28a745;
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
