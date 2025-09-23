<template>
  <div class="dependencias-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-building-columns"></i>
            Gestión de Dependencias
          </h3>
          <p class="module-description mb-0">
            Administración de dependencias gubernamentales para el sistema de licencias
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nueva Dependencia
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="form-label">Código</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.codigo"
              placeholder="Código de dependencia"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Nombre</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.nombre"
              placeholder="Nombre de la dependencia"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Descripción</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.descripcion"
              placeholder="Descripción"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado</label>
            <select class="form-select" v-model="filters.activo">
              <option value="">Todos</option>
              <option value="S">Activos</option>
              <option value="N">Inactivos</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button
              class="btn btn-outline-primary me-2"
              @click="searchDependencias"
              :disabled="loading"
            >
              <i class="fas fa-search"></i>
              Buscar
            </button>
            <button
              class="btn btn-outline-secondary me-2"
              @click="clearFilters"
              :disabled="loading"
            >
              <i class="fas fa-times"></i>
              Limpiar
            </button>
            <button
              class="btn btn-outline-success"
              @click="loadDependencias"
              :disabled="loading"
            >
              <i class="fas fa-sync-alt"></i>
              Actualizar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="card">
      <div class="card-header">
        <h6 class="mb-0">
          <i class="fas fa-list"></i>
          Dependencias Registradas
          <span v-if="dependencias.length > 0" class="badge bg-primary ms-2">
            {{ dependencias.length }} registros
          </span>
        </h6>
      </div>
      <div class="card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando dependencias...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="alert alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn btn-outline-danger btn-sm" @click="loadDependencias">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="dependencias.length === 0" class="text-center py-5">
          <i class="fas fa-building-columns fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron dependencias</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay dependencias registradas en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn btn-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Registrar primera dependencia
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light">
              <tr>
                <th>ID</th>
                <th>Código</th>
                <th>Nombre</th>
                <th>Abreviación</th>
                <th>Estado</th>
                <th>Licencias</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dependencia in dependencias" :key="dependencia.id_dependencia">
                <td>
                  <strong class="text-primary">{{ dependencia.id_dependencia }}</strong>
                </td>
                <td>{{ dependencia.codigo }}</td>
                <td>{{ dependencia.nombre }}</td>
                <td>
                  <span class="badge bg-info">{{ dependencia.abrevia || 'N/A' }}</span>
                </td>
                <td>
                  <span class="badge" :class="dependencia.activo === 'S' ? 'bg-success' : 'bg-secondary'">
                    {{ dependencia.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="dependencia.licencias === 1 ? 'bg-primary' : 'bg-warning'">
                    {{ dependencia.licencias === 1 ? 'Sí' : 'No' }}
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewDependencia(dependencia)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-warning"
                      @click="editDependencia(dependencia)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-outline-danger"
                      @click="deleteDependencia(dependencia)"
                      title="Eliminar"
                    >
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalPages > 1" class="d-flex justify-content-between align-items-center mt-4">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, totalRegistros) }} de
              {{ totalRegistros }} registros
            </span>
          </div>
          <nav aria-label="Paginación de dependencias">
            <ul class="pagination pagination-sm mb-0">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button
                  class="page-link"
                  @click="previousPage"
                  :disabled="currentPage === 1"
                  aria-label="Página anterior"
                >
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>

              <li
                v-for="page in getVisiblePages()"
                :key="page"
                class="page-item"
                :class="{ active: page === currentPage }"
              >
                <button
                  class="page-link"
                  @click="goToPage(page)"
                  :aria-label="`Página ${page}`"
                >
                  {{ page }}
                </button>
              </li>

              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button
                  class="page-link"
                  @click="nextPage"
                  :disabled="currentPage === totalPages"
                  aria-label="Página siguiente"
                >
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal para crear/editar dependencia -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingDependencia ? 'Editar Dependencia' : 'Nueva Dependencia' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveDependencia">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Código <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDependencia.codigo"
                    placeholder="Código único"
                    required
                    maxlength="10"
                    :disabled="editingDependencia"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Estado</label>
                  <select class="form-select" v-model="newDependencia.activo">
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Nombre <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDependencia.nombre"
                    placeholder="Nombre completo de la dependencia"
                    required
                    maxlength="200"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Descripción</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="newDependencia.descripcion"
                    placeholder="Descripción detallada de la dependencia"
                    maxlength="500"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Responsable</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDependencia.responsable"
                    placeholder="Nombre del responsable"
                    maxlength="100"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Teléfono</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDependencia.telefono"
                    placeholder="Número telefónico"
                    maxlength="20"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Email</label>
                  <input
                    type="email"
                    class="form-control"
                    v-model="newDependencia.email"
                    placeholder="correo@gobierno.mx"
                    maxlength="100"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Extensión</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDependencia.extension"
                    placeholder="Ext. telefónica"
                    maxlength="10"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Dirección</label>
                  <textarea
                    class="form-control"
                    rows="2"
                    v-model="newDependencia.direccion"
                    placeholder="Dirección física de la dependencia"
                    maxlength="300"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="2"
                    v-model="newDependencia.observaciones"
                    placeholder="Observaciones adicionales"
                    maxlength="500"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showCreateModal = false">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="saveDependencia"
              :disabled="creating || !newDependencia.codigo || !newDependencia.nombre"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingDependencia ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingDependencia ? 'Actualizar Dependencia' : 'Crear Dependencia' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

    <!-- Modal de detalles de la dependencia -->
    <div v-if="showDetailsModal" class="modal-overlay" @click.self="showDetailsModal = false">
      <div class="modal-content" style="max-width: 800px;">
        <div class="modal-header">
          <h2>
            <i class="fas fa-building-columns"></i>
            Detalles de la Dependencia
          </h2>
          <button class="close-btn" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedDependencia">
          <div class="row">
            <div class="col-12 mb-4">
              <div class="alert alert-info">
                <h5 class="alert-heading mb-2">
                  <i class="fas fa-info-circle"></i>
                  {{ selectedDependencia.codigo }} - {{ selectedDependencia.nombre }}
                </h5>
                <p class="mb-0">{{ selectedDependencia.descripcion || 'Sin descripción disponible' }}</p>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-info"></i>
                    Información General
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Código:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.codigo }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Abreviación:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.abrevia || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Estado:</label>
                    <span class="badge" :class="selectedDependencia.activo === 'S' ? 'bg-success' : 'bg-secondary'">
                      {{ selectedDependencia.activo === 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Maneja Licencias:</label>
                    <span class="badge" :class="selectedDependencia.licencias === 1 ? 'bg-primary' : 'bg-warning'">
                      {{ selectedDependencia.licencias === 1 ? 'Sí' : 'No' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-address-book"></i>
                    Contacto
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Responsable:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.responsable || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Teléfono:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.telefono || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Email:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.email || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Extensión:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.extension || 'N/A' }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDependencia.direccion">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-map-marker-alt"></i>
                    Dirección
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDependencia.direccion }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDependencia.observaciones">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-comment"></i>
                    Observaciones
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDependencia.observaciones }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-primary" @click="editDependencia(selectedDependencia)">
            <i class="fas fa-edit"></i>
            Editar Dependencia
          </button>
          <button class="btn btn-secondary" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
            Cerrar
          </button>
        </div>
      </div>
    </div>

    <!-- SweetAlert Modal -->
    <div v-if="sweetAlert.show" class="swal-overlay" @click.self="closeSweetAlert">
      <div class="swal-modal">
        <div class="swal-icon" :class="sweetAlert.type">
          <i v-if="sweetAlert.type === 'success'" class="fas fa-check-circle"></i>
          <i v-else-if="sweetAlert.type === 'error'" class="fas fa-times-circle"></i>
          <i v-else-if="sweetAlert.type === 'warning'" class="fas fa-exclamation-triangle"></i>
          <i v-else-if="sweetAlert.type === 'info'" class="fas fa-info-circle"></i>
          <i v-else class="fas fa-question-circle"></i>
        </div>
        <h3 class="swal-title">{{ sweetAlert.title }}</h3>
        <p class="swal-text">{{ sweetAlert.text }}</p>
        <div class="swal-footer">
          <button class="btn btn-primary" @click="closeSweetAlert">
            Aceptar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-for="toast in toasts" :key="toast.id"
         class="toast-notification"
         :class="toast.type"
         :style="{ top: (20 + (toasts.indexOf(toast) * 80)) + 'px' }">
      <div class="toast-icon">
        <i v-if="toast.type === 'success'" class="fas fa-check-circle"></i>
        <i v-else-if="toast.type === 'error'" class="fas fa-times-circle"></i>
        <i v-else-if="toast.type === 'warning'" class="fas fa-exclamation-triangle"></i>
        <i v-else-if="toast.type === 'info'" class="fas fa-info-circle"></i>
      </div>
      <div class="toast-message">{{ toast.message }}</div>
      <button class="toast-close" @click="removeToast(toast.id)">
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DependenciasForm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      dependencias: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        codigo: '',
        nombre: '',
        descripcion: '',
        activo: ''
      },

      // Modal
      showCreateModal: false,
      editingDependencia: null,

      // Modales
      showDetailsModal: false,
      selectedDependencia: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nueva dependencia
      newDependencia: {
        codigo: '',
        nombre: '',
        descripcion: '',
        responsable: '',
        telefono: '',
        email: '',
        extension: '',
        direccion: '',
        observaciones: '',
        activo: 'S'
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    }
  },

  mounted() {
    console.log('DependenciasForm component mounted')
    this.loadDependencias()
  },
  methods: {
    async loadDependencias() {
      this.loading = true
      this.error = null

      try {
        // Llamada real a la API usando SP_DEPENDENCIAS_LIST
        const eRequest = {
          Operacion: 'sp_dependencias_list',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_codigo', valor: this.filters.codigo || null },
            { nombre: 'p_nombre', valor: this.filters.nombre || null },
            { nombre: 'p_descripcion', valor: this.filters.descripcion || null },
            { nombre: 'p_activo', valor: this.filters.activo || null },
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Cargando dependencias con SP_DEPENDENCIAS_LIST:', eRequest)

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('📥 Respuesta del servidor:', data)

        if (data.success && data.data) {
          this.dependencias = data.data || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.dependencias.length > 0) {
            this.totalRegistros = parseInt(this.dependencias[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`✅ Cargadas ${this.dependencias.length} dependencias de ${this.totalRegistros} totales (Página ${this.currentPage}/${this.totalPages})`)
        } else {
          throw new Error(data.error || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar las dependencias: ' + error.message
        console.error('❌ Error loading dependencias:', error)
      } finally {
        this.loading = false
      }
    },

    async searchDependencias() {
      console.log('🔍 Buscando dependencias con filtros:', this.filters)
      this.currentPage = 1 // Reset to first page when searching
      this.loadDependencias()
    },

    clearFilters() {
      this.filters = {
        codigo: '',
        nombre: '',
        descripcion: '',
        activo: ''
      }
      this.currentPage = 1 // Reset to first page
      this.loadDependencias()
    },

    async saveDependencia() {
      if (!this.newDependencia.codigo || !this.newDependencia.nombre) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Código y Nombre)')
        return
      }

      this.creating = true

      try {
        let eRequest

        if (this.editingDependencia) {
          // Actualizar dependencia existente
          eRequest = {
            Operacion: 'SP_DEPENDENCIAS_UPDATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: this.editingDependencia.id_dependencia },
              { nombre: 'p_codigo', valor: this.newDependencia.codigo },
              { nombre: 'p_nombre', valor: this.newDependencia.nombre },
              { nombre: 'p_descripcion', valor: this.newDependencia.descripcion || null },
              { nombre: 'p_responsable', valor: this.newDependencia.responsable || null },
              { nombre: 'p_telefono', valor: this.newDependencia.telefono || null },
              { nombre: 'p_email', valor: this.newDependencia.email || null },
              { nombre: 'p_extension', valor: this.newDependencia.extension || null },
              { nombre: 'p_direccion', valor: this.newDependencia.direccion || null },
              { nombre: 'p_observaciones', valor: this.newDependencia.observaciones || null },
              { nombre: 'p_activo', valor: this.newDependencia.activo }
            ],
            Tenant: 'informix'
          }
        } else {
          // Crear nueva dependencia
          eRequest = {
            Operacion: 'SP_DEPENDENCIAS_CREATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_codigo', valor: this.newDependencia.codigo },
              { nombre: 'p_nombre', valor: this.newDependencia.nombre },
              { nombre: 'p_descripcion', valor: this.newDependencia.descripcion || null },
              { nombre: 'p_responsable', valor: this.newDependencia.responsable || null },
              { nombre: 'p_telefono', valor: this.newDependencia.telefono || null },
              { nombre: 'p_email', valor: this.newDependencia.email || null },
              { nombre: 'p_extension', valor: this.newDependencia.extension || null },
              { nombre: 'p_direccion', valor: this.newDependencia.direccion || null },
              { nombre: 'p_observaciones', valor: this.newDependencia.observaciones || null },
              { nombre: 'p_activo', valor: this.newDependencia.activo }
            ],
            Tenant: 'informix'
          }
        }

        console.log(`📨 ${this.editingDependencia ? 'Actualizando' : 'Creando'} dependencia:`, eRequest)

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('📥 Respuesta del servidor:', data)

        if (data.success && data.data) {
          const result = data.data[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingDependencia ? 'Dependencia Actualizada' : 'Dependencia Creada',
              result.message || (this.editingDependencia ? 'Dependencia actualizada exitosamente' : 'Dependencia creada exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadDependencias()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.error || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar la dependencia: ' + error.message)
        console.error('❌ Error saving dependencia:', error)
      } finally {
        this.creating = false
      }
    },

    editDependencia(dependencia) {
      this.editingDependencia = dependencia
      this.newDependencia = {
        codigo: dependencia.codigo,
        nombre: dependencia.nombre,
        descripcion: dependencia.descripcion || '',
        responsable: dependencia.responsable || '',
        telefono: dependencia.telefono || '',
        email: dependencia.email || '',
        extension: dependencia.extension || '',
        direccion: dependencia.direccion || '',
        observaciones: dependencia.observaciones || '',
        activo: dependencia.activo
      }
      this.showCreateModal = true
      this.showDetailsModal = false
    },

    deleteDependencia(dependencia) {
      if (confirm(`¿Está seguro que desea eliminar la dependencia "${dependencia.nombre}"?`)) {
        this.confirmDeleteDependencia(dependencia)
      }
    },

    async confirmDeleteDependencia(dependencia) {
      try {
        const eRequest = {
          Operacion: 'SP_DEPENDENCIAS_DELETE',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id', valor: dependencia.id_dependencia }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Eliminando dependencia:', eRequest)

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('📥 Respuesta del servidor:', data)

        if (data.success && data.data) {
          const result = data.data[0]
          if (result.success) {
            this.showSweetAlert('success', 'Dependencia Eliminada', result.message || 'Dependencia eliminada exitosamente')
            this.loadDependencias()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error al eliminar la dependencia')
          }
        } else {
          throw new Error(data.error || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar la dependencia: ' + error.message)
        console.error('❌ Error deleting dependencia:', error)
      }
    },

    resetCreateForm() {
      this.editingDependencia = null
      this.newDependencia = {
        codigo: '',
        nombre: '',
        descripcion: '',
        responsable: '',
        telefono: '',
        email: '',
        extension: '',
        direccion: '',
        observaciones: '',
        activo: 'S'
      }
    },

    viewDependencia(dependencia) {
      console.log('View dependencia:', dependencia)
      this.showDependenciaDetailsModal(dependencia)
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadDependencias()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadDependencias()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadDependencias()
      }
    },

    getVisiblePages() {
      const pages = []
      const maxVisible = 5
      let start = Math.max(1, this.currentPage - Math.floor(maxVisible / 2))
      let end = Math.min(this.totalPages, start + maxVisible - 1)

      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1)
      }

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }

      return pages
    },

    // SweetAlert personalizado
    showSweetAlert(type, title, text) {
      this.sweetAlert = {
        show: true,
        type: type,
        title: title,
        text: text
      }
    },

    closeSweetAlert() {
      this.sweetAlert.show = false

      // Auto cerrar después de 3 segundos para success e info, 5 segundos para error y warning
      const autoCloseTime = (this.sweetAlert.type === 'success' || this.sweetAlert.type === 'info') ? 3000 : 5000;
      setTimeout(() => {
        this.sweetAlert.show = false;
      }, autoCloseTime);
    },

    // Ver detalles de la dependencia en modal
    showDependenciaDetailsModal(dependencia) {
      this.selectedDependencia = dependencia
      this.showDetailsModal = true
    },

    // Sistema de Toast
    showToast(type, message) {
      const toast = {
        id: Date.now(),
        type: type,
        message: message
      }

      this.toasts.push(toast)

      // Auto remover después de 4 segundos
      setTimeout(() => {
        this.removeToast(toast.id)
      }, 4000)
    },

    removeToast(toastId) {
      const index = this.toasts.findIndex(toast => toast.id === toastId)
      if (index > -1) {
        this.toasts.splice(index, 1)
      }
    }
  }
}
</script>

