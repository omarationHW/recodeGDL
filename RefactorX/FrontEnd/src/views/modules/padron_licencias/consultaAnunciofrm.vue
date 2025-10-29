<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Anuncios</h1>
        <p>Padrón de Licencias - Gestión y Consulta de Anuncios Publicitarios</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">No. Anuncio:</label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="searchForm.anuncio"
                placeholder="Ingrese número de anuncio"
                @keyup.enter="buscarPor('anuncio')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('anuncio')"
                :disabled="!searchForm.anuncio || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Ubicación:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.ubicacion"
                placeholder="Calle, colonia, etc."
                @keyup.enter="buscarPor('ubicacion')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('ubicacion')"
                :disabled="!searchForm.ubicacion || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">No. Licencia:</label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="searchForm.licencia"
                placeholder="Número de licencia"
                @keyup.enter="buscarPor('licencia')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('licencia')"
                :disabled="!searchForm.licencia || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="anuncios.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="municipal-card-title">
          <font-awesome-icon icon="list" />
          Anuncios Encontrados ({{ totalRecords }} registros)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table table-hover">
            <thead>
              <tr>
                <th>No. Anuncio</th>
                <th>Licencia</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Área (m²)</th>
                <th>Zona</th>
                <th>Vigente</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="anuncio in anuncios" :key="anuncio.id_anuncio" @click="verDetalle(anuncio)">
                <td>{{ anuncio.anuncio }}</td>
                <td>{{ anuncio.licencia || 'N/A' }}</td>
                <td>{{ anuncio.propietario || 'Sin propietario' }}</td>
                <td>{{ anuncio.espubic || anuncio.ubicacion || 'Sin ubicación' }}</td>
                <td>{{ anuncio.area_anuncio || '0' }}</td>
                <td>{{ anuncio.zona || '-' }}</td>
                <td>
                  <span :class="['badge', anuncio.vigente === 'S' ? 'badge-success' : 'badge-secondary']">
                    {{ anuncio.vigente === 'S' ? 'Vigente' : 'No vigente' }}
                  </span>
                </td>
                <td>
                  <button
                    class="btn-municipal-secondary btn-sm"
                    @click.stop="verDetalle(anuncio)"
                    title="Ver detalle"
                  >
                    <font-awesome-icon icon="eye" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div class="pagination-container">
          <div class="pagination-info">
            Mostrando {{ ((currentPage - 1) * pageSize) + 1 }} a {{ Math.min(currentPage * pageSize, totalRecords) }} de {{ totalRecords }} registros
          </div>
          <div class="pagination">
            <button
              class="btn-pagination"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1 || loading"
            >
              <font-awesome-icon icon="chevron-left" />
            </button>
            <button
              v-for="page in paginationPages"
              :key="page"
              class="btn-pagination"
              :class="{ active: page === currentPage }"
              @click="goToPage(page)"
              :disabled="loading"
            >
              {{ page }}
            </button>
            <button
              class="btn-pagination"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages || loading"
            >
              <font-awesome-icon icon="chevron-right" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading Overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="spinner"></div>
      <p>Cargando datos...</p>
    </div>

    <!-- Modal Detalle -->
    <Modal
      v-if="showDetailModal"
      title="Detalle del Anuncio"
      @close="showDetailModal = false"
      size="large"
    >
      <template #body>
        <div v-if="selectedAnuncio" class="detail-grid">
          <div class="detail-section">
            <h6 class="section-title">Información General</h6>
            <div class="detail-row">
              <span class="detail-label">No. Anuncio:</span>
              <span class="detail-value">{{ selectedAnuncio.anuncio }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Licencia:</span>
              <span class="detail-value">{{ selectedAnuncio.licencia || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Propietario:</span>
              <span class="detail-value">{{ selectedAnuncio.propietario || 'Sin propietario' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Vigente:</span>
              <span class="detail-value">{{ selectedAnuncio.vigente === 'S' ? 'Sí' : 'No' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Bloqueado:</span>
              <span class="detail-value">{{ selectedAnuncio.bloqueado ? 'Sí' : 'No' }}</span>
            </div>
          </div>

          <div class="detail-section">
            <h6 class="section-title">Ubicación</h6>
            <div class="detail-row">
              <span class="detail-label">Ubicación:</span>
              <span class="detail-value">{{ selectedAnuncio.espubic || selectedAnuncio.ubicacion || 'Sin ubicación' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Colonia:</span>
              <span class="detail-value">{{ selectedAnuncio.colonia_ubic || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">No. Exterior:</span>
              <span class="detail-value">{{ selectedAnuncio.numext_ubic || 'N/A' }} {{ selectedAnuncio.letraext_ubic || '' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">No. Interior:</span>
              <span class="detail-value">{{ selectedAnuncio.numint_ubic || 'N/A' }} {{ selectedAnuncio.letraint_ubic || '' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Zona:</span>
              <span class="detail-value">{{ selectedAnuncio.zona || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Subzona:</span>
              <span class="detail-value">{{ selectedAnuncio.subzona || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">CP:</span>
              <span class="detail-value">{{ selectedAnuncio.cp || 'N/A' }}</span>
            </div>
          </div>

          <div class="detail-section">
            <h6 class="section-title">Características del Anuncio</h6>
            <div class="detail-row">
              <span class="detail-label">Texto:</span>
              <span class="detail-value">{{ selectedAnuncio.texto_anuncio || 'Sin texto' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Área:</span>
              <span class="detail-value">{{ selectedAnuncio.area_anuncio || '0' }} m²</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Medidas:</span>
              <span class="detail-value">{{ selectedAnuncio.medidas1 || '0' }} x {{ selectedAnuncio.medidas2 || '0' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Número de caras:</span>
              <span class="detail-value">{{ selectedAnuncio.num_caras || '0' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Base impuesto:</span>
              <span class="detail-value">${{ selectedAnuncio.base_impuesto || '0' }}</span>
            </div>
          </div>

          <div class="detail-section">
            <h6 class="section-title">Fechas</h6>
            <div class="detail-row">
              <span class="detail-label">Fecha otorgamiento:</span>
              <span class="detail-value">{{ selectedAnuncio.fecha_otorgamiento || 'N/A' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Fecha baja:</span>
              <span class="detail-value">{{ selectedAnuncio.fecha_baja || 'N/A' }}</span>
            </div>
          </div>
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="showDetailModal = false">
          Cerrar
        </button>
      </template>
    </Modal>

    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'consultaAnunciofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()

// Estado
const searchForm = ref({
  anuncio: '',
  ubicacion: '',
  licencia: ''
})

const anuncios = ref([])
const selectedAnuncio = ref(null)
const loading = ref(false)
const showDetailModal = ref(false)

const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)
const lastSearchType = ref(null)
const lastSearchValue = ref(null)

// Computadas
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))

const paginationPages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const buscarPor = async (tipo) => {
  let searchField = tipo
  let searchValue = ''

  if (tipo === 'anuncio') {
    if (!searchForm.value.anuncio) return
    searchValue = searchForm.value.anuncio
  } else if (tipo === 'ubicacion') {
    if (!searchForm.value.ubicacion) return
    searchValue = searchForm.value.ubicacion
  } else if (tipo === 'licencia') {
    if (!searchForm.value.licencia) return
    searchValue = searchForm.value.licencia
  }

  lastSearchType.value = searchField
  lastSearchValue.value = searchValue
  currentPage.value = 1

  await loadAnuncios()
}

const loadAnuncios = async () => {
  loading.value = true

  try {
    const params = [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
      { nombre: 'p_search_field', valor: lastSearchType.value, tipo: 'string' },
      { nombre: 'p_search_value', valor: lastSearchValue.value, tipo: 'string' },
      { nombre: 'p_order_by', valor: 'anuncio', tipo: 'string' }
    ]

    const response = await execute(
      'sp_consultaanuncio_list',
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      anuncios.value = response.result
      if (response.result.length > 0) {
        totalRecords.value = parseInt(response.result[0].total_count)
      }
    }
  } catch (error) {
    console.error('Error al cargar anuncios:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los anuncios',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const verDetalle = async (anuncio) => {
  loading.value = true

  try {
    const response = await execute(
      'sp_consultaanuncio_get',
      'padron_licencias',
      [{ nombre: 'p_anuncio', valor: anuncio.anuncio, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      selectedAnuncio.value = response.result[0]
      showDetailModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar detalle:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo cargar el detalle del anuncio',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadAnuncios()
  }
}
</script>
