<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Otorga Descuento</h1>
        <p>Autorización y registro de descuentos en multas</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="reload"
                placeholder="Ingrese número de cuenta"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                @keyup.enter="reload"
                placeholder="Año del ejercicio"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && rows.length > 0">
        <div class="municipal-card-header">
          <h5>Descuentos Otorgados</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Monto Multa</th>
                  <th>Tipo Descto</th>
                  <th>% Descto</th>
                  <th>Importe Descto</th>
                  <th>Fecha Captura</th>
                  <th>Capturista</th>
                  <th>Autoriza</th>
                  <th>Estado</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="r.id_multa" class="row-hover">
                  <td><code>{{ r.id_multa }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.anio }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(r.monto_multa) }}</strong></td>
                  <td>{{ r.tipo_descto }}</td>
                  <td class="text-end">{{ r.porcentaje_descto }}%</td>
                  <td class="text-end text-success"><strong>{{ formatCurrency(r.importe_descto) }}</strong></td>
                  <td>{{ formatDate(r.fecha_captura) }}</td>
                  <td>{{ r.capturista }}</td>
                  <td class="text-center">{{ r.autoriza }}</td>
                  <td>
                    <span
                      :class="getStatusClass(r.estado)"
                      class="status-badge"
                    >
                      {{ r.estado }}
                    </span>
                  </td>
                  <td>{{ r.observacion || 'N/A' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-container" v-if="total > 0">
          <div class="pagination-info">
            Mostrando {{ (page - 1) * pageSize + 1 }} a {{ Math.min(page * pageSize, total) }} de {{ total }}
          </div>
          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" @change="reload">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
              </select>
            </div>
            <div class="pagination-nav">
              <button
                class="pagination-button"
                :disabled="page === 1"
                @click="go(page - 1)"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>
              <button
                class="pagination-button"
                :disabled="page * pageSize >= total"
                @click="go(page + 1)"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && rows.length === 0 && searched">
        <div class="municipal-card-body">
          <p class="text-center text-muted">
            No se encontraron descuentos para los criterios especificados.
          </p>
        </div>
      </div>

      <div class="municipal-card" v-if="loading">
        <div class="municipal-card-body text-center">
          <div class="spinner-border"></div>
          <p>Cargando datos...</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_OTORGA_DESCTO'

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const searched = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function reload() {
  try {
    searched.value = true
    page.value = 1 // Reset a página 1 cuando se busca
    const params = [
      { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
      { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) },
      { nombre: 'p_offset', tipo: 'integer', valor: (page.value - 1) * pageSize.value },
      { nombre: 'p_limit', tipo: 'integer', valor: pageSize.value }
    ]
    const data = await execute(OP, BASE_DB, params)
    const result = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []
    rows.value = result
    // Extraer total_registros de la primera fila si existe
    total.value = result.length > 0 && result[0].total_registros ? Number(result[0].total_registros) : 0
  } catch (e) {
    rows.value = []
    total.value = 0
    console.error('Error al cargar datos:', e)
  }
}

function go(p) {
  page.value = p
  reload()
}

function formatCurrency(v) {
  return Number(v || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}

function formatDate(d) {
  if (!d) return 'N/A'
  const date = new Date(d)
  if (!isNaN(date.getTime())) {
    return date.toLocaleDateString('es-MX')
  }
  return d
}

function getStatusClass(status) {
  switch (status) {
    case 'Pagado':
      return 'status-success'
    case 'Cancelado':
      return 'status-danger'
    case 'Vigente':
      return 'status-info'
    default:
      return 'status-secondary'
  }
}
</script>

<style scoped>
.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.status-success {
  background-color: #d4edda;
  color: #155724;
}

.status-danger {
  background-color: #f8d7da;
  color: #721c24;
}

.status-info {
  background-color: #d1ecf1;
  color: #0c5460;
}

.status-secondary {
  background-color: #e2e3e5;
  color: #383d41;
}

.text-end {
  text-align: right;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.text-success {
  color: #28a745;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 0.875rem;
}

.pagination-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.page-size-selector {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.page-size-selector label {
  font-size: 0.875rem;
  color: #6c757d;
}

.page-size-selector select {
  padding: 0.25rem 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 0.875rem;
}

.pagination-nav {
  display: flex;
  gap: 0.5rem;
}

.pagination-button {
  padding: 0.5rem 0.75rem;
  border: 1px solid #ced4da;
  background-color: white;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.pagination-button:hover:not(:disabled) {
  background-color: #f8f9fa;
  border-color: #adb5bd;
}

.pagination-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>

