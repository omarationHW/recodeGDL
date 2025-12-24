<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Multas 400</h1>
        <p>Consulta de multas del artículo 400</p>
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
              <label class="municipal-form-label">Buscar</label>
              <input
                class="municipal-form-control"
                v-model="filters.filtro"
                @keyup.enter="reload"
                placeholder="ID multa, acta, contribuyente o expediente..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados ({{ allRows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Acta</th>
                  <th>Año</th>
                  <th>Fecha Acta</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Dependencia</th>
                  <th>Expediente</th>
                  <th>Multa</th>
                  <th>Gastos</th>
                  <th>Total</th>
                  <th>CVE Pago</th>
                  <th>Fecha Recepción</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in paginatedRows" :key="i" class="row-hover">
                  <td>{{ r.id_multa }}</td>
                  <td>{{ r.num_acta }}</td>
                  <td>{{ r.axo_acta }}</td>
                  <td>{{ formatDate(r.fecha_acta) }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td>{{ r.id_dependencia }}</td>
                  <td>{{ r.expediente }}</td>
                  <td class="text-right">{{ formatMoney(r.multa) }}</td>
                  <td class="text-right">{{ formatMoney(r.gastos) }}</td>
                  <td class="text-right text-bold">{{ formatMoney(r.total) }}</td>
                  <td>
                    <span v-if="r.cvepago" class="badge badge-success">{{ r.cvepago }}</span>
                    <span v-else class="badge badge-warning">SIN PAGO</span>
                  </td>
                  <td>{{ formatDate(r.fecha_recepcion) }}</td>
                  <td class="text-small">{{ r.observacion }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <button
              class="btn-pagination"
              :disabled="currentPage === 1"
              @click="currentPage--"
            >
              <font-awesome-icon icon="chevron-left" />
              Anterior
            </button>

            <div class="pagination-info">
              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-page"
                :class="{ active: page === currentPage }"
                @click="currentPage = page"
              >
                {{ page }}
              </button>
            </div>

            <button
              class="btn-pagination"
              :disabled="currentPage === totalPages"
              @click="currentPage++"
            >
              Siguiente
              <font-awesome-icon icon="chevron-right" />
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-else-if="searched && allRows.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">No se encontraron resultados</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'multas400frm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Multas 400'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'multas400frm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Multas 400'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_MULTAS400FRM'
const SCHEMA = 'publico'

const filters = ref({ filtro: '' })
const allRows = ref([])
const searched = ref(false)
const currentPage = ref(1)
const pageSize = 10

// Computed: filas paginadas
const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const end = start + pageSize
  return allRows.value.slice(start, end)
})

// Computed: total de páginas
const totalPages = computed(() => {
  return Math.ceil(allRows.value.length / pageSize)
})

// Computed: páginas visibles en el paginador
const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value

  if (total <= 7) {
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    if (current <= 4) {
      for (let i = 1; i <= 5; i++) pages.push(i)
      pages.push('...')
      pages.push(total)
    } else if (current >= total - 3) {
      pages.push(1)
      pages.push('...')
      for (let i = total - 4; i <= total; i++) pages.push(i)
    } else {
      pages.push(1)
      pages.push('...')
      for (let i = current - 1; i <= current + 1; i++) pages.push(i)
      pages.push('...')
      pages.push(total)
    }
  }

  return pages
})

async function reload() {
  searched.value = false
  currentPage.value = 1
  try {
    showLoading('Consultando...', 'Por favor espere')
    console.log('🔍 Iniciando búsqueda con filtro:', filters.value.filtro)

    const params = [
      { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.filtro || '') }
    ]

    console.log('📤 Parámetros enviados:', params)

    const response = await execute(OP, BASE_DB, params, '', null, SCHEMA)

    console.log('📥 Respuesta recibida:', response)

    // El useApi extrae 'data' de eResponse, así que response puede tener { result: [...] }
    let arr = []
    if (response?.result && Array.isArray(response.result)) {
      arr = response.result
      console.log('✅ Datos extraídos de response.result:', arr.length, 'registros')
    } else if (Array.isArray(response)) {
      arr = response
      console.log('✅ Respuesta es array directo:', arr.length, 'registros')
    } else {
      arr = []
      console.log('⚠️ No se encontraron datos en la respuesta')
    }

    allRows.value = arr
    searched.value = true

    console.log('🎯 Total de registros cargados:', allRows.value.length)
  } catch (e) {
    console.error('❌ Error al buscar multas 400:', e)
    allRows.value = []
    searched.value = true
  } finally {
    hideLoading()
  }
}

function formatMoney(value) {
  if (value === null || value === undefined) return '$0.00'
  return '$' + parseFloat(value).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function formatDate(value) {
  if (!value) return 'N/A'
  return new Date(value).toLocaleDateString('es-MX')
}
</script>


