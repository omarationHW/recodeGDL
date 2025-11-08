<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="map" />
      </div>
      <div class="module-view-info">
        <h1>Dictamen de Uso de Suelo</h1>
        <p>Padrón de Licencias - Gestión de Constancias de Uso de Suelo</p></div>
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
          Nueva Constancia
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
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
          <div class="form-group">
            <label class="municipal-form-label">Fecha Captura Desde</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.feccap_ini"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Captura Hasta</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.feccap_fin"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchConstancias"
            :disabled="loading"
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
            @click="loadConstancias"
            :disabled="loading"
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
          Constancias de Uso de Suelo
          <span class="badge-info" v-if="constancias.length > 0">{{ constancias.length }} registros</span>
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
                <th>Año</th>
                <th>Folio</th>
                <th>Tipo</th>
                <th>Solicita</th>
                <th>ID Licencia</th>
                <th>Domicilio</th>
                <th>Vigente</th>
                <th>Fecha Captura</th>
                <th>Capturista</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(const_item, index) in constancias" :key="index" class="row-hover">
                <td><strong class="text-primary">{{ const_item.axo }}</strong></td>
                <td><code class="text-muted">{{ const_item.folio }}</code></td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(const_item.tipo)">
                    {{ getTipoText(const_item.tipo) }}
                  </span>
                </td>
                <td>{{ const_item.solicita?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">
                    {{ const_item.id_licencia || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="domicilio-text">{{ const_item.domicilio?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <span class="badge" :class="const_item.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="const_item.vigente === 'V' ? 'check-circle' : 'times-circle'" />
                    {{ const_item.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(const_item.feccap) }}
                  </small>
                </td>
                <td>{{ const_item.capturista?.trim() || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewConstancia(const_item)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editConstancia(const_item)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      v-if="const_item.vigente === 'V'"
                      class="btn-municipal-danger btn-sm"
                      @click="confirmCancelConstancia(const_item)"
                      title="Cancelar"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="constancias.length === 0 && !loading">
                <td colspan="10" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron constancias con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && constancias.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando constancias...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Constancia de Uso de Suelo"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createConstancia"
      :loading="creatingConstancia"
      confirmText="Crear Constancia"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createConstancia">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newConstancia.tipo" required>
              <option value="">Seleccionar...</option>
              <option value="1">Tipo 1 - Uso de Suelo Habitacional</option>
              <option value="2">Tipo 2 - Uso de Suelo Comercial</option>
              <option value="3">Tipo 3 - Uso de Suelo Industrial</option>
              <option value="4">Tipo 4 - Uso de Suelo Mixto</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Licencia:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newConstancia.id_licencia"
              placeholder="ID de licencia relacionada"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Solicita: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newConstancia.solicita"
            maxlength="200"
            required
            placeholder="Nombre de quien solicita"
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Partida Pago:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newConstancia.partidapago"
              maxlength="50"
              placeholder="Partida de pago"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Domicilio:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newConstancia.domicilio"
            maxlength="200"
            placeholder="Domicilio del predio"
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="newConstancia.observacion"
            rows="3"
            maxlength="500"
            placeholder="Observaciones y comentarios"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Constancia ${selectedConstancia?.axo}-${selectedConstancia?.folio}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="updateConstancia"
      :loading="updatingConstancia"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateConstancia">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Año (No editable):</label>
            <input
              type="number"
              class="municipal-form-control"
              :value="editForm.axo"
              disabled
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio (No editable):</label>
            <input
              type="number"
              class="municipal-form-control"
              :value="editForm.folio"
              disabled
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo:</label>
            <select class="municipal-form-control" v-model="editForm.tipo">
              <option value="1">Tipo 1 - Uso de Suelo Habitacional</option>
              <option value="2">Tipo 2 - Uso de Suelo Comercial</option>
              <option value="3">Tipo 3 - Uso de Suelo Industrial</option>
              <option value="4">Tipo 4 - Uso de Suelo Mixto</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Licencia:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.id_licencia"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Solicita: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.solicita"
            maxlength="200"
            required
          >
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
            <label class="municipal-form-label">Vigente:</label>
            <select class="municipal-form-control" v-model="editForm.vigente">
              <option value="V">Vigente</option>
              <option value="C">Cancelado</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Domicilio:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.domicilio"
            maxlength="200"
          >
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
      :title="`Detalle Constancia ${selectedConstancia?.axo}-${selectedConstancia?.folio}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedConstancia" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Información de la Constancia
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Año:</td>
                <td><strong>{{ selectedConstancia.axo }}</strong></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td><code>{{ selectedConstancia.folio }}</code></td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(selectedConstancia.tipo)">
                    {{ getTipoText(selectedConstancia.tipo) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Solicita:</td>
                <td>{{ selectedConstancia.solicita?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">ID Licencia:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedConstancia.id_licencia || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Partida Pago:</td>
                <td>{{ selectedConstancia.partidapago?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span class="badge" :class="selectedConstancia.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="selectedConstancia.vigente === 'V' ? 'check-circle' : 'times-circle'" />
                    {{ selectedConstancia.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Datos Adicionales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedConstancia.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturista:</td>
                <td>{{ selectedConstancia.capturista?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label" colspan="2">Domicilio:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedConstancia.domicilio?.trim() || 'N/A' }}
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label" colspan="2">Observaciones:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedConstancia.observacion?.trim() || 'Sin observaciones' }}
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
          <button class="btn-municipal-primary" @click="editConstancia(selectedConstancia); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Constancia
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
      :componentName="'dictamenusodesuelo'"
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
const constancias = ref([])
const selectedConstancia = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingConstancia = ref(false)
const updatingConstancia = ref(false)

// Filtros
const filters = ref({
  axo: null,
  folio: null,
  id_licencia: null,
  feccap_ini: '',
  feccap_fin: ''
})

// Formularios
const newConstancia = ref({
  tipo: '',
  solicita: '',
  partidapago: '',
  observacion: '',
  domicilio: '',
  id_licencia: null
})

const editForm = ref({
  axo: null,
  folio: null,
  tipo: '',
  solicita: '',
  partidapago: '',
  observacion: '',
  domicilio: '',
  id_licencia: null,
  vigente: 'V'
})

// Métodos
const loadConstancias = async () => {
  setLoading(true, 'Cargando constancias...')

  try {
    const response = await execute(
      'SP_LIST_CONSTANCIAS',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: filters.value.axo || null, tipo: 'integer' },
        { nombre: 'p_folio', valor: filters.value.folio || null, tipo: 'integer' },
        { nombre: 'p_id_licencia', valor: filters.value.id_licencia || null, tipo: 'integer' },
        { nombre: 'p_feccap_ini', valor: filters.value.feccap_ini || null, tipo: 'string' },
        { nombre: 'p_feccap_fin', valor: filters.value.feccap_fin || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      constancias.value = response.result
      showToast('success', 'Constancias cargadas correctamente')
    } else {
      constancias.value = []
      showToast('error', 'Error al cargar constancias')
    }
  } catch (error) {
    handleApiError(error)
    constancias.value = []
  } finally {
    setLoading(false)
  }
}

const searchConstancias = () => {
  loadConstancias()
}

const clearFilters = () => {
  filters.value = {
    axo: null,
    folio: null,
    id_licencia: null,
    feccap_ini: '',
    feccap_fin: ''
  }
  loadConstancias()
}

const openCreateModal = () => {
  newConstancia.value = {
    tipo: '',
    solicita: '',
    partidapago: '',
    observacion: '',
    domicilio: '',
    id_licencia: null
  }
  showCreateModal.value = true
}

const createConstancia = async () => {
  if (!newConstancia.value.tipo || !newConstancia.value.solicita) {
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
    title: '¿Confirmar creación de constancia?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará una nueva constancia con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Solicita:</strong> ${newConstancia.value.solicita}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${getTipoText(newConstancia.value.tipo)}</li>
          <li style="margin: 5px 0;"><strong>Domicilio:</strong> ${newConstancia.value.domicilio || 'N/A'}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear constancia',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingConstancia.value = true

  try {
    const response = await execute(
      'SP_CREATE_CONSTANCIA',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: parseInt(newConstancia.value.tipo), tipo: 'integer' },
        { nombre: 'p_solicita', valor: newConstancia.value.solicita.trim(), tipo: 'string' },
        { nombre: 'p_partidapago', valor: newConstancia.value.partidapago?.trim() || null, tipo: 'string' },
        { nombre: 'p_observacion', valor: newConstancia.value.observacion?.trim() || null, tipo: 'string' },
        { nombre: 'p_domicilio', valor: newConstancia.value.domicilio?.trim() || null, tipo: 'string' },
        { nombre: 'p_id_licencia', valor: newConstancia.value.id_licencia || null, tipo: 'integer' },
        { nombre: 'p_capturista', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      showCreateModal.value = false
      loadConstancias()

      await Swal.fire({
        icon: 'success',
        title: 'Constancia creada!',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>Año:</strong> ${response.result[0].axo}</p>
            <p><strong>Folio:</strong> ${response.result[0].folio}</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', 'Constancia creada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear constancia',
        text: 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear la constancia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingConstancia.value = false
  }
}

const editConstancia = (constancia) => {
  selectedConstancia.value = constancia
  editForm.value = {
    axo: constancia.axo,
    folio: constancia.folio,
    tipo: constancia.tipo?.toString() || '',
    solicita: constancia.solicita?.trim() || '',
    partidapago: constancia.partidapago?.trim() || '',
    observacion: constancia.observacion?.trim() || '',
    domicilio: constancia.domicilio?.trim() || '',
    id_licencia: constancia.id_licencia,
    vigente: constancia.vigente
  }
  showEditModal.value = true
}

const updateConstancia = async () => {
  if (!editForm.value.solicita) {
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
        <p style="margin-bottom: 10px;">Se actualizarán los datos de la constancia:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Año-Folio:</strong> ${editForm.value.axo}-${editForm.value.folio}</li>
          <li style="margin: 5px 0;"><strong>Solicita:</strong> ${editForm.value.solicita}</li>
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

  updatingConstancia.value = true

  try {
    const response = await execute(
      'SP_UPDATE_CONSTANCIA',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: editForm.value.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: editForm.value.folio, tipo: 'integer' },
        { nombre: 'p_tipo', valor: parseInt(editForm.value.tipo), tipo: 'integer' },
        { nombre: 'p_solicita', valor: editForm.value.solicita.trim(), tipo: 'string' },
        { nombre: 'p_partidapago', valor: editForm.value.partidapago?.trim() || null, tipo: 'string' },
        { nombre: 'p_observacion', valor: editForm.value.observacion?.trim() || null, tipo: 'string' },
        { nombre: 'p_domicilio', valor: editForm.value.domicilio?.trim() || null, tipo: 'string' },
        { nombre: 'p_id_licencia', valor: editForm.value.id_licencia || null, tipo: 'integer' },
        { nombre: 'p_vigente', valor: editForm.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadConstancias()

      await Swal.fire({
        icon: 'success',
        title: 'Constancia actualizada!',
        text: 'Los datos de la constancia han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Constancia actualizada exitosamente')
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
    updatingConstancia.value = false
  }
}

const viewConstancia = (constancia) => {
  selectedConstancia.value = constancia
  showViewModal.value = true
}

const confirmCancelConstancia = async (constancia) => {
  const result = await Swal.fire({
    title: '¿Cancelar constancia?',
    text: `¿Está seguro de cancelar la constancia ${constancia.axo}-${constancia.folio}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    await cancelConstancia(constancia)
  }
}

const cancelConstancia = async (constancia) => {
  try {
    const response = await execute(
      'SP_CANCEL_CONSTANCIA',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadConstancias()

      await Swal.fire({
        icon: 'success',
        title: 'Constancia cancelada!',
        text: 'La constancia ha sido cancelada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Constancia cancelada exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getTipoBadgeClass = (tipo) => {
  const classes = {
    '1': 'badge-primary',
    '2': 'badge-success',
    '3': 'badge-warning',
    '4': 'badge-info'
  }
  return classes[tipo?.toString()] || 'badge-secondary'
}

const getTipoText = (tipo) => {
  const tipos = {
    '1': 'Habitacional',
    '2': 'Comercial',
    '3': 'Industrial',
    '4': 'Mixto'
  }
  return tipos[tipo?.toString()] || tipo
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
  loadConstancias()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>

<style scoped>
.domicilio-text {
  display: block;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.observaciones-box {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #dee2e6;
  min-height: 60px;
  white-space: pre-wrap;
}

.details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  .details-grid {
    grid-template-columns: 1fr;
  }
}

.required {
  color: #dc3545;
}
</style>
