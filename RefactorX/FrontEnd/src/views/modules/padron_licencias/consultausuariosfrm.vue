<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Usuarios</h1>
        <p>Padrón de Licencias - Gestión de Usuarios del Sistema</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="abrirModalNuevo"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button
          class="btn-municipal-primary"
          @click="cargarTodos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Tab Selector - Button Group -->
          <div class="btn-group mb-3" role="group">
            <button
              type="button"
              class="btn btn-outline-primary"
              :class="{ active: activeTab === 'usuario' }"
              @click="activeTab = 'usuario'"
            >
              <font-awesome-icon icon="user" />
              Usuario
            </button>
            <button
              type="button"
              class="btn btn-outline-primary"
              :class="{ active: activeTab === 'nombre' }"
              @click="activeTab = 'nombre'"
            >
              <font-awesome-icon icon="id-card" />
              Nombre
            </button>
            <button
              type="button"
              class="btn btn-outline-primary"
              :class="{ active: activeTab === 'departamento' }"
              @click="activeTab = 'departamento'"
            >
              <font-awesome-icon icon="building" />
              Departamento
            </button>
          </div>

          <!-- Búsqueda por Usuario -->
          <div v-if="activeTab === 'usuario'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Usuario</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="filters.usuario"
                  placeholder="Ingrese nombre de usuario"
                  @keyup.enter="buscarPorUsuario"
                  style="text-transform: lowercase;"
                />
              </div>
            </div>
          </div>

          <!-- Búsqueda por Nombre -->
          <div v-if="activeTab === 'nombre'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nombre</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="filters.nombre"
                  placeholder="Ingrese nombre completo"
                  @keyup.enter="buscarPorNombre"
                  style="text-transform: uppercase;"
                />
              </div>
            </div>
          </div>

          <!-- Búsqueda por Departamento -->
          <div v-if="activeTab === 'departamento'">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Dependencia</label>
                <select
                  class="municipal-form-control"
                  v-model="filters.idDependencia"
                  @change="onDependenciaChange"
                >
                  <option value="">Seleccione...</option>
                  <option
                    v-for="dep in dependencias"
                    :key="dep.id_dependencia"
                    :value="dep.id_dependencia"
                  >
                    {{ dep.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Departamento</label>
                <select
                  class="municipal-form-control"
                  v-model="filters.cveDepto"
                  :disabled="!filters.idDependencia"
                >
                  <option value="">Seleccione...</option>
                  <option
                    v-for="depto in departamentos"
                    :key="depto.cvedepto"
                    :value="depto.cvedepto"
                  >
                    {{ depto.nombredepto }}
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button
                  class="btn-municipal-primary me-2"
                  @click="buscar"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
                <button
                  class="btn-municipal-secondary"
                  @click="limpiarFiltros"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="usuarios.length > 0">
              {{ formatNumber(usuarios.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Usuario</th>
                  <th>Nombre</th>
                  <th>Departamento</th>
                  <th>Nivel</th>
                  <th>Fecha Alta</th>
                  <th>Fecha Baja</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="usuarios.length === 0 && !searchPerformed">
                  <td colspan="8" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para encontrar usuarios o actualiza la consulta completa</p>
                  </td>
                </tr>
                <tr v-else-if="usuarios.length === 0">
                  <td colspan="8" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron usuarios con los criterios especificados</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="(usuario, index) in paginatedUsuarios"
                  :key="index"
                  @click="selectedUsuario = usuario"
                  @dblclick="verDetalleUsuario(usuario)"
                  :class="{ 'table-row-selected': selectedUsuario === usuario }"
                  class="row-hover"
                >
                  <td><strong class="text-primary">{{ usuario.usuario?.trim() }}</strong></td>
                  <td>{{ usuario.nombres?.trim() || 'N/A' }}</td>
                  <td><small>{{ usuario.nombredepto?.trim() || 'N/A' }}</small></td>
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
                        class="btn-municipal-primary btn-sm"
                        @click.stop="abrirModalEditar(usuario)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="!usuario.fecbaj"
                        class="btn btn-danger btn-sm"
                        @click.stop="confirmarBaja(usuario)"
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

          <!-- Controles de Paginación -->
          <div v-if="usuarios.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
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
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
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

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal Nuevo Usuario -->
    <Modal
      :show="showModalNuevo"
      size="xl"
      @close="cerrarModalNuevo"
      :showDefaultFooter="false"
      class="modal-usuario"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="user-plus" class="me-2" />
          Nuevo Usuario
        </h5>
      </template>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Usuario <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formNuevo.usuario"
            placeholder="Nombre de usuario"
            style="text-transform: lowercase;"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombre Completo <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formNuevo.nombres"
            placeholder="Nombre completo"
            style="text-transform: uppercase;"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Contraseña <span class="required">*</span></label>
          <input
            type="password"
            class="municipal-form-control"
            v-model="formNuevo.clave"
            placeholder="Contraseña"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label class="municipal-form-label">Dependencia <span class="required">*</span></label>
          <select
            class="municipal-form-control"
            v-model="formNuevo.idDependencia"
            @change="cargarDeptosModal"
          >
            <option value="">Seleccione...</option>
            <option
              v-for="dep in dependencias"
              :key="dep.id_dependencia"
              :value="dep.id_dependencia"
            >
              {{ dep.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Departamento <span class="required">*</span></label>
          <select
            class="municipal-form-control"
            v-model="formNuevo.cvedepto"
            :disabled="!formNuevo.idDependencia"
          >
            <option value="">Seleccione...</option>
            <option
              v-for="depto in deptosModal"
              :key="depto.cvedepto"
              :value="depto.cvedepto"
            >
              {{ depto.nombredepto }}
            </option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label class="municipal-form-label">Nivel <span class="required">*</span></label>
          <select class="municipal-form-control" v-model="formNuevo.nivel" required>
            <option value="">Seleccionar...</option>
            <option value="1">Nivel 1 - Básico</option>
            <option value="5">Nivel 5 - Intermedio</option>
            <option value="9">Nivel 9 - Avanzado</option>
            <option value="10">Nivel 10 - Administrador</option>
          </select>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="cerrarModalNuevo">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="crearUsuario"
          :disabled="loadingModal"
        >
          <font-awesome-icon icon="save" />
          Guardar
        </button>
      </div>
    </Modal>

    <!-- Modal Editar Usuario -->
    <Modal
      :show="showModalEditar"
      size="xl"
      @close="cerrarModalEditar"
      :showDefaultFooter="false"
      class="modal-usuario"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="user-edit" class="me-2" />
          Actualizar Usuario
        </h5>
      </template>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Usuario</label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formEditar.usuario"
            disabled
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombre Completo <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="formEditar.nombres"
            placeholder="Nombre completo"
            style="text-transform: uppercase;"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Nueva Contraseña</label>
          <input
            type="password"
            class="municipal-form-control"
            v-model="formEditar.clave"
            placeholder="Dejar vacío para mantener la actual"
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label class="municipal-form-label">Dependencia <span class="required">*</span></label>
          <select
            class="municipal-form-control"
            v-model="formEditar.idDependencia"
            @change="cargarDeptosModalEditar"
          >
            <option value="">Seleccione...</option>
            <option
              v-for="dep in dependencias"
              :key="dep.id_dependencia"
              :value="dep.id_dependencia"
            >
              {{ dep.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Departamento <span class="required">*</span></label>
          <select
            class="municipal-form-control"
            v-model="formEditar.cvedepto"
            :disabled="!formEditar.idDependencia"
          >
            <option value="">Seleccione...</option>
            <option
              v-for="depto in deptosModalEditar"
              :key="depto.cvedepto"
              :value="depto.cvedepto"
            >
              {{ depto.nombredepto }}
            </option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label class="municipal-form-label">Nivel <span class="required">*</span></label>
          <select class="municipal-form-control" v-model="formEditar.nivel" required>
            <option value="1">Nivel 1 - Básico</option>
            <option value="5">Nivel 5 - Intermedio</option>
            <option value="9">Nivel 9 - Avanzado</option>
            <option value="10">Nivel 10 - Administrador</option>
          </select>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="cerrarModalEditar">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="actualizarUsuario"
          :disabled="loadingModal"
        >
          <font-awesome-icon icon="save" />
          Actualizar
        </button>
      </div>
    </Modal>

    <!-- Modal Detalle Usuario -->
    <Modal
      :show="showModalDetalle"
      size="xl"
      @close="cerrarModalDetalle"
      :showDefaultFooter="false"
      class="modal-usuario"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="id-card" class="me-2" />
          Detalles del Usuario: {{ selectedUsuario?.usuario?.trim() }}
        </h5>
      </template>
      <div v-if="selectedUsuario" class="user-details">
        <div class="details-grid">
          <!-- Sección 1: Información Básica -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Usuario:</td>
                <td><strong class="text-primary">{{ selectedUsuario.usuario?.trim() }}</strong></td>
              </tr>
              <tr>
                <td class="label">Nombre Completo:</td>
                <td>{{ selectedUsuario.nombres?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Nivel:</td>
                <td>
                  <span class="badge" :class="getLevelBadgeClass(selectedUsuario.nivel)">
                    <font-awesome-icon icon="user-shield" />
                    Nivel {{ selectedUsuario.nivel || 'N/A' }} - {{ getLevelName(selectedUsuario.nivel) }}
                  </span>
                </td>
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

          <!-- Sección 2: Departamento -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="building" />
              Departamento
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Dependencia:</td>
                <td>{{ selectedUsuario.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Departamento:</td>
                <td>{{ selectedUsuario.nombredepto?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ selectedUsuario.telefono?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <!-- Sección 3: Fechas -->
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
                  <font-awesome-icon icon="calendar-minus" :class="selectedUsuario.fecbaj ? 'text-danger' : 'text-muted'" />
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
            </table>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="cerrarModalDetalle">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="abrirModalEditar(); cerrarModalDetalle()">
            <font-awesome-icon icon="edit" />
            Editar Usuario
          </button>
        </div>
      </div>
    </Modal>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'consultausuariosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const {
  loading: loadingGlobal,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const activeTab = ref('usuario')
const showFilters = ref(false)
const usuarios = ref([])
const dependencias = ref([])
const departamentos = ref([])
const deptosModal = ref([])
const deptosModalEditar = ref([])
const selectedUsuario = ref(null)
const searchPerformed = ref(false)
const showModalNuevo = ref(false)
const showModalEditar = ref(false)
const showModalDetalle = ref(false)
const showDocumentation = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => usuarios.value.length)

// Filtros
const filters = ref({
  usuario: '',
  nombre: '',
  idDependencia: '',
  cveDepto: ''
})

// Formularios
const formNuevo = ref({
  usuario: '',
  nombres: '',
  clave: '',
  idDependencia: '',
  cvedepto: '',
  nivel: 1
})

const formEditar = ref({
  usuario: '',
  nombres: '',
  clave: '',
  idDependencia: '',
  cvedepto: '',
  nivel: 1
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const buscar = () => {
  if (activeTab.value === 'usuario') {
    buscarPorUsuario()
  } else if (activeTab.value === 'nombre') {
    buscarPorNombre()
  } else if (activeTab.value === 'departamento') {
    buscarPorDepartamento()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    usuario: '',
    nombre: '',
    idDependencia: '',
    cveDepto: ''
  }
  usuarios.value = []
  selectedUsuario.value = null
  searchPerformed.value = false
  departamentos.value = []
  currentPage.value = 1
}

const cargarTodos = async () => {
  showLoading('Cargando usuarios...', 'Por favor espere')
  searchPerformed.value = true
  currentPage.value = 1
  showFilters.value = false

  try {
    const response = await execute(
      'get_all_usuarios',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      usuarios.value = response.result
      if (usuarios.value.length > 0) {
        selectedUsuario.value = usuarios.value[0]
        showToast('success', `Se cargaron ${usuarios.value.length} usuario(s)`)
      } else {
        showToast('info', 'No hay usuarios registrados')
      }
    } else {
      usuarios.value = []
      selectedUsuario.value = null
      showToast('info', 'No hay usuarios')
    }
  } catch (error) {
    handleApiError(error, 'Error al cargar usuarios')
    usuarios.value = []
    selectedUsuario.value = null
  } finally {
    hideLoading()
  }
}

const buscarPorUsuario = async () => {
  if (!filters.value.usuario.trim()) {
    showToast('warning', 'Debes indicar el usuario')
    return
  }

  showLoading('Buscando usuario...', 'Consultando base de datos')
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const response = await execute(
      'consulta_usuario_por_usuario',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: filters.value.usuario.trim().toLowerCase(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      usuarios.value = response.result
      if (usuarios.value.length > 0) {
        selectedUsuario.value = usuarios.value[0]
        showToast('success', `Se encontró ${usuarios.value.length} usuario(s)`)
      } else {
        showToast('info', 'No se encontraron usuarios con ese criterio')
      }
    } else {
      usuarios.value = []
      selectedUsuario.value = null
      showToast('info', 'No se encontraron usuarios')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar usuario')
    usuarios.value = []
    selectedUsuario.value = null
  } finally {
    hideLoading()
  }
}

const buscarPorNombre = async () => {
  if (!filters.value.nombre.trim()) {
    showToast('warning', 'Debes indicar el nombre')
    return
  }

  showLoading('Buscando por nombre...', 'Consultando base de datos')
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const response = await execute(
      'consulta_usuario_por_nombre',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: filters.value.nombre.trim().toUpperCase(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      usuarios.value = response.result
      if (usuarios.value.length > 0) {
        selectedUsuario.value = usuarios.value[0]
        showToast('success', `Se encontraron ${usuarios.value.length} usuario(s)`)
      } else {
        showToast('info', 'No se encontraron usuarios con ese nombre')
      }
    } else {
      usuarios.value = []
      selectedUsuario.value = null
      showToast('info', 'No se encontraron usuarios')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar usuarios')
    usuarios.value = []
    selectedUsuario.value = null
  } finally {
    hideLoading()
  }
}

const buscarPorDepartamento = async () => {
  if (!filters.value.idDependencia || !filters.value.cveDepto) {
    showToast('warning', 'Debes indicar la dependencia y el departamento')
    return
  }

  showLoading('Buscando por departamento...', 'Consultando base de datos')
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const response = await execute(
      'consulta_usuario_por_depto',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(filters.value.idDependencia), tipo: 'integer' },
        { nombre: 'p_cvedepto', valor: parseInt(filters.value.cveDepto), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      usuarios.value = response.result
      if (usuarios.value.length > 0) {
        selectedUsuario.value = usuarios.value[0]
        showToast('success', `Se encontraron ${usuarios.value.length} usuario(s)`)
      } else {
        showToast('info', 'No se encontraron usuarios en ese departamento')
      }
    } else {
      usuarios.value = []
      selectedUsuario.value = null
      showToast('info', 'No se encontraron usuarios')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar usuarios')
    usuarios.value = []
    selectedUsuario.value = null
  } finally {
    hideLoading()
  }
}

// CRUD Operations
const abrirModalNuevo = () => {
  formNuevo.value = {
    usuario: '',
    nombres: '',
    clave: '',
    idDependencia: '',
    cvedepto: '',
    nivel: 1
  }
  deptosModal.value = []
  showModalNuevo.value = true
}

const cerrarModalNuevo = () => {
  showModalNuevo.value = false
}

const abrirModalEditar = async (usuario = null) => {
  // Si se pasa un usuario, usarlo; si no, usar el seleccionado
  const usuarioEditar = usuario || selectedUsuario.value

  if (!usuarioEditar) {
    showToast('warning', 'Debe seleccionar un usuario de la tabla para actualizar')
    return
  }

  // Activar loading global
  showLoading('Preparando edición...', 'Cargando información del usuario')

  // Actualizar el usuario seleccionado
  selectedUsuario.value = usuarioEditar

  formEditar.value = {
    usuario: usuarioEditar.usuario,
    nombres: usuarioEditar.nombres,
    clave: '',
    idDependencia: usuarioEditar.cvedependencia || '',
    cvedepto: usuarioEditar.cvedepto || '',
    nivel: usuarioEditar.nivel || 1
  }

  // Cargar departamentos de la dependencia actual
  if (formEditar.value.idDependencia) {
    await cargarDeptosModalEditar()
  }

  // Pequeño delay para mostrar el loading
  await new Promise(resolve => setTimeout(resolve, 200))

  showModalEditar.value = true
  hideLoading()
  showToast('info', `Editando usuario: ${usuarioEditar.usuario}`)
}

const cerrarModalEditar = () => {
  showModalEditar.value = false
}

const verDetalleUsuario = async (usuario) => {
  showLoading('Cargando detalles...', 'Preparando información del usuario')
  selectedUsuario.value = usuario

  // Pequeño delay para mostrar el loading
  await new Promise(resolve => setTimeout(resolve, 300))

  showModalDetalle.value = true
  hideLoading()
}

const cerrarModalDetalle = () => {
  showModalDetalle.value = false
}

const crearUsuario = async () => {
  // Validaciones
  if (!formNuevo.value.usuario || !formNuevo.value.nombres || !formNuevo.value.clave || !formNuevo.value.cvedepto) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación antes de crear
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de usuario?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo usuario con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${formNuevo.value.usuario.trim().toLowerCase()}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${formNuevo.value.nombres}</li>
          <li style="margin: 5px 0;"><strong>Departamento:</strong> ${formNuevo.value.cvedepto}</li>
          <li style="margin: 5px 0;"><strong>Nivel:</strong> ${formNuevo.value.nivel}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear usuario',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Creando usuario...', 'Por favor espere')

  try {
    const response = await execute(
      'crear_usuario',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formNuevo.value.usuario.toLowerCase(), tipo: 'string' },
        { nombre: 'p_nombres', valor: formNuevo.value.nombres.toUpperCase(), tipo: 'string' },
        { nombre: 'p_clave', valor: formNuevo.value.clave, tipo: 'string' },
        { nombre: 'p_cvedepto', valor: parseInt(formNuevo.value.cvedepto), tipo: 'integer' },
        { nombre: 'p_nivel', valor: formNuevo.value.nivel, tipo: 'integer' },
        { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]) {
      const resultado = response.result[0]
      if (resultado.success) {
        cerrarModalNuevo()

        await Swal.fire({
          icon: 'success',
          title: '¡Usuario creado!',
          text: 'El usuario ha sido creado exitosamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        showToast('success', 'Usuario creado exitosamente')

        // Recargar resultados si había una búsqueda activa
        if (searchPerformed.value) {
          if (activeTab.value === 'usuario' && filters.value.usuario) {
            buscarPorUsuario()
          } else if (activeTab.value === 'nombre' && filters.value.nombre) {
            buscarPorNombre()
          } else if (activeTab.value === 'departamento' && filters.value.cveDepto) {
            buscarPorDepartamento()
          }
        }
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al crear usuario',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()

    handleApiError(error, 'Error al crear usuario')

    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo crear el usuario',
      confirmButtonColor: '#ea8215'
    })
  }
}

const actualizarUsuario = async () => {
  // Validaciones
  if (!formEditar.value.nombres || !formEditar.value.cvedepto) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación antes de actualizar
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizarán los datos del usuario:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${formEditar.value.usuario}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${formEditar.value.nombres}</li>
          <li style="margin: 5px 0;"><strong>Departamento:</strong> ${formEditar.value.cvedepto}</li>
          <li style="margin: 5px 0;"><strong>Nivel:</strong> ${formEditar.value.nivel}</li>
          ${formEditar.value.clave ? '<li style="margin: 5px 0;"><strong>Clave:</strong> Se actualizará</li>' : ''}
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Actualizando usuario...', 'Por favor espere')

  try {
    const response = await execute(
      'actualizar_usuario',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formEditar.value.usuario, tipo: 'string' },
        { nombre: 'p_nombres', valor: formEditar.value.nombres.toUpperCase(), tipo: 'string' },
        { nombre: 'p_clave', valor: formEditar.value.clave || null, tipo: 'string' },
        { nombre: 'p_cvedepto', valor: parseInt(formEditar.value.cvedepto), tipo: 'integer' },
        { nombre: 'p_nivel', valor: formEditar.value.nivel, tipo: 'integer' },
        { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]) {
      const resultado = response.result[0]
      if (resultado.success) {
        cerrarModalEditar()

        await Swal.fire({
          icon: 'success',
          title: '¡Usuario actualizado!',
          text: 'Los datos del usuario han sido actualizados',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        showToast('success', 'Usuario actualizado exitosamente')

        // Recargar resultados
        if (activeTab.value === 'usuario' && filters.value.usuario) {
          buscarPorUsuario()
        } else if (activeTab.value === 'nombre' && filters.value.nombre) {
          buscarPorNombre()
        } else if (activeTab.value === 'departamento' && filters.value.cveDepto) {
          buscarPorDepartamento()
        }
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al actualizar',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()

    handleApiError(error, 'Error al actualizar usuario')

    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo actualizar el usuario',
      confirmButtonColor: '#ea8215'
    })
  }
}

const confirmarBaja = async (usuario = null) => {
  // Si se pasa un usuario, usarlo; si no, usar el seleccionado
  const usuarioBaja = usuario || selectedUsuario.value

  if (!usuarioBaja) return

  // Actualizar el usuario seleccionado
  selectedUsuario.value = usuarioBaja

  if (usuarioBaja.fecbaj) {
    showToast('warning', 'Este usuario ya está dado de baja')
    return
  }

  const result = await Swal.fire({
    title: '¿Dar de baja usuario?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">¿Está seguro de dar de baja al siguiente usuario?</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${usuarioBaja.usuario?.trim()}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${usuarioBaja.nombres?.trim()}</li>
          <li style="margin: 5px 0;"><strong>Departamento:</strong> ${usuarioBaja.nombredepto?.trim()}</li>
        </ul>
        <p style="margin-top: 15px; color: #dc3545; font-weight: bold;">Esta acción no se puede deshacer.</p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await darBajaUsuario()
  }
}

const darBajaUsuario = async () => {
  showLoading('Dando de baja usuario...', 'Por favor espere')

  try {
    const response = await execute(
      'dar_baja_usuario',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: selectedUsuario.value.usuario, tipo: 'string' },
        { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]) {
      const resultado = response.result[0]
      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: '¡Usuario dado de baja!',
          text: 'El usuario ha sido desactivado exitosamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        showToast('success', 'Usuario dado de baja exitosamente')

        // Recargar resultados
        if (activeTab.value === 'usuario' && filters.value.usuario) {
          buscarPorUsuario()
        } else if (activeTab.value === 'nombre' && filters.value.nombre) {
          buscarPorNombre()
        } else if (activeTab.value === 'departamento' && filters.value.cveDepto) {
          buscarPorDepartamento()
        }
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al dar de baja',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()

    handleApiError(error, 'Error al dar de baja usuario')

    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo dar de baja al usuario',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Cargar catálogos
const cargarDependencias = async () => {
  try {
    const response = await execute(
      'get_dependencias',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      dependencias.value = response.result
    }
  } catch (error) {
  }
}

const onDependenciaChange = async () => {
  filters.value.cveDepto = ''
  departamentos.value = []

  if (!filters.value.idDependencia) return

  try {
    const response = await execute(
      'get_deptos_by_dependencia',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(filters.value.idDependencia), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      departamentos.value = response.result
    }
  } catch (error) {
  }
}

const cargarDeptosModal = async () => {
  formNuevo.value.cvedepto = ''
  deptosModal.value = []

  if (!formNuevo.value.idDependencia) return

  try {
    const response = await execute(
      'get_deptos_by_dependencia',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(formNuevo.value.idDependencia), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      deptosModal.value = response.result
    }
  } catch (error) {
  }
}

const cargarDeptosModalEditar = async () => {
  deptosModalEditar.value = []

  if (!formEditar.value.idDependencia) return

  try {
    const response = await execute(
      'get_deptos_by_dependencia',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(formEditar.value.idDependencia), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      deptosModalEditar.value = response.result
    }
  } catch (error) {
  }
}

// Utilidades
const getStatusBadgeClass = (fecbaj) => {
  return fecbaj ? 'badge-danger' : 'badge-success'
}

const getStatusText = (fecbaj) => {
  return fecbaj ? 'Inactivo' : 'Activo'
}

const getStatusIcon = (fecbaj) => {
  return fecbaj ? 'times-circle' : 'check-circle'
}

const getLevelBadgeClass = (nivel) => {
  const classes = {
    1: 'badge-secondary',
    5: 'badge-purple',
    9: 'badge-warning',
    10: 'badge-primary'
  }
  return classes[nivel] || 'badge-secondary'
}

const getLevelName = (nivel) => {
  const names = {
    1: 'Básico',
    5: 'Intermedio',
    9: 'Avanzado',
    10: 'Administrador'
  }
  return names[nivel] || 'Desconocido'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return ''
  }
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedUsuarios = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return usuarios.value.slice(start, end)
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

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedUsuario.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedUsuario.value = null
}

// Lifecycle
onMounted(() => {
  cargarDependencias()
  activeTab.value = 'usuario'
})
</script>