<style scoped>
/* Estilos específicos del módulo de dependencias */
.dependencias-module {
  padding: 1rem;
}

.module-header {
  background: linear-gradient(135deg, #ff8c00 0%, #ff6347 100%);
  color: white;
  padding: 1.5rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.module-title {
  margin: 0;
  font-weight: 600;
}

.module-description {
  opacity: 0.9;
  font-size: 0.95rem;
}

/* Hover específico para dependencias */
.table-hover tbody tr:hover {
  background-color: rgba(255, 140, 0, 0.05);
}

/* Paginación con tema naranja para dependencias */
.pagination .page-link {
  color: #ff8c00;
  border-color: #dee2e6;
  padding: 0.375rem 0.75rem;
}

.pagination .page-link:hover {
  color: #cc7000;
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.pagination .page-item.active .page-link {
  background-color: #ff8c00;
  border-color: #ff8c00;
  color: white;
}

.pagination .page-link:focus {
  box-shadow: 0 0 0 0.2rem rgba(255, 140, 0, 0.25);
}

/* Estilos específicos para iconos de tipo SweetAlert dependencias */
.swal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.swal-modal {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
  max-width: 400px;
  min-width: 300px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.swal-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.swal-icon.success {
  color: #28a745;
}

.swal-icon.error {
  color: #dc3545;
}

.swal-icon.warning {
  color: #ffc107;
}

.swal-icon.info {
  color: #17a2b8;
}

.swal-title {
  margin-bottom: 1rem;
  font-size: 1.5rem;
  color: #333;
}

.swal-text {
  margin-bottom: 2rem;
  color: #666;
}

.swal-footer {
  display: flex;
  justify-content: center;
}

/* Estilos específicos para el modal de detalles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.modal-overlay .modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-overlay .modal-header {
  background: linear-gradient(135deg, #ff8c00 0%, #ff6347 100%);
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px 8px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-overlay .modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
}

.modal-overlay .modal-body {
  padding: 1.5rem;
}

.modal-overlay .modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.form-control-plaintext {
  background-color: transparent;
  border: none;
  padding: 0;
  margin: 0;
  font-weight: 500;
  color: #495057;
}

.card.h-100 {
  height: 100% !important;
}

/* Toast notifications */
.toast-notification {
  position: fixed;
  right: 20px;
  width: 350px;
  padding: 1rem;
  border-radius: 0.5rem;
  color: white;
  z-index: 9999;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.toast-notification.success {
  background: linear-gradient(135deg, #28a745, #20c997);
}

.toast-notification.error {
  background: linear-gradient(135deg, #dc3545, #e55353);
}

.toast-notification.warning {
  background: linear-gradient(135deg, #ffc107, #fd7e14);
  color: #212529;
}

.toast-notification.info {
  background: linear-gradient(135deg, #17a2b8, #20c997);
}

.toast-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.toast-message {
  flex: 1;
  font-weight: 500;
}

.toast-close {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  opacity: 0.8;
  transition: opacity 0.2s;
}

.toast-close:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.1);
}

/* Badge personalizado para dependencias */
.badge.bg-primary { background-color: #007bff !important; }
.badge.bg-success { background-color: #28a745 !important; }
.badge.bg-warning { background-color: #ffc107 !important; color: #212529 !important; }
.badge.bg-info { background-color: #17a2b8 !important; }
.badge.bg-secondary { background-color: #6c757d !important; }
.badge.bg-dark { background-color: #343a40 !important; }
.badge.bg-light { background-color: #f8f9fa !important; color: #212529 !important; }
</style>
