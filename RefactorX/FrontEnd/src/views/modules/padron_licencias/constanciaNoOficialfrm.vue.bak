<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Solicitud de Número Oficial</h1>
        <p>Padrón de Licencias - Gestión de Solicitudes de Número Oficial</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
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
                :disabled="!searchForm.propietario || loading"
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
            <button
              class="btn-municipal-secondary"
              @click="loadAll"
              :disabled="loading"
              style="margin-top: 24px;"
            >
              <font-awesome-icon icon="list" /> Ver Todas
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="solicitudes.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="municipal-card-title">
          <font-awesome-icon icon="list" />
          Solicitudes Encontradas ({{ totalRecords }} registros)
        </h5>
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
              <tr v-for="solic in solicitudes" :key="`${solic.axo}-${solic.folio}`">
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
                    @click="openEditModal(solic)"
                    title="Modificar"
                  >
                    <font-awesome-icon icon="edit" />
                  </button>
                  <button
                    v-if="solic.vigente === 'V'"
                    class="btn-municipal-danger btn-sm"
                    @click="cancelarSolicitud(solic)"
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

    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'constanciaNoOficialfrm'"
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

const loading = ref(false)
const showFormModal = ref(false)
const formMode = ref('create') // 'create' o 'edit'

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
  loading.value = true

  try {
    const params = [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
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

    if (response && response.result) {
      solicitudes.value = response.result
      if (response.result.length > 0) {
        totalRecords.value = parseInt(response.result[0].total_count)
      }
    }
  } catch (error) {
    console.error('Error al cargar solicitudes:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar las solicitudes',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
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
  loading.value = true

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
        { nombre: 'p_capturista', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

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
    console.error('Error al crear:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo crear la solicitud',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const actualizarSolicitud = async () => {
  loading.value = true

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
    console.error('Error al actualizar:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo actualizar la solicitud',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cancelarSolicitud = async (solic) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Cancelar Solicitud?',
    html: `<p>¿Desea cancelar la solicitud <strong>Año ${solic.axo}, Folio ${solic.folio}</strong>?</p>
           <p>Esta acción marcará la solicitud como no vigente.</p>`,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    loading.value = true

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
      console.error('Error al cancelar:', error)
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo cancelar la solicitud',
        confirmButtonColor: '#ea8215'
      })
    } finally {
      loading.value = false
    }
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadSolicitudes()
  }
}
</script>
