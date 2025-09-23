<template>
  <div class="consultausuarios-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-users"></i>
            Consulta de Usuarios del Sistema
          </h3>
          <p class="module-description mb-0">
            Gestión completa de usuarios y permisos del sistema
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nuevo Usuario
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="form-label">Usuario</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.usuario"
              placeholder="Nombre de usuario"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Nombre Completo</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.nombres"
              placeholder="Nombre completo"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Departamento</label>
            <input
              type="number"
              class="form-control"
              v-model="filters.cvedepto"
              placeholder="Clave departamento"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Nivel</label>
            <select class="form-control" v-model="filters.nivel">
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
            <button
              class="btn btn-outline-primary me-2"
              @click="searchUsuarios"
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
              @click="loadUsuarios"
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
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list"></i>
          Resultados de Búsqueda
          <span class="badge badge-info ms-2" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border spinner-border-sm text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>
      <div class="card-body p-0" v-if="!loading">
        <div class="table-responsive">
          <table class="table table-striped table-hover mb-0">
            <thead class="thead-dark">
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
                  <span class="badge badge-outline-secondary">
                    {{ usuario.cvedepto || 'N/A' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getLevelClass(usuario.nivel)">
                    <i class="fas fa-user-shield"></i>
                    Nivel {{ usuario.nivel || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <i class="fas fa-calendar"></i>
                    {{ formatDate(usuario.fecalt) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDate(usuario.fecbaj) }}
                  </small>
                </td>
                <td>
                  <span :class="getStatusClass(usuario.fecbaj)">
                    <i :class="getStatusIcon(usuario.fecbaj)"></i>
                    {{ getStatusText(usuario.fecbaj) }}
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm" role="group">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewUsuario(usuario)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-warning"
                      @click="editUsuario(usuario)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      v-if="!usuario.fecbaj"
                      class="btn btn-outline-danger"
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
      <div class="card-footer" v-if="totalRecords > 0 && !loading">
        <div class="row align-items-center">
          <div class="col-md-6">
            <small class="text-muted">
              <i class="fas fa-info-circle"></i>
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
    <div v-if="loading && usuarios.length === 0" class="card">
      <div class="card-body text-center py-5">
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
                    <label for="usuario">Usuario:</label>
                    <input
                      type="text"
                      class="form-control"
                      id="usuario"
                      v-model="newUsuario.usuario"
                      maxlength="8"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="clave">Clave:</label>
                    <input
                      type="text"
                      class="form-control"
                      id="clave"
                      v-model="newUsuario.clave"
                      maxlength="8"
                    >
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label for="nombres">Nombres:</label>
                <input
                  type="text"
                  class="form-control"
                  id="nombres"
                  v-model="newUsuario.nombres"
                  maxlength="30"
                  required
                >
              </div>
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="cvedepto">Departamento:</label>
                    <input
                      type="number"
                      class="form-control"
                      id="cvedepto"
                      v-model="newUsuario.cvedepto"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label for="nivel">Nivel:</label>
                    <select class="form-control" id="nivel" v-model="newUsuario.nivel" required>
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
            <button type="button" class="btn btn-outline-secondary" @click="showCreateModal = false">
              <i class="fas fa-times"></i>
              Cancelar
            </button>
            <button type="button" class="btn btn-primary" @click="createUsuario" :disabled="creatingUsuario">
              <span v-if="creatingUsuario" class="spinner-border spinner-border-sm me-2" role="status"></span>
              <i v-else class="fas fa-save"></i>
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
                    <label class="form-label">Usuario (No editable):</label>
                    <input
                      type="text"
                      class="form-control"
                      :value="editForm.usuario"
                      disabled
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="form-label">Nueva Clave (opcional):</label>
                    <input
                      type="password"
                      class="form-control"
                      v-model="editForm.clave"
                      maxlength="8"
                      placeholder="Dejar vacío para mantener actual"
                    >
                  </div>
                </div>
              </div>
              <div class="form-group mb-3">
                <label class="form-label">Nombres Completos:</label>
                <input
                  type="text"
                  class="form-control"
                  v-model="editForm.nombres"
                  maxlength="30"
                  required
                >
              </div>
              <div class="row">
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="form-label">Departamento:</label>
                    <input
                      type="number"
                      class="form-control"
                      v-model="editForm.cvedepto"
                      required
                    >
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group mb-3">
                    <label class="form-label">Nivel de Acceso:</label>
                    <select class="form-control" v-model="editForm.nivel" required>
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
                    <label class="form-label">Fecha de Baja (opcional):</label>
                    <input
                      type="date"
                      class="form-control"
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
            <button type="button" class="btn btn-outline-secondary" @click="showEditModal = false">
              <i class="fas fa-times"></i>
              Cancelar
            </button>
            <button type="button" class="btn btn-warning" @click="updateUsuario" :disabled="updatingUsuario">
              <span v-if="updatingUsuario" class="spinner-border spinner-border-sm me-2" role="status"></span>
              <i v-else class="fas fa-save"></i>
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
                              <span class="badge badge-outline-secondary">
                                {{ selectedUsuario.cvedepto || 'N/A' }}
                              </span>
                            </td>
                          </tr>
                          <tr>
                            <td class="fw-bold text-muted">Nivel:</td>
                            <td>
                              <span class="badge" :class="getLevelClass(selectedUsuario.nivel)">
                                <i class="fas fa-user-shield"></i>
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
                              <span :class="getStatusClass(selectedUsuario.fecbaj)">
                                <i :class="getStatusIcon(selectedUsuario.fecbaj)"></i>
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
            <button type="button" class="btn btn-outline-secondary" @click="showViewModal = false">
              <i class="fas fa-times"></i>
              Cerrar
            </button>
            <button type="button" class="btn btn-warning" @click="editUsuario(selectedUsuario); showViewModal = false">
              <i class="fas fa-edit"></i>
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
              Parametros: [this.currentPage, this.itemsPerPage, searchTerm]
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
              Parametros: [
                this.newUsuario.usuario.trim().toUpperCase(),
                this.newUsuario.cvedepto,
                this.newUsuario.nombres.trim(),
                this.newUsuario.clave?.trim() || '',
                this.newUsuario.nivel,
                'sistema'
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
              Parametros: [
                this.editForm.usuario,
                this.editForm.cvedepto,
                this.editForm.nombres.trim(),
                this.editForm.clave?.trim() || '',
                this.editForm.nivel,
                this.editForm.fecbaj,
                'sistema'
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
              Parametros: [
                usuario.usuario?.trim(),
                'sistema'
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

    getStatusClass(fecbaj) {
      return fecbaj ? 'badge badge-danger' : 'badge badge-success'
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

<style scoped>
/* ==================================== */
/* CONSULTAUSUARIOS - TEMA PÚPURA */
/* ==================================== */

.consultausuarios-module {
  padding: 1.5rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  min-height: 100vh;
}

/* Header del módulo */
.module-header {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  color: white;
  padding: 2rem;
  border-radius: 15px;
  margin-bottom: 2rem;
  box-shadow: 0 10px 30px rgba(111, 66, 193, 0.3);
}

.module-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
}

.module-title i {
  margin-right: 1rem;
  color: #ffd700;
}

.module-description {
  font-size: 1.1rem;
  opacity: 0.9;
  font-weight: 300;
}

/* Cards y contenedores */
.card {
  border: none;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}

.card-header {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  color: white;
  border-radius: 15px 15px 0 0 !important;
  border-bottom: none;
  padding: 1.5rem;
  font-weight: 600;
}

.card-header h5 {
  margin: 0;
  font-size: 1.2rem;
}

.card-header .badge {
  background-color: rgba(255,255,255,0.2);
  color: white;
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
}

/* Botones principales */
.btn-primary {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  border: none;
  border-radius: 10px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(111, 66, 193, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(111, 66, 193, 0.4);
  background: linear-gradient(135deg, #5a359a 0%, #4a2c63 100%);
}

.btn-outline-primary {
  color: #6f42c1;
  border-color: #6f42c1;
  border-radius: 10px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-outline-primary:hover {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  border-color: #6f42c1;
  transform: translateY(-1px);
}

/* Tabla */
.table {
  border-radius: 10px;
  overflow: hidden;
}

.table th {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
  border: none;
  padding: 1rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.table td {
  font-size: 0.9rem;
  vertical-align: middle;
  padding: 1rem;
  border-color: #dee2e6;
}

.table-row-hover:hover {
  background-color: rgba(111, 66, 193, 0.05);
  transition: all 0.2s ease;
}

/* Badges y estados */
.badge {
  font-size: 0.8rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
}

.badge-primary {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  color: white;
}

.badge-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  color: white;
}

.badge-warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
  color: #212529;
}

.badge-success {
  background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
  color: white;
}

.badge-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
}

.badge-secondary {
  background: linear-gradient(135deg, #6c757d 0%, #545b62 100%);
  color: white;
}

.badge-outline-secondary {
  background: rgba(108, 117, 125, 0.1);
  color: #6c757d;
  border: 1px solid #6c757d;
}

/* Botones de acción */
.btn-group-sm .btn {
  border-radius: 8px;
  margin: 0 2px;
  transition: all 0.2s ease;
}

.btn-outline-primary:hover {
  background: #6f42c1;
  border-color: #6f42c1;
  transform: scale(1.05);
}

.btn-outline-warning:hover {
  background: #ffc107;
  border-color: #ffc107;
  transform: scale(1.05);
}

.btn-outline-danger:hover {
  background: #dc3545;
  border-color: #dc3545;
  transform: scale(1.05);
}

/* Formularios */
.form-control {
  border-radius: 10px;
  border: 2px solid #e9ecef;
  padding: 0.75rem 1rem;
  transition: all 0.3s ease;
}

.form-control:focus {
  border-color: #6f42c1;
  box-shadow: 0 0 0 0.2rem rgba(111, 66, 193, 0.25);
}

.form-label {
  font-weight: 600;
  color: #495057;
  margin-bottom: 0.5rem;
}

/* Modales */
.modal-content {
  border: none;
  border-radius: 15px;
  box-shadow: 0 10px 50px rgba(0,0,0,0.3);
}

.modal-header {
  border-radius: 15px 15px 0 0;
  border-bottom: none;
  padding: 1.5rem 2rem;
}

.modal-body {
  padding: 2rem;
}

.modal-footer {
  border-top: none;
  padding: 1.5rem 2rem;
  border-radius: 0 0 15px 15px;
}

/* Paginación */
.pagination {
  gap: 0.5rem;
}

.page-link {
  border: none;
  border-radius: 8px;
  color: #6f42c1;
  font-weight: 600;
  padding: 0.75rem 1rem;
  transition: all 0.2s ease;
}

.page-item.active .page-link {
  background: linear-gradient(135deg, #6f42c1 0%, #563d7c 100%);
  color: white;
  box-shadow: 0 4px 10px rgba(111, 66, 193, 0.3);
}

.page-link:hover {
  background: rgba(111, 66, 193, 0.1);
  color: #6f42c1;
  transform: translateY(-1px);
}

/* Spinner personalizado */
.spinner-border {
  width: 1.5rem;
  height: 1.5rem;
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

/* Código de texto */
code {
  background: rgba(111, 66, 193, 0.1);
  color: #6f42c1;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.85rem;
}

/* Texto primario */
.text-primary {
  color: #6f42c1 !important;
}

/* Efectos de hover para filas */
.table tbody tr:hover {
  background-color: rgba(111, 66, 193, 0.05);
}

/* Animaciones */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.card {
  animation: slideIn 0.3s ease-out;
}

/* Responsive */
@media (max-width: 768px) {
  .consultausuarios-module {
    padding: 1rem;
  }

  .module-header {
    padding: 1.5rem;
  }

  .module-title {
    font-size: 1.5rem;
  }

  .table-responsive {
    border-radius: 10px;
  }
}

/* Estados de carga */
.loading-overlay {
  position: relative;
}

.loading-overlay::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  z-index: 10;
  border-radius: 15px;
}
</style>
