<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map" />
      </div>
      <div class="module-view-info">
        <h1>Catastro DM</h1>
        <p>Consulta con paginación server-side</p>
      </div>
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
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro</label>
              <input class="municipal-form-control" v-model="filters.q" placeholder="Buscar..." @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.year" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Propietario</th>
                  <th>Domicilio</th>
                  <th>Colonia</th>
                  <th>Año</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.propietario }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td>{{ r.colonia }}</td>
                  <td>{{ r.ejercicio }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="5" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="pagination-container" v-if="!loading && total > 0">
          <div class="pagination-info">
            Mostrando {{ (page-1)*pageSize + 1 }} a {{ Math.min(page*pageSize, total) }} de {{ total }}
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
              <button class="pagination-button" :disabled="page===1" @click="go(page-1)">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <button class="pagination-button" :disabled="page*pageSize>=total" @click="go(page+1)">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'CatastroDM'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Catastro DM'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'CatastroDM'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Catastro DM'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos' // TODO confirmar
const OP_CATASTRO_DM = 'RECAUDADORA_CATASTRO_DM' // TODO confirmar

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ q: '', year: new Date().getFullYear() })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

async function reload() {
  page.value = Math.max(1, page.value)
  const params = [
    { nombre: 'p_query', valor: String(filters.value.q || ''), tipo: 'string' },
    { nombre: 'p_year', valor: Number(filters.value.year || 0), tipo: 'integer' },
    { nombre: 'p_offset', valor: (page.value - 1) * pageSize.value, tipo: 'integer' },
    { nombre: 'p_limit', valor: pageSize.value, tipo: 'integer' }
  ]
  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_CATASTRO_DM, BASE_DB, params, '', null, 'publico')

    // Extraer datos de la estructura correcta
    const data = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []

    rows.value = arr
    total.value = arr.length > 0 ? Number(arr[0].total_count || 0) : 0
  } catch (e) {
    rows.value = []
    total.value = 0
  } finally {
    hideLoading()
  }
}

function go(p) {
  page.value = p
  reload()
}

watch([pageSize], () => reload())

reload()
</script>
