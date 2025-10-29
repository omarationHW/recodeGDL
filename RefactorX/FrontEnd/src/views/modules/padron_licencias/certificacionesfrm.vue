<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="certificate" />
      </div>
      <div class="module-view-info">
        <h1>Certificaciones</h1>
        <p>Padrón de Licencias - Gestión de Certificaciones</p></div>
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
          Nueva Certificación
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Certificación</label>
            <select class="municipal-form-control" v-model="filters.tipo">
              <option value="">Todos los tipos</option>
              <option value="A">Tipo A - Certificación de Anuncio</option>
              <option value="L">Tipo L - Certificación de Licencia</option>
              <option value="C">Tipo C - Certificación de Constancia</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.axo"
              placeholder="Año"
              min="2000"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.folio"
              placeholder="Folio"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Licencia</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id_licencia"
              placeholder="ID Licencia"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchCertificaciones"
            :disabled="loading || !filters.tipo"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadCertificaciones"
            :disabled="loading || !filters.tipo"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
          <span class="badge-info" v-if="certificaciones.length > 0">{{ certificaciones.length }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Año</th>
                <th>Folio</th>
                <th>ID Licencia</th>
                <th>Tipo</th>
                <th>Partida Pago</th>
                <th>Vigente</th>
                <th>Fecha Captura</th>
                <th>Capturista</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="cert in certificaciones" :key="cert.id" class="row-hover">
                <td><strong class="text-primary">{{ cert.id }}</strong></td>
                <td>{{ cert.axo }}</td>
                <td><code class="text-muted">{{ cert.folio }}</code></td>
                <td>
                  <span class="badge-secondary">
                    {{ cert.id_licencia || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(cert.tipo)">
                    <font-awesome-icon icon="certificate" />
                    {{ getTipoText(cert.tipo) }}
                  </span>
                </td>
                <td>{{ cert.partidapago?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="cert.vigente === 'S' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="cert.vigente === 'S' ? 'check-circle' : 'times-circle'" />
                    {{ cert.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(cert.feccap) }}
                  </small>
                </td>
                <td>{{ cert.capturista?.trim() || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewCertificacion(cert)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editCertificacion(cert)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      v-if="cert.vigente === 'S'"
                      class="btn-municipal-danger btn-sm"
                      @click="confirmCancelCertificacion(cert)"
                      title="Cancelar"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="certificaciones.length === 0 && !loading">
                <td colspan="10" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron certificaciones. Seleccione un tipo y presione Buscar.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && certificaciones.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando certificaciones...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Certificación"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createCertificacion"
      :loading="creatingCertificacion"
      confirmText="Crear Certificación"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createCertificacion">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Año: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newCertificacion.axo"
              min="2000"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newCertificacion.folio"
              required
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">ID Licencia: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newCertificacion.id_licencia"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newCertificacion.tipo" required>
              <option value="">Seleccionar...</option>
              <option value="A">Tipo A - Certificación de Anuncio</option>
              <option value="L">Tipo L - Certificación de Licencia</option>
              <option value="C">Tipo C - Certificación de Constancia</option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Partida Pago:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newCertificacion.partidapago"
              maxlength="50"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigente: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newCertificacion.vigente" required>
              <option value="S">Sí - Vigente</option>
              <option value="N">No - No Vigente</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="newCertificacion.observacion"
            rows="3"
            maxlength="500"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Certificación ID: ${selectedCertificacion?.id}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="updateCertificacion"
      :loading="updatingCertificacion"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateCertificacion">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">ID (No editable):</label>
            <input
              type="number"
              class="municipal-form-control"
              :value="editForm.id"
              disabled
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.axo"
              min="2000"
              disabled
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Folio:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.folio"
              disabled
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Licencia: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.id_licencia"
              required
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Partida Pago:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.partidapago"
              maxlength="50"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigente: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="editForm.vigente" required>
              <option value="S">Sí - Vigente</option>
              <option value="N">No - No Vigente</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.observacion"
            rows="3"
            maxlength="500"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Certificación ID: ${selectedCertificacion?.id}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedCertificacion" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="certificate" />
              Información de Certificación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ selectedCertificacion.id }}</code></td>
              </tr>
              <tr>
                <td class="label">Año:</td>
                <td>{{ selectedCertificacion.axo }}</td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ selectedCertificacion.folio }}</td>
              </tr>
              <tr>
                <td class="label">ID Licencia:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedCertificacion.id_licencia || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(selectedCertificacion.tipo)">
                    {{ getTipoText(selectedCertificacion.tipo) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Partida Pago:</td>
                <td>{{ selectedCertificacion.partidapago?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span class="badge" :class="selectedCertificacion.vigente === 'S' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="selectedCertificacion.vigente === 'S' ? 'check-circle' : 'times-circle'" />
                    {{ selectedCertificacion.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Control y Observaciones
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedCertificacion.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturó:</td>
                <td>{{ selectedCertificacion.capturista?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label" colspan="2">Observaciones:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedCertificacion.observacion?.trim() || 'Sin observaciones' }}
                  </div>
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editCertificacion(selectedCertificacion); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Certificación
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notification -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'certificacionesfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const certificaciones = ref([])
const selectedCertificacion = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingCertificacion = ref(false)
const updatingCertificacion = ref(false)

// Filtros
const filters = ref({
  tipo: '',
  axo: null,
  folio: null,
  id_licencia: null
})

// Formularios
const newCertificacion = ref({
  axo: new Date().getFullYear(),
  folio: null,
  id_licencia: null,
  partidapago: '',
  observacion: '',
  vigente: 'S',
  tipo: ''
})

const editForm = ref({
  id: null,
  axo: null,
  folio: null,
  id_licencia: null,
  partidapago: '',
  observacion: '',
  vigente: 'S'
})

// Métodos
const loadCertificaciones = async () => {
  if (!filters.value.tipo) {
    showToast('warning', 'Por favor seleccione un tipo de certificación')
    return
  }

  setLoading(true, 'Cargando certificaciones...')

  try {
    const response = await execute(
      'SP_CERTIFICACIONES_LIST',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: filters.value.tipo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      certificaciones.value = response.result
      showToast('success', 'Certificaciones cargadas correctamente')
    } else {
      certificaciones.value = []
      showToast('error', 'Error al cargar certificaciones')
    }
  } catch (error) {
    handleApiError(error)
    certificaciones.value = []
  } finally {
    setLoading(false)
  }
}

const searchCertificaciones = () => {
  loadCertificaciones()
}

const clearFilters = () => {
  filters.value = {
    tipo: '',
    axo: null,
    folio: null,
    id_licencia: null
  }
  certificaciones.value = []
}

const openCreateModal = () => {
  newCertificacion.value = {
    axo: new Date().getFullYear(),
    folio: null,
    id_licencia: null,
    partidapago: '',
    observacion: '',
    vigente: 'S',
    tipo: filters.value.tipo || ''
  }
  showCreateModal.value = true
}

const createCertificacion = async () => {
  if (!newCertificacion.value.axo || !newCertificacion.value.folio || !newCertificacion.value.id_licencia || !newCertificacion.value.tipo) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de certificación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará una nueva certificación con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Año:</strong> ${newCertificacion.value.axo}</li>
          <li style="margin: 5px 0;"><strong>Folio:</strong> ${newCertificacion.value.folio}</li>
          <li style="margin: 5px 0;"><strong>ID Licencia:</strong> ${newCertificacion.value.id_licencia}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${getTipoText(newCertificacion.value.tipo)}</li>
          <li style="margin: 5px 0;"><strong>Vigente:</strong> ${newCertificacion.value.vigente === 'S' ? 'Sí' : 'No'}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear certificación',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingCertificacion.value = true

  try {
    const response = await execute(
      'SP_CERTIFICACIONES_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: newCertificacion.value.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: newCertificacion.value.folio, tipo: 'integer' },
        { nombre: 'p_id_licencia', valor: newCertificacion.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_partidapago', valor: newCertificacion.value.partidapago?.trim() || '', tipo: 'string' },
        { nombre: 'p_observacion', valor: newCertificacion.value.observacion?.trim() || '', tipo: 'string' },
        { nombre: 'p_vigente', valor: newCertificacion.value.vigente, tipo: 'string' },
        { nombre: 'p_tipo', valor: newCertificacion.value.tipo, tipo: 'string' },
        { nombre: 'p_capturista', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadCertificaciones()

      await Swal.fire({
        icon: 'success',
        title: 'Certificación creada!',
        text: 'La certificación ha sido creada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Certificación creada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear certificación',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear la certificación',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingCertificacion.value = false
  }
}

const editCertificacion = (cert) => {
  selectedCertificacion.value = cert
  editForm.value = {
    id: cert.id,
    axo: cert.axo,
    folio: cert.folio,
    id_licencia: cert.id_licencia,
    partidapago: cert.partidapago?.trim() || '',
    observacion: cert.observacion?.trim() || '',
    vigente: cert.vigente
  }
  showEditModal.value = true
}

const updateCertificacion = async () => {
  if (!editForm.value.id_licencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizarán los datos de la certificación:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>ID:</strong> ${editForm.value.id}</li>
          <li style="margin: 5px 0;"><strong>ID Licencia:</strong> ${editForm.value.id_licencia}</li>
          <li style="margin: 5px 0;"><strong>Vigente:</strong> ${editForm.value.vigente === 'S' ? 'Sí' : 'No'}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  updatingCertificacion.value = true

  try {
    const response = await execute(
      'SP_CERTIFICACIONES_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: editForm.value.id, tipo: 'integer' },
        { nombre: 'p_id_licencia', valor: editForm.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_partidapago', valor: editForm.value.partidapago?.trim() || '', tipo: 'string' },
        { nombre: 'p_observacion', valor: editForm.value.observacion?.trim() || '', tipo: 'string' },
        { nombre: 'p_vigente', valor: editForm.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadCertificaciones()

      await Swal.fire({
        icon: 'success',
        title: 'Certificación actualizada!',
        text: 'Los datos de la certificación han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Certificación actualizada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al actualizar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    updatingCertificacion.value = false
  }
}

const viewCertificacion = (cert) => {
  selectedCertificacion.value = cert
  showViewModal.value = true
}

const confirmCancelCertificacion = async (cert) => {
  const result = await Swal.fire({
    title: '¿Cancelar certificación?',
    text: `¿Está seguro de cancelar la certificación ID ${cert.id}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    await cancelCertificacion(cert)
  }
}

const cancelCertificacion = async (cert) => {
  try {
    const response = await execute(
      'SP_CERTIFICACIONES_CANCEL',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: cert.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadCertificaciones()

      await Swal.fire({
        icon: 'success',
        title: 'Certificación cancelada!',
        text: 'La certificación ha sido cancelada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Certificación cancelada exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getTipoBadgeClass = (tipo) => {
  const classes = {
    'A': 'badge-info',
    'L': 'badge-primary',
    'C': 'badge-warning'
  }
  return classes[tipo] || 'badge-secondary'
}

const getTipoText = (tipo) => {
  const tipos = {
    'A': 'Anuncio',
    'L': 'Licencia',
    'C': 'Constancia'
  }
  return tipos[tipo] || tipo
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  // No cargar automáticamente - usuario debe seleccionar tipo
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>

<style scoped>
.observaciones-box {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #dee2e6;
  min-height: 60px;
  white-space: pre-wrap;
}
</style>
