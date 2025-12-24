<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div><div class="module-view-info"><h1>Requerimiento</h1><p>Consulta y gestión</p></div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload" /></div><div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" @keyup.enter="reload" /></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button></div>
      </div></div>
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th v-for="col in columns" :key="col">{{ col }}</th></tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ r[col] }}</td>
                </tr>
                <tr v-if="rows.length===0">
                  <td :colspan="columns.length" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <button
              class="btn-pagination"
              @click="currentPage = 1"
              :disabled="currentPage === 1"
            >
              Primera
            </button>
            <button
              class="btn-pagination"
              @click="currentPage--"
              :disabled="currentPage === 1"
            >
              Anterior
            </button>
            <span class="pagination-info">
              Página {{ currentPage }} de {{ totalPages }}
            </span>
            <button
              class="btn-pagination"
              @click="currentPage++"
              :disabled="currentPage === totalPages"
            >
              Siguiente
            </button>
            <button
              class="btn-pagination"
              @click="currentPage = totalPages"
              :disabled="currentPage === totalPages"
            >
              Última
            </button>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'Req'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Requerimiento'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'Req'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Requerimiento'"
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


const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_REQ'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const columns = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return rows.value.slice(start, end)
})

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    columns.value = arr.length ? Object.keys(arr[0]) : []
    currentPage.value = 1
  } catch (e) {
    rows.value = []
    columns.value = []
  } finally {
    hideLoading()
  }
}

reload()
</script>

