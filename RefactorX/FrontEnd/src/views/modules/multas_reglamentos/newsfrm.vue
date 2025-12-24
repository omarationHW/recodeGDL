<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="newspaper" />
      </div>
      <div class="module-view-info">
        <h1>Novedades de Multas</h1>
        <p>Consulta de multas recientes y novedades con paginación</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Búsqueda</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Buscar por contribuyente, folio, año..."
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
          <h5>Novedades de Multas</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Fecha Acta</th>
                  <th>Fecha Recepción</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Total</th>
                  <th>Estatus</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="r.id_multa" class="row-hover">
                  <td><code>{{ r.id_multa }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.anio }}</td>
                  <td>{{ formatDate(r.fecha_acta) }}</td>
                  <td>{{ formatDate(r.fecha_recepcion) }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(r.total) }}</strong></td>
                  <td>
                    <span
                      :class="getStatusClass(r.estatus)"
                      class="status-badge"
                    >
                      {{ r.estatus }}
                    </span>
                  </td>
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
            No se encontraron resultados para la búsqueda.
          </p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'newsfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Novedades de Multas'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'newsfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Novedades de Multas'"
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
const OP = 'RECAUDADORA_NEWSFRM'
const SCHEMA = 'publico'

const filters = ref({ q: '' })
const rows = ref([])
const searched = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

async function reload() {
  try {
    searched.value = true
    const params = [
      { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') },
      { nombre: 'p_offset', tipo: 'integer', valor: (page.value - 1) * pageSize.value },
      { nombre: 'p_limit', tipo: 'integer', valor: pageSize.value }
    ]
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)
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
    case 'PAGADA':
      return 'status-success'
    case 'CANCELADA':
      return 'status-danger'
    case 'PENDIENTE':
      return 'status-warning'
    default:
      return 'status-secondary'
  }
}
</script>

