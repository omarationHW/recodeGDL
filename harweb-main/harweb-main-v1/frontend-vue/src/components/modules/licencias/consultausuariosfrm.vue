<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-1">
            <i class="fas fa-users me-2"></i>
            Consulta de Usuarios del Sistema
          </h3>
          <p class="mb-0 opacity-90">
            Gestión completa de usuarios y permisos del sistema
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn-municipal-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus me-1"></i>
            Nuevo Usuario
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Usuario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.usuario"
              placeholder="Nombre de usuario"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Nombre Completo</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombres"
              placeholder="Nombre completo"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Departamento</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.cvedepto"
              placeholder="Clave departamento"
            >
          </div>
          <div class="col-md-3">
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
        <div class="row mt-3">
          <div class="col-12">
            <div class="municipal-group-btn">
              <button
                class="btn-municipal-primary me-2"
                @click="searchUsuarios"
                :disabled="loading"
              >
                <i class="fas fa-search me-1"></i>
                Buscar
              </button>
              <button
                class="btn-municipal-secondary me-2"
                @click="clearFilters"
                :disabled="loading"
              >
                <i class="fas fa-times me-1"></i>
                Limpiar
              </button>
              <button
                class="btn-municipal-secondary"
                @click="loadUsuarios"
                :disabled="loading"
              >
                <i class="fas fa-sync-alt me-1"></i>
                Actualizar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Resultados de Búsqueda
          <span class="municipal-badge municipal-badge-info ms-2" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border spinner-border-sm text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>
      <div class="municipal-card-body p-0" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table mb-0">
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
              <tr v-for="usuario in usuarios" :key="usuario.usuario" class="table-row-hover">
                <td><strong class="text-primary">{{ usuario.usuario?.trim() }}</strong></td>
                <td>{{ usuario.nombres?.trim() || 'N/A' }}</td>
                <td><code class="text-muted">{{ usuario.clave?.trim() || 'Sin clave' }}</code></td>
                <td>
                  <span class="municipal-badge municipal-badge-secondary">
                    {{ usuario.cvedepto || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="municipal-badge" :class="getMunicipalLevelClass(usuario.nivel)">
                    <i class="fas fa-user-shield me-1"></i>
                    Nivel {{ usuario.nivel || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <i class="fas fa-calendar me-1"></i>
                    {{ formatDate(usuario.fecalt) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDate(usuario.fecbaj) }}
                  </small>
                </td>
                <td>
                  <span class="municipal-badge" :class="getMunicipalStatusClass(usuario.fecbaj)">
                    <i :class="getStatusIcon(usuario.fecbaj)" class="me-1"></i>
                    {{ getStatusText(usuario.fecbaj) }}
                  </span>
                </td>
                <td>
                  <div class="municipal-group-btn btn-group-sm" role="group">
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="viewUsuario(usuario)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editUsuario(usuario)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      v-if="!usuario.fecbaj"
                      class="btn-municipal-secondary btn-sm"
                      @click="confirmDeactivateUsuario(usuario)"
                      title="Dar de baja"
                    >
                      <i class="fas fa-ban"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="usuarios.length === 0 && !loading">
                <td colspan="9" class="text-center text-muted py-4">
                  <i class="fas fa-search fa-2x mb-3 text-muted"></i>
                  <p class="mb-0">No se encontraron usuarios con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div class="municipal-card-footer" v-if="totalRecords > 0 && !loading">
        <div class="row align-items-center">
          <div class="col-md-6">
            <small class="text-muted">
              <i class="fas fa-info-circle me-1"></i>
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </small>
          </div>
          <div class="col-md-6">
            <nav aria-label="Paginación de usuarios">
              <ul class="pagination pagination-sm justify-content-end mb-0">
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <button class="page-link" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                    <i class="fas fa-chevron-left"></i>
                    Anterior
                  </button>
                </li>

                <li
                  v-for="page in visiblePages"
                  :key="page"
                  class="page-item"
                  :class="{ active: page === currentPage }"
                >
                  <button class="page-link" @click="goToPage(page)">{{ page }}</button>
                </li>

                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <button class="page-link" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                    Siguiente
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay para tabla vacía -->
    <div v-if="loading && usuarios.length === 0" class="municipal-card">
      <div class="municipal-card-body text-center py-5">
        <div class="spinner-border text-primary mb-3" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="text-muted mb-0">Cargando usuarios del sistema...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <div
      class="modal fade"
      :class="{ show: showCreateModal }"
      :style="{ display: showCreateModal ? 'block' : 'none' }"
      v-if="showCreateModal"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title">
              <i class="fas fa-user-plus"></i>
              Crear Nuevo Usuario
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="createUsuario">
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label" for="usuario">Usuario:</label>
                    <input
                      type="text"
                      class="municipal-form-control"
                      id="usuario"
                      v-model="newUsuario.usuario"
                      maxlength="8"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label" for="clave">Clave:</label>
                    <input
                      type="text"
                      class="municipal-form-control"
                      id="clave"
                      v-model="newUsuario.clave"
                      maxlength="8"
                    >
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="municipal-form-label" for="nombres">Nombres:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  id="nombres"
                  v-model="newUsuario.nombres"
                  maxlength="30"
                  required
                >
              </div>
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label" for="cvedepto">Departamento:</label>
                    <input
                      type="number"
                      class="municipal-form-control"
                      id="cvedepto"
                      v-model="newUsuario.cvedepto"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label" for="nivel">Nivel:</label>
                    <select class="municipal-form-control" id="nivel" v-model="newUsuario.nivel" required>
                      <option value="">Seleccionar...</option>
                      <option value="1">Nivel 1 - Básico</option>
                      <option value="5">Nivel 5 - Intermedio</option>
                      <option value="9">Nivel 9 - Avanzado</option>
                      <option value="10">Nivel 10 - Administrador</option>
                    </select>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showCreateModal = false">
              <i class="fas fa-times me-1"></i>
              Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="createUsuario" :disabled="creatingUsuario">
              <span v-if="creatingUsuario" class="spinner-border spinner-border-sm me-2" role="status"></span>
              <i v-else class="fas fa-save me-1"></i>
              {{ creatingUsuario ? 'Creando...' : 'Crear Usuario' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de edición -->
    <div
      class="modal fade"
      :class="{ show: showEditModal }"
      :style="{ display: showEditModal ? 'block' : 'none' }"
      v-if="showEditModal"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-warning text-dark">
            <h5 class="modal-title">
              <i class="fas fa-user-edit"></i>
              Editar Usuario: {{ selectedUsuario?.usuario }}
            </h5>
            <button type="button" class="btn-close" @click="showEditModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="updateUsuario">
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Usuario (No editable):</label>
                    <input
                      type="text"
                      class="municipal-form-control"
                      :value="editForm.usuario"
                      disabled
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group mb-3">
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
              </div>
              <div class="form-group mb-3">
                <label class="municipal-form-label">Nombres Completos:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="editForm.nombres"
                  maxlength="30"
                  required
                >
              </div>
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Departamento:</label>
                    <input
                      type="number"
                      class="municipal-form-control"
                      v-model="editForm.cvedepto"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Nivel de Acceso:</label>
                    <select class="municipal-form-control" v-model="editForm.nivel" required>
                      <option value="1">Nivel 1 - Básico</option>
                      <option value="5">Nivel 5 - Intermedio</option>
                      <option value="9">Nivel 9 - Avanzado</option>
                      <option value="10">Nivel 10 - Administrador</option>
                    </select>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Fecha de Baja (opcional):</label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="editForm.fecbaj"
                    >
                    <small class="form-text text-muted">
                      Establezca una fecha para dar de baja al usuario
                    </small>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showEditModal = false">
              <i class="fas fa-times me-1"></i>
              Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="updateUsuario" :disabled="updatingUsuario">
              <span v-if="updatingUsuario" class="spinner-border spinner-border-sm me-2" role="status"></span>
              <i v-else class="fas fa-save me-1"></i>
              {{ updatingUsuario ? 'Guardando...' : 'Guardar Cambios' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de visualización -->
    <div
      class="modal fade"
      :class="{ show: showViewModal }"
      :style="{ display: showViewModal ? 'block' : 'none' }"
      v-if="showViewModal"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-info text-white">
            <h5 class="modal-title">
              <i class="fas fa-user"></i>
              Detalles del Usuario: {{ selectedUsuario?.usuario }}
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="showViewModal = false"></button>
          </div>
          <div class="modal-body">
            <div v-if="selectedUsuario" class="row">
              <div class="col-12">
                <div class="card border-0">
                  <div class="card-body">
                    <div class="row">
                      <div class="col-md-6">
                        <h6 class="text-muted mb-3">
                          <i class="fas fa-id-card"></i>
                          Información Básica
                        </h6>
                        <table class="table table-sm table-borderless">
                          <tr>
                            <td class="fw-bold text-muted">Usuario:</td>
                            <td><code class="bg-light p-1 rounded">{{ selectedUsuario.usuario?.trim() }}</code></td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Nombres:</td>
                            <td>{{ selectedUsuario.nombres?.trim() || 'N/A' }}</td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Clave:</td>
                            <td><span class="text-muted">{{ selectedUsuario.clave?.trim() ? '***oculto***' : 'Sin clave' }}</span></td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Departamento:</td>
                            <td>
                              <span class="municipal-badge municipal-badge-secondary">
                                {{ selectedUsuario.cvedepto || 'N/A' }}
                              </span>
                            </td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Nivel:</td>
                            <td>
                              <span class="municipal-badge" :class="getMunicipalLevelClass(selectedUsuario.nivel)">
                                <i class="fas fa-user-shield me-1"></i>
                                Nivel {{ selectedUsuario.nivel || 'N/A' }}
                              </span>
                            </td>
                          </tr>
                        </table>
                      </div>
                      <div class="col-md-6">
                        <h6 class="text-muted mb-3">
                          <i class="fas fa-calendar-alt"></i>
                          Fechas y Control
                        </h6>
                        <table class="table table-sm table-borderless">
                          <tr>
                            <td class="fw-bold text-muted">Fecha Alta:</td>
                            <td>
                              <i class="fas fa-calendar-plus text-success"></i>
                              {{ formatDate(selectedUsuario.fecalt) }}
                            </td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Fecha Baja:</td>
                            <td>
                              <i class="fas fa-calendar-minus text-danger"></i>
                              {{ formatDate(selectedUsuario.fecbaj) }}
                            </td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Fecha Captura:</td>
                            <td>
                              <i class="fas fa-clock text-info"></i>
                              {{ formatDate(selectedUsuario.feccap) }}
                            </td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Capturó:</td>
                            <td>{{ selectedUsuario.capturo?.trim() || 'N/A' }}</td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Estado:</td>
                            <td>
                              <span class="municipal-badge" :class="getMunicipalStatusClass(selectedUsuario.fecbaj)">
                                <i :class="getStatusIcon(selectedUsuario.fecbaj)" class="me-1"></i>
                                {{ getStatusText(selectedUsuario.fecbaj) }}
                              </span>
                            </td>
                          </tr>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showViewModal = false">
              <i class="fas fa-times me-1"></i>
              Cerrar
            </button>
            <button type="button" class="btn-municipal-primary" @click="editUsuario(selectedUsuario); showViewModal = false">
              <i class="fas fa-edit me-1"></i>
              Editar Usuario
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import Swal from 'sweetalert2'

export default {
  name: 'consultausuariosfrm',
  // Component for managing users in the system - Fixed API response structure
  data() {
    return {
      usuarios: [],
      loading: false,
      creatingUsuario: false,
      updatingUsuario: false,
      currentPage: 1,
      itemsPerPage: 10,
      totalRecords: 0,
      selectedUsuario: null,
      showCreateModal: false,
      showEditModal: false,
      showViewModal: false,

      // Filtros de búsqueda
      filters: {
        usuario: '',
        nombres: '',
        cvedepto: '',
        nivel: ''
      },

      // Formulario de nuevo usuario
      newUsuario: {
        usuario: '',
        cvedepto: null,
        nombres: '',
        clave: '',
        nivel: null
      },

      // Formulario de edición
      editForm: {
        usuario: '',
        cvedepto: null,
        nombres: '',
        clave: '',
        nivel: null,
        fecbaj: null
      }
    }
  },

  computed: {
    totalPages() {
      return Math.ceil(this.totalRecords / this.itemsPerPage)
    },

    visiblePages() {
      const pages = []
      const start = Math.max(1, this.currentPage - 2)
      const end = Math.min(this.totalPages, this.currentPage + 2)

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      return pages
    }
  },

  methods: {
    // Método principal para cargar usuarios
    async loadUsuarios() {
      this.loading = true
      try {
        // Construir parámetros de búsqueda
        const searchTerms = []
        if (this.filters.usuario) searchTerms.push(this.filters.usuario)
        if (this.filters.nombres) searchTerms.push(this.filters.nombres)
        if (this.filters.cvedepto) searchTerms.push(this.filters.cvedepto)
        if (this.filters.nivel) searchTerms.push(this.filters.nivel)

        const searchTerm = searchTerms.join(' ')

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_CONSULTAUSUARIOS_LIST',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_page', valor: this.currentPage },
                { nombre: 'p_limit', valor: this.itemsPerPage },
                { nombre: 'p_search', valor: searchTerm || null }
              ]
            }
          })
        })

        const responseData = await response.json()

        console.log('API Response:', responseData)

        // Usar nueva estructura data.eResponse.success && data.eResponse.data.result
        if (responseData.eResponse && responseData.eResponse.success && responseData.eResponse.data) {
          this.usuarios = responseData.eResponse.data.result
          if (this.usuarios.length > 0) {
            this.totalRecords = parseInt(this.usuarios[0].total_records) || 0
          } else {
            this.totalRecords = 0
          }

          // Toast de éxito
          this.showToast('Usuarios cargados correctamente', 'success')
        } else {
          console.error('Error en la respuesta:', responseData)
          this.usuarios = []
          this.totalRecords = 0
          this.showToast('Error al cargar usuarios', 'error')
        }
      } catch (error) {
        console.error('Error loading usuarios:', error)
        this.usuarios = []
        this.totalRecords = 0
        this.showToast('Error de conexión al cargar usuarios', 'error')
      } finally {
        this.loading = false
      }
    },

    // Métodos de búsqueda y filtros
    searchUsuarios() {
      this.currentPage = 1
      this.loadUsuarios()
    },

    clearFilters() {
      this.filters = {
        usuario: '',
        nombres: '',
        cvedepto: '',
        nivel: ''
      }
      this.currentPage = 1
      this.loadUsuarios()
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        this.loadUsuarios()
      }
    },

    // Métodos de modales
    openCreateModal() {
      this.newUsuario = {
        usuario: '',
        cvedepto: null,
        nombres: '',
        clave: '',
        nivel: null
      }
      this.showCreateModal = true
    },

    // Métodos CRUD
    async createUsuario() {
      // Validación de campos requeridos
      if (!this.newUsuario.usuario || !this.newUsuario.nombres || !this.newUsuario.cvedepto || !this.newUsuario.nivel) {
        await Swal.fire({
          icon: 'warning',
          title: 'Campos requeridos',
          text: 'Por favor complete todos los campos obligatorios: Usuario, Nombres, Departamento y Nivel',
          confirmButtonColor: '#6f42c1'
        })
        return
      }

      this.creatingUsuario = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_CONSULTAUSUARIOS_CREATE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_usuario', valor: this.newUsuario.usuario.trim().toUpperCase() },
                { nombre: 'p_cvedepto', valor: this.newUsuario.cvedepto },
                { nombre: 'p_nombres', valor: this.newUsuario.nombres.trim() },
                { nombre: 'p_clave', valor: this.newUsuario.clave?.trim() || '' },
                { nombre: 'p_nivel', valor: this.newUsuario.nivel },
                { nombre: 'p_capturo', valor: 'sistema' }
              ]
            }
          })
        })

        const responseData = await response.json()

        console.log('Create Response:', responseData)

        if (responseData.eResponse && responseData.eResponse.success && responseData.eResponse.data) {
          const result = responseData.eResponse.data.result[0]

          if (result?.success) {
            this.showCreateModal = false
            this.loadUsuarios()

            await Swal.fire({
              icon: 'success',
              title: '¡Usuario creado!',
              text: 'El usuario ha sido creado exitosamente',
              confirmButtonColor: '#6f42c1',
              timer: 2000
            })

            this.showToast('Usuario creado exitosamente', 'success')
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Error al crear usuario',
              text: result?.message || 'Error desconocido',
              confirmButtonColor: '#6f42c1'
            })
          }
        } else {
          throw new Error('Respuesta inválida del servidor')
        }
      } catch (error) {
        console.error('Error creating usuario:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error de conexión',
          text: 'No se pudo crear el usuario. Verifique su conexión.',
          confirmButtonColor: '#6f42c1'
        })
      } finally {
        this.creatingUsuario = false
      }
    },

    editUsuario(usuario) {
      this.selectedUsuario = usuario
      this.editForm = {
        usuario: usuario.usuario?.trim(),
        cvedepto: usuario.cvedepto,
        nombres: usuario.nombres?.trim() || '',
        clave: '',  // No mostrar clave actual por seguridad
        nivel: usuario.nivel,
        fecbaj: usuario.fecbaj ? usuario.fecbaj.split('T')[0] : null
      }
      this.showEditModal = true
    },

    async updateUsuario() {
      // Validación de campos requeridos
      if (!this.editForm.nombres || !this.editForm.cvedepto || !this.editForm.nivel) {
        await Swal.fire({
          icon: 'warning',
          title: 'Campos requeridos',
          text: 'Por favor complete los campos obligatorios: Nombres, Departamento y Nivel',
          confirmButtonColor: '#6f42c1'
        })
        return
      }

      this.updatingUsuario = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_CONSULTAUSUARIOS_UPDATE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_usuario', valor: this.editForm.usuario },
                { nombre: 'p_cvedepto', valor: this.editForm.cvedepto },
                { nombre: 'p_nombres', valor: this.editForm.nombres.trim() },
                { nombre: 'p_clave', valor: this.editForm.clave?.trim() || '' },
                { nombre: 'p_nivel', valor: this.editForm.nivel },
                { nombre: 'p_fecbaj', valor: this.editForm.fecbaj },
                { nombre: 'p_capturo', valor: 'sistema' }
              ]
            }
          })
        })

        const responseData = await response.json()

        console.log('Update Response:', responseData)

        if (responseData.eResponse && responseData.eResponse.success && responseData.eResponse.data) {
          const result = responseData.eResponse.data.result[0]

          if (result?.success) {
            this.showEditModal = false
            this.loadUsuarios()

            await Swal.fire({
              icon: 'success',
              title: '¡Usuario actualizado!',
              text: 'Los datos del usuario han sido actualizados exitosamente',
              confirmButtonColor: '#6f42c1',
              timer: 2000
            })

            this.showToast('Usuario actualizado exitosamente', 'success')
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Error al actualizar usuario',
              text: result?.message || 'Error desconocido',
              confirmButtonColor: '#6f42c1'
            })
          }
        } else {
          throw new Error('Respuesta inválida del servidor')
        }
      } catch (error) {
        console.error('Error updating usuario:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error de conexión',
          text: 'No se pudo actualizar el usuario. Verifique su conexión.',
          confirmButtonColor: '#6f42c1'
        })
      } finally {
        this.updatingUsuario = false
      }
    },

    viewUsuario(usuario) {
      this.selectedUsuario = usuario
      this.showViewModal = true
    },

    async confirmDeactivateUsuario(usuario) {
      const result = await Swal.fire({
        title: '¿Dar de baja usuario?',
        text: `¿Está seguro de dar de baja al usuario "${usuario.usuario?.trim()}"? Esta acción desactivará el acceso al sistema.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, dar de baja',
        cancelButtonText: 'Cancelar',
        reverseButtons: true
      })

      if (result.isConfirmed) {
        await this.deactivateUsuario(usuario)
      }
    },

    async deactivateUsuario(usuario) {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_CONSULTAUSUARIOS_DELETE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_usuario', valor: usuario.usuario?.trim() },
                { nombre: 'p_capturo', valor: 'sistema' }
              ]
            }
          })
        })

        const responseData = await response.json()

        console.log('Deactivate Response:', responseData)

        if (responseData.eResponse && responseData.eResponse.success && responseData.eResponse.data) {
          const result = responseData.eResponse.data.result[0]

          if (result?.success) {
            this.loadUsuarios()

            await Swal.fire({
              icon: 'success',
              title: '¡Usuario dado de baja!',
              text: 'El usuario ha sido desactivado exitosamente',
              confirmButtonColor: '#6f42c1',
              timer: 2000
            })

            this.showToast('Usuario dado de baja exitosamente', 'success')
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Error al dar de baja',
              text: result?.message || 'Error desconocido',
              confirmButtonColor: '#6f42c1'
            })
          }
        } else {
          throw new Error('Respuesta inválida del servidor')
        }
      } catch (error) {
        console.error('Error deactivating usuario:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error de conexión',
          text: 'No se pudo dar de baja el usuario. Verifique su conexión.',
          confirmButtonColor: '#6f42c1'
        })
      }
    },

    // Métodos auxiliares y de UI
    showToast(message, type = 'info') {
      const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.addEventListener('mouseenter', Swal.stopTimer)
          toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
      })

      const iconMap = {
        success: 'success',
        error: 'error',
        warning: 'warning',
        info: 'info'
      }

      Toast.fire({
        icon: iconMap[type] || 'info',
        title: message
      })
    },

    getLevelClass(nivel) {
      const classes = {
        1: 'badge-secondary',
        5: 'badge-info',
        9: 'badge-warning',
        10: 'badge-primary'
      }
      return classes[nivel] || 'badge-secondary'
    },

    getMunicipalLevelClass(nivel) {
      const classes = {
        1: 'municipal-badge-secondary',
        5: 'municipal-badge-info',
        9: 'municipal-badge-warning',
        10: 'municipal-badge-primary'
      }
      return classes[nivel] || 'municipal-badge-secondary'
    },

    getStatusClass(fecbaj) {
      return fecbaj ? 'badge badge-danger' : 'badge badge-success'
    },

    getMunicipalStatusClass(fecbaj) {
      return fecbaj ? 'municipal-badge-danger' : 'municipal-badge-success'
    },

    getStatusText(fecbaj) {
      return fecbaj ? 'Inactivo' : 'Activo'
    },

    getStatusIcon(fecbaj) {
      return fecbaj ? 'fas fa-times-circle' : 'fas fa-check-circle'
    },

    formatDate(dateString) {
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
  },

  mounted() {
    console.log('ConsultaUsuariosfrm component mounted')
    this.loadUsuarios()
  },

  beforeUnmount() {
    // Limpiar cualquier modal abierto
    this.showCreateModal = false
    this.showEditModal = false
    this.showViewModal = false
  }
}
</script>

