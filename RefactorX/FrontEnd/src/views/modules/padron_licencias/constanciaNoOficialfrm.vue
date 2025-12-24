<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Solicitud de Número Oficial</h1>
        <p>Padrón de Licencias - Gestión de Solicitudes de Número Oficial</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
        >
          <font-awesome-icon icon="plus" />
          Nueva Solicitud
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Propietario:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.propietario"
                placeholder="Nombre del propietario"
                @keyup.enter="buscarPor('propietario')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('propietario')"
                :disabled="!searchForm.propietario"
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
                :disabled="!searchForm.ubicacion"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group form-group-button-offset">
            <button
              class="btn-municipal-secondary"
              @click="loadAll"
            >
              <font-awesome-icon icon="list" /> Ver Todas
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State - Sin búsqueda -->
    <div v-if="solicitudes.length === 0 && !hasSearched" class="empty-state">
      <div class="empty-state-icon">
        <font-awesome-icon icon="file-contract" size="3x" />
      </div>
      <h4>Solicitudes de Número Oficial</h4>
      <p>Utilice los filtros de búsqueda para encontrar solicitudes o haga clic en "Ver Todas" para listar todos los registros</p>
    </div>

    <!-- Empty State - Sin resultados -->
    <div v-else-if="solicitudes.length === 0 && hasSearched" class="empty-state">
      <div class="empty-state-icon">
        <font-awesome-icon icon="inbox" size="3x" />
      </div>
      <h4>Sin resultados</h4>
      <p>No se encontraron solicitudes con los criterios especificados</p>
    </div>

    <!-- Resultados -->
    <div v-else class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Solicitudes Encontradas
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="solicitudes.length > 0">
            {{ formatNumber(totalRecords) }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table table-hover">
            <thead>
              <tr>
                <th>Año</th>
                <th>Folio</th>
                <th>Propietario</th>
                <th>Actividad</th>
                <th>Ubicación</th>
                <th>Zona</th>
                <th>Vigente</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="solic in paginatedSolicitudes"
                :key="`${solic.axo}-${solic.folio}`"
                @click="selectedRow = solic"
                :class="{ 'table-row-selected': selectedRow === solic }"
                class="row-hover"
              >
                <td>{{ solic.axo || 'N/A' }}</td>
                <td>{{ solic.folio || 'N/A' }}</td>
                <td>{{ solic.propietario || 'Sin nombre' }}</td>
                <td>{{ solic.actividad || 'Sin actividad' }}</td>
                <td>{{ solic.ubicacion || 'Sin ubicación' }}</td>
                <td>{{ solic.zona || '-' }}</td>
                <td>
                  <span :class="['badge', solic.vigente === 'V' ? 'badge-success' : 'badge-secondary']">
                    {{ solic.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                  </span>
                </td>
                <td>{{ solic.feccap || 'N/A' }}</td>
                <td>
                  <button
                    class="btn-municipal-secondary btn-sm"
                    @click.stop="openEditModal(solic)"
                    title="Modificar"
                  >
                    <font-awesome-icon icon="edit" />
                  </button>
                  <button
                    v-if="solic.vigente === 'V'"
                    class="btn-municipal-danger btn-sm"
                    @click.stop="cancelarSolicitud(solic)"
                    title="Cancelar"
                  >
                    <font-awesome-icon icon="ban" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="solicitudes.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ formatNumber(totalRecords) }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="itemsPerPage"
              @change="changePageSize($event.target.value)"
              style="width: auto; display: inline-block;"
            >
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-double-left" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-left" />
            </button>
            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-right" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-double-right" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <Modal
      :show="showFormModal"
      :title="formMode === 'create' ? 'Nueva Solicitud' : 'Modificar Solicitud'"
      @close="showFormModal = false"
      size="lg"
    >
        <form @submit.prevent="guardarSolicitud">
          <div class="form-grid">
            <div class="form-group">
              <label class="municipal-form-label required">Propietario:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.propietario"
                required
                maxlength="50"
                placeholder="Nombre del propietario"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label required">Actividad:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.actividad"
                required
                maxlength="80"
                placeholder="Actividad o giro"
              />
            </div>

            <div class="form-group full-width">
              <label class="municipal-form-label required">Ubicación:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.ubicacion"
                required
                maxlength="75"
                placeholder="Calle, número, colonia"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label required">Zona:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.zona"
                required
                min="1"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label required">Subzona:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.subzona"
                required
                min="1"
              />
            </div>
          </div>
        </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="showFormModal = false">
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="guardarSolicitud">
          {{ formMode === 'create' ? 'Crear' : 'Actualizar' }}
        </button>
      </template>
    </Modal>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'constanciaNoOficialfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Solicitud de Número Oficial'"
      @close="showDocModal = false"
    />
    </div>
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const searchForm = ref({
  propietario: '',
  ubicacion: ''
})

const solicitudes = ref([])
const formData = ref({
  axo: null,
  folio: null,
  propietario: '',
  actividad: '',
  ubicacion: '',
  zona: 1,
  subzona: 1
})

const showFormModal = ref(false)
const formMode = ref('create') // 'create' o 'edit'
const selectedRow = ref(null)
const hasSearched = ref(false)

const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const lastSearchType = ref(null)
const lastSearchValue = ref(null)

// Computadas
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedSolicitudes = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return solicitudes.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const buscarPor = async (tipo) => {
  let searchField = tipo
  let searchValue = ''

  if (tipo === 'propietario') {
    if (!searchForm.value.propietario) return
    searchValue = searchForm.value.propietario
  } else if (tipo === 'ubicacion') {
    if (!searchForm.value.ubicacion) return
    searchValue = searchForm.value.ubicacion
  }

  lastSearchType.value = searchField
  lastSearchValue.value = searchValue
  currentPage.value = 1

  await loadSolicitudes()
}

const loadAll = async () => {
  lastSearchType.value = null
  lastSearchValue.value = null
  currentPage.value = 1
  await loadSolicitudes()
}

const loadSolicitudes = async () => {
  showLoading('Cargando solicitudes...', 'Consultando registros')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const params = [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: itemsPerPage.value, tipo: 'integer' },
      { nombre: 'p_search_field', valor: lastSearchType.value, tipo: 'string' },
      { nombre: 'p_search_value', valor: lastSearchValue.value, tipo: 'string' },
      { nombre: 'p_order_by', valor: 'axo_desc', tipo: 'string' }
    ]

    const response = await execute(
      'sp_solicnooficial_list',
      'padron_licencias',
      params,
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      solicitudes.value = response.result
      if (response.result.length > 0) {
        totalRecords.value = parseInt(response.result[0].total_count)
      }
      showToast('success', `${solicitudes.value.length} solicitudes cargadas en ${duration}s`, 3000)
    }
  } catch (error) {
    handleApiError(error, 'cargar las solicitudes')
  } finally {
    hideLoading()
  }
}

const openCreateModal = () => {
  formMode.value = 'create'
  formData.value = {
    axo: null,
    folio: null,
    propietario: '',
    actividad: '',
    ubicacion: '',
    zona: 1,
    subzona: 1
  }
  showFormModal.value = true
}

const openEditModal = (solic) => {
  formMode.value = 'edit'
  formData.value = {
    axo: solic.axo,
    folio: solic.folio,
    propietario: solic.propietario?.trim() || '',
    actividad: solic.actividad?.trim() || '',
    ubicacion: solic.ubicacion?.trim() || '',
    zona: solic.zona || 1,
    subzona: solic.subzona || 1
  }
  showFormModal.value = true
}

const guardarSolicitud = async () => {
  if (formMode.value === 'create') {
    await crearSolicitud()
  } else {
    await actualizarSolicitud()
  }
}

const crearSolicitud = async () => {
  showLoading('Creando solicitud...', 'Guardando información')
  const startTime = performance.now()
  const usuario = localStorage.getItem('usuario') || 'sistema'

  try {
    const response = await execute(
      'sp_solicnooficial_create',
      'padron_licencias',
      [
        { nombre: 'p_propietario', valor: formData.value.propietario.trim(), tipo: 'string' },
        { nombre: 'p_actividad', valor: formData.value.actividad.trim(), tipo: 'string' },
        { nombre: 'p_ubicacion', valor: formData.value.ubicacion.trim(), tipo: 'string' },
        { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
        { nombre: 'p_subzona', valor: formData.value.subzona, tipo: 'integer' },
        { nombre: 'p_capturista', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Solicitud creada',
        text: `Año: ${response.result[0].axo}, Folio: ${response.result[0].folio}`,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })
      showFormModal.value = false
      loadSolicitudes()
    } else {
      throw new Error(response?.result?.[0]?.message || 'Error desconocido')
    }
  } catch (error) {
    handleApiError(error, 'crear la solicitud')
  } finally {
    hideLoading()
  }
}

const actualizarSolicitud = async () => {
  showLoading('Actualizando solicitud...', 'Guardando cambios')
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_solicnooficial_update',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: formData.value.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: formData.value.folio, tipo: 'integer' },
        { nombre: 'p_propietario', valor: formData.value.propietario.trim(), tipo: 'string' },
        { nombre: 'p_actividad', valor: formData.value.actividad.trim(), tipo: 'string' },
        { nombre: 'p_ubicacion', valor: formData.value.ubicacion.trim(), tipo: 'string' },
        { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
        { nombre: 'p_subzona', valor: formData.value.subzona, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Actualizado',
        text: 'Solicitud actualizada correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showFormModal.value = false
      loadSolicitudes()
    } else {
      throw new Error(response?.result?.[0]?.message || 'Error desconocido')
    }
  } catch (error) {
    handleApiError(error, 'actualizar la solicitud')
  } finally {
    hideLoading()
  }
}

const cancelarSolicitud = async (solic) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Cancelar Solicitud?',
    html: `<div class="swal-selection-content">
             <p class="swal-confirmation-text">¿Desea cancelar la solicitud <strong>Año ${solic.axo}, Folio ${solic.folio}</strong>?</p>
             <p class="swal-confirmation-text">Esta acción marcará la solicitud como no vigente.</p>
           </div>`,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    showLoading('Cancelando solicitud...', 'Procesando')
    const startTime = performance.now()

    try {
      const response = await execute(
        'sp_solicnooficial_cancel',
        'padron_licencias',
        [
          { nombre: 'p_axo', valor: solic.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: solic.folio, tipo: 'integer' }
        ],
        'guadalajara'
      )

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)

      if (response && response.result && response.result[0]?.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Cancelada',
          text: 'Solicitud cancelada correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        loadSolicitudes()
      } else {
        throw new Error(response?.result?.[0]?.message || 'Error desconocido')
      }
    } catch (error) {
      handleApiError(error, 'cancelar la solicitud')
    } finally {
      hideLoading()
    }
  }
}

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const clearFilters = () => {
  searchForm.value = {
    propietario: '',
    ubicacion: ''
  }
  solicitudes.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
  lastSearchType.value = null
  lastSearchValue.value = null
}
</script>
