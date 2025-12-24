<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Empresas</h1>
        <p>Consulta de empresas registradas</p>
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
      <!-- Search form -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nombre</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Buscar empresa por nombre..."
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

      <!-- Results table -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Empresas ({{ total }} registros)</h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Empresa</th>
                  <th>RFC</th>
                  <th>Contacto</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><strong>{{ r.empresa || r.nombre }}</strong></td>
                  <td><code>{{ r.rfc }}</code></td>
                  <td>{{ r.contacto }}</td>
                  <td>
                    <span :class="'badge badge-' + (r.estatus === 'Activo' ? 'success' : 'secondary')">
                      {{ r.estatus }}
                    </span>
                  </td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    Sin empresas encontradas
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination Controls -->
          <div v-if="total > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex }} - {{ endIndex }} de {{ total }} registros
              </span>
            </div>
            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary"
                :disabled="page === 1"
                @click="goToPage(1)">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="page === 1"
                @click="goToPage(page - 1)">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page-indicator">
                Página {{ page }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary"
                :disabled="page === totalPages"
                @click="goToPage(page + 1)">
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="page === totalPages"
                @click="goToPage(totalPages)">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'Empresas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Empresas'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'Empresas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Empresas'"
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
const OP_LIST = 'RECAUDADORA_EMPRESAS'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ q: '' })
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const rows = ref([])

// Computed properties para paginación
const totalPages = computed(() => Math.ceil(total.value / pageSize.value))

const startIndex = computed(() => (page.value - 1) * pageSize.value + 1)

const endIndex = computed(() => {
  const end = page.value * pageSize.value
  return end > total.value ? total.value : end
})

// Funciones de paginación
function goToPage(p) {
  if (p >= 1 && p <= totalPages.value) {
    page.value = p
    reload()
  }
}

async function reload() {
  const params = [
    { nombre: 'q', tipo: 'string', valor: String(filters.value.q || '') },
    { nombre: 'offset', tipo: 'integer', valor: (page.value - 1) * pageSize.value },
    { nombre: 'limit', tipo: 'integer', valor: pageSize.value }
  ]

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)

    // La API puede retornar data.result, data.rows, o data directamente
    rows.value = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
      ? data.rows
      : Array.isArray(data)
      ? data
      : []

    // Obtener el total de registros
    if (rows.value.length > 0 && rows.value[0].total_count) {
      total.value = Number(rows.value[0].total_count)
    } else if (data?.total !== undefined) {
      total.value = Number(data.total)
    } else if (data?.count !== undefined) {
      total.value = Number(data.count)
    } else {
      total.value = rows.value.length
    }
  } catch (e) {
    rows.value = []
    total.value = 0
    console.error('Error al cargar empresas:', e)
  } finally {
    hideLoading()
  }
}

// Cargar datos al iniciar
reload()
</script>
