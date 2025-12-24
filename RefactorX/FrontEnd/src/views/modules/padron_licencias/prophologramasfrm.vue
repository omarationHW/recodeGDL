<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="certificate" />
      </div>
      <div class="module-view-info">
        <h1>Propietarios de Hologramas</h1>
        <p>Padrón de Licencias - Gestión de Contribuyentes con Propuestas de Hologramas</p>
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
          Nuevo Propietario
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc"
              placeholder="RFC"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">CURP</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.curp"
              placeholder="CURP"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchPropietarios"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadPropietarios"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Propietarios de Hologramas
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="propietarios.length > 0">
            {{ propietarios.length }} registros
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="propietarios.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="certificate" size="3x" />
          </div>
          <h4>Propietarios de Hologramas</h4>
          <p>Utilice los filtros de búsqueda o haga clic en "Actualizar" para ver todos los propietarios registrados</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="propietarios.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron propietarios con los criterios especificados</p>
        </div>

        <!-- Tabla con resultados -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Domicilio</th>
                <th>Colonia</th>
                <th>Teléfono</th>
                <th>RFC</th>
                <th>CURP</th>
                <th>Email</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="propietario in propietarios"
                :key="propietario.idcontrib"
                @click="selectedRow = propietario"
                :class="{ 'table-row-selected': selectedRow === propietario }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ propietario.idcontrib }}</strong></td>
                <td>{{ propietario.nombre?.trim() || 'N/A' }}</td>
                <td>{{ propietario.domicilio?.trim() || 'N/A' }}</td>
                <td>{{ propietario.colonia?.trim() || 'N/A' }}</td>
                <td>
                  <span v-if="propietario.telefono">
                    <font-awesome-icon icon="phone" class="text-muted" />
                    {{ propietario.telefono }}
                  </span>
                  <span v-else class="text-muted">N/A</span>
                </td>
                <td><code>{{ propietario.rfc?.trim() || 'N/A' }}</code></td>
                <td><code>{{ propietario.curp?.trim() || 'N/A' }}</code></td>
                <td>
                  <span v-if="propietario.email">
                    <font-awesome-icon icon="envelope" class="text-muted" />
                    {{ propietario.email }}
                  </span>
                  <span v-else class="text-muted">N/A</span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewPropietario(propietario)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="editPropietario(propietario)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click.stop="confirmDeletePropietario(propietario)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Propietario de Holograma"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createPropietario"
      :loading="creatingPropietario"
      confirmText="Crear Propietario"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createPropietario">
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombre Completo: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newPropietario.nombre"
            maxlength="100"
            required
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Domicilio:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newPropietario.domicilio"
            maxlength="150"
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Colonia:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newPropietario.colonia"
              maxlength="100"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Teléfono:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newPropietario.telefono"
              maxlength="20"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">RFC:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newPropietario.rfc"
              maxlength="13"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">CURP:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newPropietario.curp"
              maxlength="18"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Email:</label>
          <input
            type="email"
            class="municipal-form-control"
            v-model="newPropietario.email"
            maxlength="100"
          >
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Propietario: ${selectedPropietario?.nombre}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="updatePropietario"
      :loading="updatingPropietario"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updatePropietario">
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombre Completo: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.nombre"
            maxlength="100"
            required
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Domicilio:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.domicilio"
            maxlength="150"
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Colonia:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.colonia"
              maxlength="100"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Teléfono:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.telefono"
              maxlength="20"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">RFC:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.rfc"
              maxlength="13"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">CURP:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.curp"
              maxlength="18"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Email:</label>
          <input
            type="email"
            class="municipal-form-control"
            v-model="editForm.email"
            maxlength="100"
          >
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Propietario: ${selectedPropietario?.nombre}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedPropietario" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información Personal
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><strong>{{ selectedPropietario.idcontrib }}</strong></td>
              </tr>
              <tr>
                <td class="label">Nombre:</td>
                <td>{{ selectedPropietario.nombre?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ selectedPropietario.rfc?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">CURP:</td>
                <td><code>{{ selectedPropietario.curp?.trim() || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Información de Contacto
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ selectedPropietario.domicilio?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedPropietario.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>
                  <font-awesome-icon icon="phone" class="text-muted" />
                  {{ selectedPropietario.telefono?.trim() || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>
                  <font-awesome-icon icon="envelope" class="text-muted" />
                  {{ selectedPropietario.email?.trim() || 'N/A' }}
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="detail-section">
          <h6 class="section-title">
            <font-awesome-icon icon="info-circle" />
            Información de Captura
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Fecha Captura:</td>
              <td>
                <font-awesome-icon icon="clock" class="text-info" />
                {{ formatDate(selectedPropietario.feccap) }}
              </td>
            </tr>
            <tr>
              <td class="label">Capturó:</td>
              <td>{{ selectedPropietario.capturista?.trim() || 'N/A' }}</td>
            </tr>
          </table>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editPropietario(selectedPropietario); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Propietario
          </button>
        </div>
      </div>
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
      :componentName="'prophologramasfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Propietarios de Hologramas'"
      @close="showDocModal = false"
    />

    </div>
    <!-- /module-view-content -->

  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
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
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const propietarios = ref([])
const selectedPropietario = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingPropietario = ref(false)
const updatingPropietario = ref(false)

// Filtros
const filters = ref({
  nombre: '',
  rfc: '',
  curp: ''
})

// Formularios
const newPropietario = ref({
  nombre: '',
  domicilio: '',
  colonia: '',
  telefono: '',
  rfc: '',
  curp: '',
  email: ''
})

const editForm = ref({
  idcontrib: null,
  nombre: '',
  domicilio: '',
  colonia: '',
  telefono: '',
  rfc: '',
  curp: '',
  email: ''
})

// Métodos
const loadPropietarios = async () => {
  showLoading('Cargando propietarios de hologramas...')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(
      'get_contribholog_list',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      propietarios.value = response.result
      showToast('success', 'Propietarios cargados correctamente')
      toast.value.duration = durationText
    } else {
      propietarios.value = []
      showToast('error', 'Error al cargar propietarios')
    }
  } catch (error) {
    handleApiError(error)
    propietarios.value = []
  } finally {
    hideLoading()
  }
}

const searchPropietarios = async () => {
  showLoading('Buscando propietarios...')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const response = await execute(
      'sp_c_contribholog_list',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: filters.value.nombre || null, tipo: 'string' },
        { nombre: 'p_rfc', valor: filters.value.rfc || null, tipo: 'string' },
        { nombre: 'p_curp', valor: filters.value.curp || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      propietarios.value = response.result
      showToast('success', `Se encontraron ${response.result.length} resultados`)
    } else {
      propietarios.value = []
      showToast('warning', 'No se encontraron resultados')
    }
  } catch (error) {
    handleApiError(error)
    propietarios.value = []
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    nombre: '',
    rfc: '',
    curp: ''
  }
  propietarios.value = []
  hasSearched.value = false
  selectedRow.value = null
}

const openCreateModal = () => {
  newPropietario.value = {
    nombre: '',
    domicilio: '',
    colonia: '',
    telefono: '',
    rfc: '',
    curp: '',
    email: ''
  }
  showCreateModal.value = true
}

const createPropietario = async () => {
  if (!newPropietario.value.nombre) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el nombre del propietario',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo propietario con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${newPropietario.value.nombre}</li>
          ${newPropietario.value.rfc ? `<li style="margin: 5px 0;"><strong>RFC:</strong> ${newPropietario.value.rfc}</li>` : ''}
          ${newPropietario.value.curp ? `<li style="margin: 5px 0;"><strong>CURP:</strong> ${newPropietario.value.curp}</li>` : ''}
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingPropietario.value = true
  const startTime = performance.now()

  try {
    const usuario = localStorage.getItem('usuario') || 'sistema'
    const response = await execute(
      'sp_c_contribholog_create',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: newPropietario.value.nombre.trim(), tipo: 'string' },
        { nombre: 'p_domicilio', valor: newPropietario.value.domicilio?.trim() || '', tipo: 'string' },
        { nombre: 'p_colonia', valor: newPropietario.value.colonia?.trim() || '', tipo: 'string' },
        { nombre: 'p_telefono', valor: newPropietario.value.telefono?.trim() || '', tipo: 'string' },
        { nombre: 'p_rfc', valor: newPropietario.value.rfc?.trim() || '', tipo: 'string' },
        { nombre: 'p_curp', valor: newPropietario.value.curp?.trim() || '', tipo: 'string' },
        { nombre: 'p_email', valor: newPropietario.value.email?.trim() || '', tipo: 'string' },
        { nombre: 'p_capturista', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      showCreateModal.value = false
      loadPropietarios()

      await Swal.fire({
        icon: 'success',
        title: 'Propietario creado',
        text: 'El propietario ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Propietario creado exitosamente')
      toast.value.duration = durationText
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingPropietario.value = false
  }
}

const editPropietario = (propietario) => {
  selectedPropietario.value = propietario
  editForm.value = {
    idcontrib: propietario.idcontrib,
    nombre: propietario.nombre?.trim() || '',
    domicilio: propietario.domicilio?.trim() || '',
    colonia: propietario.colonia?.trim() || '',
    telefono: propietario.telefono?.trim() || '',
    rfc: propietario.rfc?.trim() || '',
    curp: propietario.curp?.trim() || '',
    email: propietario.email?.trim() || ''
  }
  showEditModal.value = true
}

const updatePropietario = async () => {
  if (!editForm.value.nombre) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el nombre del propietario',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    text: 'Se actualizarán los datos del propietario',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  updatingPropietario.value = true

  try {
    const response = await execute(
      'sp_c_contribholog_update',
      'padron_licencias',
      [
        { nombre: 'p_idcontrib', valor: editForm.value.idcontrib, tipo: 'integer' },
        { nombre: 'p_nombre', valor: editForm.value.nombre.trim(), tipo: 'string' },
        { nombre: 'p_domicilio', valor: editForm.value.domicilio?.trim() || '', tipo: 'string' },
        { nombre: 'p_colonia', valor: editForm.value.colonia?.trim() || '', tipo: 'string' },
        { nombre: 'p_telefono', valor: editForm.value.telefono?.trim() || '', tipo: 'string' },
        { nombre: 'p_rfc', valor: editForm.value.rfc?.trim() || '', tipo: 'string' },
        { nombre: 'p_curp', valor: editForm.value.curp?.trim() || '', tipo: 'string' },
        { nombre: 'p_email', valor: editForm.value.email?.trim() || '', tipo: 'string' },
        { nombre: 'p_capturista', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      showEditModal.value = false
      loadPropietarios()

      await Swal.fire({
        icon: 'success',
        title: 'Propietario actualizado',
        text: 'Los datos han sido actualizados exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Propietario actualizado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    updatingPropietario.value = false
  }
}

const viewPropietario = (propietario) => {
  selectedPropietario.value = propietario
  showViewModal.value = true
}

const confirmDeletePropietario = async (propietario) => {
  const result = await Swal.fire({
    title: '¿Eliminar propietario?',
    text: `¿Está seguro de eliminar a "${propietario.nombre?.trim()}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deletePropietario(propietario)
  }
}

const deletePropietario = async (propietario) => {
  try {
    const response = await execute(
      'sp_c_contribholog_delete',
      'padron_licencias',
      [
        { nombre: 'p_idcontrib', valor: propietario.idcontrib, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      loadPropietarios()

      await Swal.fire({
        icon: 'success',
        title: 'Propietario eliminado',
        text: 'El propietario ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Propietario eliminado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  loadPropietarios()
})
</script>
