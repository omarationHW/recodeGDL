<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map" />
      </div>
      <div class="module-view-info">
        <h1>Dictamen de Uso de Suelo</h1>
        <p>Padrón de Licencias - Gestión de Constancias de Uso de Suelo</p></div>
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
            @click="loadConstancias"
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
          Constancias de Uso de Suelo
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="constancias.length > 0">
            {{ constancias.length }} registros
          </span>
        </div>
      </div>

      <div class="municipal-card-body">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="constancias.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="map" size="3x" />
          </div>
          <h4>Dictamen de Uso de Suelo</h4>
          <p>Utilice los filtros de búsqueda para consultar las constancias de uso de suelo</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="constancias.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron constancias con los criterios especificados</p>
        </div>

        <!-- Tabla con resultados -->
        <div v-else class="table-responsive">
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
              <tr
                v-for="(const_item, index) in paginatedConstancias"
                :key="index"
                @click="selectedRow = const_item"
                :class="{ 'table-row-selected': selectedRow === const_item }"
                class="row-hover"
              >
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
                      @click.stop="viewConstancia(const_item)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="editConstancia(const_item)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      v-if="const_item.vigente === 'V'"
                      class="btn-municipal-danger btn-sm"
                      @click.stop="confirmCancelConstancia(const_item)"
                      title="Cancelar"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div v-if="constancias.length > 0" class="pagination-controls">
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
      :componentName="'dictamenusodesuelo'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Dictamen de Uso de Suelo'"
      @close="showDocModal = false"
    />
  </div>
  <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
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
const constancias = ref([])
const selectedConstancia = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
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
  showLoading('Cargando constancias...', 'Consultando registros')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_list_constancias',
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
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      constancias.value = response.result
      showToast('success', `Constancias cargadas en ${duration}s`, duration)
    } else {
      constancias.value = []
      showToast('error', 'Error al cargar constancias')
    }
  } catch (error) {
    handleApiError(error)
    constancias.value = []
  } finally {
    hideLoading()
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
  constancias.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
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
      <div class="swal-confirmation-text">
        <p>Se creará una nueva constancia con los siguientes datos:</p>
        <ul>
          <li><strong>Solicita:</strong> ${newConstancia.value.solicita}</li>
          <li><strong>Tipo:</strong> ${getTipoText(newConstancia.value.tipo)}</li>
          <li><strong>Domicilio:</strong> ${newConstancia.value.domicilio || 'N/A'}</li>
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
  const startTime = performance.now()
  const usuario = localStorage.getItem('usuario') || 'sistema'

  try {
    const response = await execute(
      'sp_create_constancia',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: parseInt(newConstancia.value.tipo), tipo: 'integer' },
        { nombre: 'p_solicita', valor: newConstancia.value.solicita.trim(), tipo: 'string' },
        { nombre: 'p_partidapago', valor: newConstancia.value.partidapago?.trim() || null, tipo: 'string' },
        { nombre: 'p_observacion', valor: newConstancia.value.observacion?.trim() || null, tipo: 'string' },
        { nombre: 'p_domicilio', valor: newConstancia.value.domicilio?.trim() || null, tipo: 'string' },
        { nombre: 'p_id_licencia', valor: newConstancia.value.id_licencia || null, tipo: 'integer' },
        { nombre: 'p_capturista', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]) {
      showCreateModal.value = false
      loadConstancias()

      await Swal.fire({
        icon: 'success',
        title: 'Constancia creada!',
        html: `
          <div class="swal-confirmation-text">
            <p><strong>Año:</strong> ${response.result[0].axo}</p>
            <p><strong>Folio:</strong> ${response.result[0].folio}</p>
            <p><strong>Tiempo:</strong> ${duration}s</p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', `Constancia creada en ${duration}s`)
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
      <div class="swal-confirmation-text">
        <p>Se actualizarán los datos de la constancia:</p>
        <ul>
          <li><strong>Año-Folio:</strong> ${editForm.value.axo}-${editForm.value.folio}</li>
          <li><strong>Solicita:</strong> ${editForm.value.solicita}</li>
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
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_update_constancia',
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
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

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

      showToast('success', `Constancia actualizada en ${duration}s`)
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
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_cancel_constancia',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
      ],
      'guadalajara'
    )
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      loadConstancias()

      await Swal.fire({
        icon: 'success',
        title: 'Constancia cancelada!',
        text: 'La constancia ha sido cancelada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `Constancia cancelada en ${duration}s`)
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
    '4': 'badge-purple'
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
  } catch {
    return 'Fecha inválida'
  }
}

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => constancias.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedConstancias = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return constancias.value.slice(start, end)
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

// Lifecycle
onMounted(() => {
  // No cargar automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
