<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Empresas</h1>
        <p>Aseo Contratado - Gestión de Empresas Prestadoras de Servicio</p>
      </div>
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
          Nueva Empresa
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.search"
                placeholder="Nombre, representante o número..."
                @keyup.enter="searchEmpresas"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="searchEmpresas"
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
              @click="loadEmpresas"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
            <button
              class="btn-municipal-primary"
              @click="exportarExcel"
              :disabled="loading || empresas.length === 0"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Empresas Registradas
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No. Empresa</th>
                  <th>Control</th>
                  <th>Tipo</th>
                  <th>Descripción</th>
                  <th>Representante</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="empresas.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="building" size="2x" class="empty-icon" />
                    <p>No se encontraron empresas registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="empresa in empresas" :key="empresa.num_empresa" class="row-hover">
                  <td><strong class="text-primary">{{ empresa.num_empresa }}</strong></td>
                  <td><code class="text-muted">{{ empresa.ctrol_emp || 'N/A' }}</code></td>
                  <td>
                    <span class="badge-secondary">{{ empresa.tipo_empresa || 'N/A' }}</span>
                  </td>
                  <td>{{ empresa.descripcion }}</td>
                  <td>{{ empresa.representante || 'N/A' }}</td>
                  <td>
                    <span class="badge" :class="empresa.fecha_baja ? 'badge-danger' : 'badge-success'">
                      <font-awesome-icon :icon="empresa.fecha_baja ? 'times-circle' : 'check-circle'" />
                      {{ empresa.fecha_baja ? 'Inactiva' : 'Activa' }}
                    </span>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="viewEmpresa(empresa)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editEmpresa(empresa)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="!empresa.fecha_baja"
                        class="btn-municipal-secondary btn-sm"
                        @click="confirmDeleteEmpresa(empresa)"
                        title="Dar de baja"
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
        <div class="pagination-container" v-if="totalRecords > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
            de {{ totalRecords }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="itemsPerPage" @change="changePageSize">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === currentPage }"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading && empresas.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando empresas...</p>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Empresa"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createEmpresa"
      :loading="creatingEmpresa"
      confirmText="Crear Empresa"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createEmpresa">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Control Empresa:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.ctrol_emp"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo:</label>
            <select class="municipal-form-control" v-model="newEmpresa.tipo_empresa">
              <option value="">Seleccionar...</option>
              <option value="PUBLICA">Pública</option>
              <option value="PRIVADA">Privada</option>
              <option value="MIXTA">Mixta</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción / Nombre: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newEmpresa.descripcion"
            maxlength="100"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Representante:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newEmpresa.representante"
            maxlength="100"
          />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Teléfono:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.telefono"
              maxlength="20"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Email:</label>
            <input
              type="email"
              class="municipal-form-control"
              v-model="newEmpresa.email"
              maxlength="100"
            />
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Dirección:</label>
          <textarea
            class="municipal-form-control"
            v-model="newEmpresa.direccion"
            rows="2"
            maxlength="200"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Empresa: ${selectedEmpresa?.descripcion}`"
      size="lg"
      @close="showEditModal = false"
      @confirm="updateEmpresa"
      :loading="updatingEmpresa"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateEmpresa">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">No. Empresa:</label>
            <input
              type="text"
              class="municipal-form-control"
              :value="editForm.num_empresa"
              disabled
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Control:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.ctrol_emp"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Tipo:</label>
            <select class="municipal-form-control" v-model="editForm.tipo_empresa">
              <option value="">Seleccionar...</option>
              <option value="PUBLICA">Pública</option>
              <option value="PRIVADA">Privada</option>
              <option value="MIXTA">Mixta</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción / Nombre: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.descripcion"
            maxlength="100"
            required
          />
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Representante:</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.representante"
            maxlength="100"
          />
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Teléfono:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.telefono"
              maxlength="20"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Email:</label>
            <input
              type="email"
              class="municipal-form-control"
              v-model="editForm.email"
              maxlength="100"
            />
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Dirección:</label>
          <textarea
            class="municipal-form-control"
            v-model="editForm.direccion"
            rows="2"
            maxlength="200"
          ></textarea>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Fecha de Baja (opcional):</label>
          <input
            type="date"
            class="municipal-form-control"
            v-model="editForm.fecha_baja"
          />
          <small class="form-text">
            Establezca una fecha para dar de baja la empresa
          </small>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de la Empresa: ${selectedEmpresa?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedEmpresa" class="empresa-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información Básica
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">No. Empresa:</td>
                <td><code>{{ selectedEmpresa.num_empresa }}</code></td>
              </tr>
              <tr>
                <td class="label">Control:</td>
                <td>{{ selectedEmpresa.ctrol_emp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge-secondary">{{ selectedEmpresa.tipo_empresa || 'N/A' }}</span>
                </td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedEmpresa.descripcion }}</td>
              </tr>
              <tr>
                <td class="label">Representante:</td>
                <td>{{ selectedEmpresa.representante || 'N/A' }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="address-card" />
              Datos de Contacto
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Teléfono:</td>
                <td>
                  <font-awesome-icon icon="phone" class="text-info" />
                  {{ selectedEmpresa.telefono || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>
                  <font-awesome-icon icon="envelope" class="text-info" />
                  {{ selectedEmpresa.email || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Dirección:</td>
                <td>
                  <font-awesome-icon icon="map-marker-alt" class="text-info" />
                  {{ selectedEmpresa.direccion || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="selectedEmpresa.fecha_baja ? 'badge-danger' : 'badge-success'">
                    <font-awesome-icon :icon="selectedEmpresa.fecha_baja ? 'times-circle' : 'check-circle'" />
                    {{ selectedEmpresa.fecha_baja ? 'Inactiva' : 'Activa' }}
                  </span>
                </td>
              </tr>
              <tr v-if="selectedEmpresa.fecha_baja">
                <td class="label">Fecha Baja:</td>
                <td>
                  <font-awesome-icon icon="calendar-times" class="text-danger" />
                  {{ formatDate(selectedEmpresa.fecha_baja) }}
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
          <button class="btn-municipal-primary" @click="editEmpresa(selectedEmpresa); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Empresa
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ABC_Empresas'"
    :moduleName="'aseo_contratado'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
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
const empresas = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedEmpresa = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingEmpresa = ref(false)
const updatingEmpresa = ref(false)

// Filtros
const filters = ref({
  search: ''
})

// Formularios
const newEmpresa = ref({
  ctrol_emp: null,
  tipo_empresa: '',
  descripcion: '',
  representante: '',
  telefono: '',
  email: '',
  direccion: ''
})

const editForm = ref({
  num_empresa: null,
  ctrol_emp: null,
  tipo_empresa: '',
  descripcion: '',
  representante: '',
  telefono: '',
  email: '',
  direccion: '',
  fecha_baja: null
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const loadEmpresas = async () => {
  setLoading(true, 'Cargando empresas...')

  try {
    const response = await execute(
      'SP_ASEO_EMPRESAS_LIST',
      'aseo_contratado',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_search', valor: filters.value.search || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      empresas.value = response.result
      if (empresas.value.length > 0) {
        totalRecords.value = parseInt(empresas.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Empresas cargadas correctamente')
    } else {
      empresas.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar empresas')
    }
  } catch (error) {
    handleApiError(error)
    empresas.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchEmpresas = () => {
  currentPage.value = 1
  loadEmpresas()
}

const clearFilters = () => {
  filters.value = {
    search: ''
  }
  currentPage.value = 1
  loadEmpresas()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadEmpresas()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadEmpresas()
}

const openCreateModal = () => {
  newEmpresa.value = {
    ctrol_emp: null,
    tipo_empresa: '',
    descripcion: '',
    representante: '',
    telefono: '',
    email: '',
    direccion: ''
  }
  showCreateModal.value = true
}

const createEmpresa = async () => {
  if (!newEmpresa.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de empresa?',
    html: `
      <p>Se creará una nueva empresa con los siguientes datos:</p>
      <ul class="list-unstyled-left">
        <li><strong>Descripción:</strong> ${newEmpresa.value.descripcion}</li>
        <li><strong>Representante:</strong> ${newEmpresa.value.representante || 'N/A'}</li>
        <li><strong>Tipo:</strong> ${newEmpresa.value.tipo_empresa || 'N/A'}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear empresa',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingEmpresa.value = true

  try {
    const response = await execute(
      'SP_ASEO_EMPRESAS_CREATE',
      'aseo_contratado',
      [
        { nombre: 'p_ctrol_emp', valor: newEmpresa.value.ctrol_emp },
        { nombre: 'p_tipo_empresa', valor: newEmpresa.value.tipo_empresa },
        { nombre: 'p_descripcion', valor: newEmpresa.value.descripcion },
        { nombre: 'p_representante', valor: newEmpresa.value.representante },
        { nombre: 'p_telefono', valor: newEmpresa.value.telefono },
        { nombre: 'p_email', valor: newEmpresa.value.email },
        { nombre: 'p_direccion', valor: newEmpresa.value.direccion },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadEmpresas()

      await Swal.fire({
        icon: 'success',
        title: '¡Empresa creada!',
        text: 'La empresa ha sido creada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Empresa creada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear empresa',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingEmpresa.value = false
  }
}

const editEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  editForm.value = {
    num_empresa: empresa.num_empresa,
    ctrol_emp: empresa.ctrol_emp,
    tipo_empresa: empresa.tipo_empresa || '',
    descripcion: empresa.descripcion,
    representante: empresa.representante || '',
    telefono: empresa.telefono || '',
    email: empresa.email || '',
    direccion: empresa.direccion || '',
    fecha_baja: empresa.fecha_baja ? empresa.fecha_baja.split('T')[0] : null
  }
  showEditModal.value = true
}

const updateEmpresa = async () => {
  if (!editForm.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La descripción es obligatoria',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <p>Se actualizarán los datos de la empresa:</p>
      <ul class="list-unstyled-left">
        <li><strong>No. Empresa:</strong> ${editForm.value.num_empresa}</li>
        <li><strong>Descripción:</strong> ${editForm.value.descripcion}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingEmpresa.value = true

  try {
    const response = await execute(
      'SP_ASEO_EMPRESAS_UPDATE',
      'aseo_contratado',
      [
        { nombre: 'p_num_empresa', valor: editForm.value.num_empresa },
        { nombre: 'p_ctrol_emp', valor: editForm.value.ctrol_emp },
        { nombre: 'p_tipo_empresa', valor: editForm.value.tipo_empresa },
        { nombre: 'p_descripcion', valor: editForm.value.descripcion },
        { nombre: 'p_representante', valor: editForm.value.representante },
        { nombre: 'p_telefono', valor: editForm.value.telefono },
        { nombre: 'p_email', valor: editForm.value.email },
        { nombre: 'p_direccion', valor: editForm.value.direccion },
        { nombre: 'p_fecha_baja', valor: editForm.value.fecha_baja || null },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadEmpresas()

      await Swal.fire({
        icon: 'success',
        title: '¡Empresa actualizada!',
        text: 'Los datos han sido actualizados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Empresa actualizada exitosamente')
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
    updatingEmpresa.value = false
  }
}

const viewEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  showViewModal.value = true
}

const confirmDeleteEmpresa = async (empresa) => {
  const result = await Swal.fire({
    title: '¿Dar de baja empresa?',
    html: `
      <p>¿Está seguro de dar de baja la empresa:</p>
      <p><strong>${empresa.descripcion}</strong>?</p>
      <p class="text-danger">Esta acción marcará la empresa como inactiva</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteEmpresa(empresa)
  }
}

const deleteEmpresa = async (empresa) => {
  try {
    const response = await execute(
      'SP_ASEO_EMPRESAS_DELETE',
      'aseo_contratado',
      [
        { nombre: 'p_num_empresa', valor: empresa.num_empresa },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadEmpresas()

      await Swal.fire({
        icon: 'success',
        title: '¡Empresa dada de baja!',
        text: 'La empresa ha sido desactivada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Empresa dada de baja exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'Error al dar de baja la empresa',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  }
}

const exportarExcel = async () => {
  await Swal.fire({
    title: 'Exportar a Excel',
    text: 'Funcionalidad en desarrollo',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
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
  loadEmpresas()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
