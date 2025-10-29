<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Usuarios</h1>
        <p>Padrón de Licencias - Gestión de Usuarios del Sistema</p></div>
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
          Nuevo Usuario
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Usuario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.usuario"
              placeholder="Nombre de usuario"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Nombre Completo</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombres"
              placeholder="Nombre completo"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Departamento</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.cvedepto"
              placeholder="Clave departamento"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Nivel</label>
            <select class="municipal-form-control" v-model="filters.nivel">
              <option value="">Todos los niveles</option>
              <option value="1">Nivel 1 - Básico</option>
              <option value="5">Nivel 5 - Intermedio</option>
              <option value="9">Nivel 9 - Avanzado</option>
              <option value="10">Nivel 10 - Administrador</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchUsuarios"
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
            @click="loadUsuarios"
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
          Resultados de Búsqueda
          <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
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
                <th>Usuario</th>
                <th>Nombre</th>
                <th>Clave</th>
                <th>Depto</th>
                <th>Nivel</th>
                <th>Fecha Alta</th>
                <th>Fecha Baja</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="usuario in usuarios" :key="usuario.usuario" class="row-hover">
                <td><strong class="text-primary">{{ usuario.usuario?.trim() }}</strong></td>
                <td>{{ usuario.nombres?.trim() || 'N/A' }}</td>
                <td><code class="text-muted">{{ usuario.clave?.trim() || 'Sin clave' }}</code></td>
                <td>
                  <span class="badge-secondary">
                    {{ usuario.cvedepto || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getLevelBadgeClass(usuario.nivel)">
                    <font-awesome-icon icon="user-shield" />
                    Nivel {{ usuario.nivel || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(usuario.fecalt) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDate(usuario.fecbaj) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(usuario.fecbaj)">
                    <font-awesome-icon :icon="getStatusIcon(usuario.fecbaj)" />
                    {{ getStatusText(usuario.fecbaj) }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewUsuario(usuario)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editUsuario(usuario)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      v-if="!usuario.fecbaj"
                      class="btn-municipal-secondary btn-sm"
                      @click="confirmDeactivateUsuario(usuario)"
                      title="Dar de baja"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="usuarios.length === 0 && !loading">
                <td colspan="9" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron usuarios con los criterios especificados</p>
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
    <div v-if="loading && usuarios.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando usuarios del sistema...</p>
      </div>
    </div>

    <!-- Modal de creación usando componente Modal -->
    <Modal
      :show="showCreateModal"
      title="Crear Nuevo Usuario"
      size="xl"
      @close="showCreateModal = false"
      @confirm="createUsuario"
      :loading="creatingUsuario"
      confirmText="Crear Usuario"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createUsuario">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Usuario: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newUsuario.usuario"
              maxlength="8"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newUsuario.clave"
              maxlength="8"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombres: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="newUsuario.nombres"
            maxlength="30"
            required
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Departamento: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newUsuario.cvedepto"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Nivel: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="newUsuario.nivel" required>
              <option value="">Seleccionar...</option>
              <option value="1">Nivel 1 - Básico</option>
              <option value="5">Nivel 5 - Intermedio</option>
              <option value="9">Nivel 9 - Avanzado</option>
              <option value="10">Nivel 10 - Administrador</option>
            </select>
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Usuario: ${selectedUsuario?.usuario}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="updateUsuario"
      :loading="updatingUsuario"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="updateUsuario">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Usuario (No editable):</label>
            <input
              type="text"
              class="municipal-form-control"
              :value="editForm.usuario"
              disabled
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Nueva Clave (opcional):</label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="editForm.clave"
              maxlength="8"
              placeholder="Dejar vacío para mantener actual"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombres Completos: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="editForm.nombres"
            maxlength="30"
            required
          >
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Departamento: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.cvedepto"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Nivel de Acceso: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="editForm.nivel" required>
              <option value="1">Nivel 1 - Básico</option>
              <option value="5">Nivel 5 - Intermedio</option>
              <option value="9">Nivel 9 - Avanzado</option>
              <option value="10">Nivel 10 - Administrador</option>
            </select>
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Fecha de Baja (opcional):</label>
          <input
            type="date"
            class="municipal-form-control"
            v-model="editForm.fecbaj"
          >
          <small class="form-text">
            Establezca una fecha para dar de baja al usuario
          </small>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Usuario: ${selectedUsuario?.usuario}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedUsuario" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información Básica
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Usuario:</td>
                <td><code>{{ selectedUsuario.usuario?.trim() }}</code></td>
              </tr>
              <tr>
                <td class="label">Nombres:</td>
                <td>{{ selectedUsuario.nombres?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Clave:</td>
                <td><span class="text-muted">{{ selectedUsuario.clave?.trim() ? '***oculto***' : 'Sin clave' }}</span></td>
              </tr>
              <tr>
                <td class="label">Departamento:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedUsuario.cvedepto || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Nivel:</td>
                <td>
                  <span class="badge" :class="getLevelBadgeClass(selectedUsuario.nivel)">
                    <font-awesome-icon icon="user-shield" />
                    Nivel {{ selectedUsuario.nivel || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Fechas y Control
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Alta:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedUsuario.fecalt) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Baja:</td>
                <td>
                  <font-awesome-icon icon="calendar-minus" class="text-danger" />
                  {{ formatDate(selectedUsuario.fecbaj) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="clock" class="text-info" />
                  {{ formatDate(selectedUsuario.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturó:</td>
                <td>{{ selectedUsuario.capturo?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(selectedUsuario.fecbaj)">
                    <font-awesome-icon :icon="getStatusIcon(selectedUsuario.fecbaj)" />
                    {{ getStatusText(selectedUsuario.fecbaj) }}
                  </span>
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
          <button class="btn-municipal-primary" @click="editUsuario(selectedUsuario); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Usuario
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
      :componentName="'consultausuariosfrm'"
      :moduleName="'padron_licencias'"
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
const usuarios = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const selectedUsuario = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingUsuario = ref(false)
const updatingUsuario = ref(false)

// Filtros
const filters = ref({
  usuario: '',
  nombres: '',
  cvedepto: '',
  nivel: ''
})

// Formularios
const newUsuario = ref({
  usuario: '',
  cvedepto: null,
  nombres: '',
  clave: '',
  nivel: null
})

const editForm = ref({
  usuario: '',
  cvedepto: null,
  nombres: '',
  clave: '',
  nivel: null,
  fecbaj: null
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
const loadUsuarios = async () => {
  setLoading(true, 'Cargando usuarios...')

  try {
    const searchTerms = []
    if (filters.value.usuario) searchTerms.push(filters.value.usuario)
    if (filters.value.nombres) searchTerms.push(filters.value.nombres)
    if (filters.value.cvedepto) searchTerms.push(filters.value.cvedepto)
    if (filters.value.nivel) searchTerms.push(filters.value.nivel)

    const searchTerm = searchTerms.join(' ')

    const response = await execute(
      'SP_CONSULTAUSUARIOS_LIST',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_search', valor: searchTerm || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      usuarios.value = response.result
      if (usuarios.value.length > 0) {
        totalRecords.value = parseInt(usuarios.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Usuarios cargados correctamente')
    } else {
      usuarios.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar usuarios')
    }
  } catch (error) {
    handleApiError(error)
    usuarios.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchUsuarios = () => {
  currentPage.value = 1
  loadUsuarios()
}

const clearFilters = () => {
  filters.value = {
    usuario: '',
    nombres: '',
    cvedepto: '',
    nivel: ''
  }
  currentPage.value = 1
  loadUsuarios()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadUsuarios()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadUsuarios()
}

const openCreateModal = () => {
  newUsuario.value = {
    usuario: '',
    cvedepto: null,
    nombres: '',
    clave: '',
    nivel: null
  }
  showCreateModal.value = true
}

const createUsuario = async () => {
  if (!newUsuario.value.usuario || !newUsuario.value.nombres || !newUsuario.value.cvedepto || !newUsuario.value.nivel) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Mensaje de confirmación antes de crear
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de usuario?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo usuario con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${newUsuario.value.usuario.trim().toUpperCase()}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${newUsuario.value.nombres}</li>
          <li style="margin: 5px 0;"><strong>Departamento:</strong> ${newUsuario.value.cvedepto}</li>
          <li style="margin: 5px 0;"><strong>Nivel:</strong> ${newUsuario.value.nivel}</li>
          ${newUsuario.value.clave ? '<li style="margin: 5px 0;"><strong>Clave:</strong> Se asignará</li>' : ''}
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear usuario',
    cancelButtonText: 'Cancelar'
  })

  // Si el usuario cancela, no continuar
  if (!confirmResult.isConfirmed) {
    return
  }

  creatingUsuario.value = true

  try {
    const response = await execute(
      'SP_CONSULTAUSUARIOS_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: newUsuario.value.usuario.trim().toUpperCase() },
        { nombre: 'p_cvedepto', valor: newUsuario.value.cvedepto },
        { nombre: 'p_nombres', valor: newUsuario.value.nombres.trim() },
        { nombre: 'p_clave', valor: newUsuario.value.clave?.trim() || '' },
        { nombre: 'p_nivel', valor: newUsuario.value.nivel },
        { nombre: 'p_capturo', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showCreateModal.value = false
      loadUsuarios()

      await Swal.fire({
        icon: 'success',
        title: '¡Usuario creado!',
        text: 'El usuario ha sido creado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Usuario creado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al crear usuario',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el usuario',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    creatingUsuario.value = false
  }
}

const editUsuario = (usuario) => {
  selectedUsuario.value = usuario
  editForm.value = {
    usuario: usuario.usuario?.trim(),
    cvedepto: usuario.cvedepto,
    nombres: usuario.nombres?.trim() || '',
    clave: '',
    nivel: usuario.nivel,
    fecbaj: usuario.fecbaj ? usuario.fecbaj.split('T')[0] : null
  }
  showEditModal.value = true
}

const updateUsuario = async () => {
  console.log('🔵 updateUsuario llamado')
  console.log('📝 Datos del formulario:', editForm.value)

  if (!editForm.value.nombres || !editForm.value.cvedepto || !editForm.value.nivel) {
    console.log('⚠️ Validación fallida - campos requeridos faltantes')
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Mensaje de confirmación antes de guardar
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizarán los datos del usuario:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${editForm.value.usuario}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${editForm.value.nombres}</li>
          <li style="margin: 5px 0;"><strong>Departamento:</strong> ${editForm.value.cvedepto}</li>
          <li style="margin: 5px 0;"><strong>Nivel:</strong> ${editForm.value.nivel}</li>
          ${editForm.value.clave ? '<li style="margin: 5px 0;"><strong>Clave:</strong> Se actualizará</li>' : ''}
          ${editForm.value.fecbaj ? `<li style="margin: 5px 0;"><strong>Fecha de Baja:</strong> ${editForm.value.fecbaj}</li>` : ''}
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  // Si el usuario cancela, no continuar
  if (!confirmResult.isConfirmed) {
    console.log('❌ Usuario canceló la actualización')
    return
  }

  console.log('✅ Validación pasada, iniciando actualización...')
  updatingUsuario.value = true

  try {
    const params = [
      { nombre: 'p_usuario', valor: editForm.value.usuario, tipo: 'string' },
      { nombre: 'p_cvedepto', valor: editForm.value.cvedepto, tipo: 'integer' },
      { nombre: 'p_nombres', valor: editForm.value.nombres.trim(), tipo: 'string' },
      { nombre: 'p_clave', valor: editForm.value.clave?.trim() || '', tipo: 'string' },
      { nombre: 'p_nivel', valor: editForm.value.nivel, tipo: 'integer' },
      { nombre: 'p_fecbaj', valor: editForm.value.fecbaj || null, tipo: 'string' }
    ]

    console.log('📤 Enviando petición al API:', params)

    const response = await execute(
      'sp_consultausuarios_update',
      'padron_licencias',
      params,
      'guadalajara'
    )

    console.log('📥 Respuesta del API:', response)

    if (response && response.result && response.result[0]?.success) {
      showEditModal.value = false
      loadUsuarios()

      await Swal.fire({
        icon: 'success',
        title: '¡Usuario actualizado!',
        text: 'Los datos del usuario han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Usuario actualizado exitosamente')
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
    updatingUsuario.value = false
  }
}

const viewUsuario = (usuario) => {
  selectedUsuario.value = usuario
  showViewModal.value = true
}

const confirmDeactivateUsuario = async (usuario) => {
  const result = await Swal.fire({
    title: '¿Dar de baja usuario?',
    text: `¿Está seguro de dar de baja al usuario "${usuario.usuario?.trim()}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deactivateUsuario(usuario)
  }
}

const deactivateUsuario = async (usuario) => {
  try {
    const response = await execute(
      'SP_CONSULTAUSUARIOS_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: usuario.usuario?.trim() },
        { nombre: 'p_capturo', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      loadUsuarios()

      await Swal.fire({
        icon: 'success',
        title: '¡Usuario dado de baja!',
        text: 'El usuario ha sido desactivado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Usuario dado de baja exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Utilidades
const getLevelBadgeClass = (nivel) => {
  const classes = {
    1: 'badge-secondary',
    5: 'badge-info',
    9: 'badge-warning',
    10: 'badge-primary'
  }
  return classes[nivel] || 'badge-secondary'
}

const getStatusBadgeClass = (fecbaj) => {
  return fecbaj ? 'badge-danger' : 'badge-success'
}

const getStatusText = (fecbaj) => {
  return fecbaj ? 'Inactivo' : 'Activo'
}

const getStatusIcon = (fecbaj) => {
  return fecbaj ? 'times-circle' : 'check-circle'
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
  loadUsuarios()
})

onBeforeUnmount(() => {
  showCreateModal.value = false
  showEditModal.value = false
  showViewModal.value = false
})
</script>
