<template>
  <div class="container-fluid px-4 py-3">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-shield-alt"></i> Seguridad</li>
        <li class="breadcrumb-item active" aria-current="page">Control de Privilegios</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h3 mb-1"><i class="fas fa-users-cog text-primary me-2"></i>Control de Privilegios</h2>
            <p class="text-muted mb-0">Gestión de roles, permisos y auditoría de usuarios</p>
          </div>
          <div>
            <button class="btn btn-success me-2" @click="showAuditModal = true" title="Ver Auditoría Global">
              <i class="fas fa-file-alt me-1"></i>Auditoría
            </button>
            <button class="btn btn-primary" @click="showModal = true; modalTitle = 'Nuevo Privilegio'; currentItem = {};">
              <i class="fas fa-plus me-1"></i>Nuevo Privilegio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Buscar usuario:</label>
            <input v-model="filters.usuario" @input="loadPrivilegios" type="text" class="form-control" placeholder="Usuario o nombre...">
          </div>
          <div class="col-md-3">
            <label class="form-label">Departamento:</label>
            <select v-model="filters.departamento" @change="loadPrivilegios" class="form-select">
              <option value="">Todos</option>
              <option value="SISTEMAS">Sistemas</option>
              <option value="LICENCIAS">Licencias</option>
              <option value="RECAUDACION">Recaudación</option>
              <option value="ADMINISTRACION">Administración</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado:</label>
            <select v-model="filters.estado" @change="loadPrivilegios" class="form-select">
              <option value="">Todos</option>
              <option value="1">Activo</option>
              <option value="0">Baja</option>
            </select>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button @click="resetFilters" class="btn btn-outline-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de usuarios -->
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Usuarios del Sistema</h5>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando usuarios...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th @click="sortBy('usuario')" class="sortable">Usuario <i class="fas fa-sort"></i></th>
                  <th @click="sortBy('nombres')" class="sortable">Nombre <i class="fas fa-sort"></i></th>
                  <th @click="sortBy('nombredepto')" class="sortable">Departamento <i class="fas fa-sort"></i></th>
                  <th>Estado</th>
                  <th>Permisos</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="usuario in usuarios" :key="usuario.usuario"
                    :class="{ 'table-active': selectedUsuario?.usuario === usuario.usuario }">
                  <td>
                    <div class="d-flex align-items-center">
                      <i class="fas fa-user-circle text-muted me-2"></i>
                      {{ usuario.usuario }}
                    </div>
                  </td>
                  <td>{{ usuario.nombres }}</td>
                  <td>
                    <span class="badge bg-info">{{ usuario.nombredepto || 'Sin asignar' }}</span>
                  </td>
                  <td>
                    <span :class="usuario.baja ? 'badge bg-danger' : 'badge bg-success'">
                      {{ usuario.baja ? 'Baja' : 'Activo' }}
                    </span>
                  </td>
                  <td>
                    <span class="badge bg-primary">{{ usuario.total_permisos || 0 }} permisos</span>
                  </td>
                  <td>
                    <div class="btn-group" role="group">
                      <button @click="selectUsuario(usuario)" class="btn btn-sm btn-outline-primary" title="Ver Permisos">
                        <i class="fas fa-key"></i>
                      </button>
                      <button @click="editPrivileges(usuario)" class="btn btn-sm btn-outline-warning" title="Asignar Privilegio">
                        <i class="fas fa-plus"></i>
                      </button>
                      <button @click="viewAuditoria(usuario)" class="btn btn-sm btn-outline-info" title="Ver Auditoría">
                        <i class="fas fa-history"></i>
                      </button>
                      <button @click="exportUserPrivileges(usuario)" class="btn btn-sm btn-outline-success" title="Exportar Privilegios">
                        <i class="fas fa-download"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagination.total > pagination.limit" class="d-flex justify-content-between align-items-center p-3 bg-light">
            <span class="text-muted">
              Mostrando {{ ((pagination.page - 1) * pagination.limit) + 1 }} a {{ Math.min(pagination.page * pagination.limit, pagination.total) }} de {{ pagination.total }} registros
            </span>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: pagination.page <= 1 }">
                  <button class="page-link" @click="changePage(pagination.page - 1)">Anterior</button>
                </li>
                <li v-for="page in getPageNumbers()" :key="page" class="page-item" :class="{ active: page === pagination.page }">
                  <button class="page-link" @click="changePage(page)">{{ page }}</button>
                </li>
                <li class="page-item" :class="{ disabled: pagination.page >= Math.ceil(pagination.total / pagination.limit) }">
                  <button class="page-link" @click="changePage(pagination.page + 1)">Siguiente</button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Detalle del usuario seleccionado -->
    <div v-if="selectedUsuario" class="row mt-4">
      <div class="col-md-6">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0"><i class="fas fa-key me-2"></i>Permisos Actuales - {{ selectedUsuario.usuario }}</h5>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Tag</th>
                    <th>Permiso</th>
                    <th>Acción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="permiso in permisos" :key="permiso.num_tag">
                    <td><span class="badge bg-secondary">{{ permiso.num_tag }}</span></td>
                    <td>{{ permiso.descripcion }}</td>
                    <td>
                      <button @click="revokePermission(permiso)" class="btn btn-sm btn-outline-danger" title="Revocar">
                        <i class="fas fa-times"></i>
                      </button>
                    </td>
                  </tr>
                  <tr v-if="permisos.length === 0">
                    <td colspan="3" class="text-center text-muted py-3">Sin permisos asignados</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-6">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0"><i class="fas fa-history me-2"></i>Auditoría Reciente</h5>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
              <table class="table table-sm mb-0">
                <thead class="table-light sticky-top">
                  <tr>
                    <th>Fecha</th>
                    <th>Acción</th>
                    <th>Tag</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="aud in auditoria" :key="aud.id">
                    <td class="text-nowrap">{{ formatDateTime(aud.fechahora) }}</td>
                    <td>
                      <span :class="getAuditActionClass(aud.proc)">{{ aud.proc }}</span>
                    </td>
                    <td><span class="badge bg-secondary">{{ aud.num_tag }}</span></td>
                  </tr>
                  <tr v-if="auditoria.length === 0">
                    <td colspan="3" class="text-center text-muted py-3">Sin registros de auditoría</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para nuevo privilegio -->
    <div class="modal fade" :class="{ show: showModal }" :style="{ display: showModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveItem">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Usuario <span class="text-danger">*</span></label>
                  <select v-model="currentItem.usuario" class="form-select" required>
                    <option value="">Seleccione un usuario</option>
                    <option v-for="user in usuarios" :key="user.usuario" :value="user.usuario">
                      {{ user.usuario }} - {{ user.nombres }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Número Tag <span class="text-danger">*</span></label>
                  <input v-model="currentItem.num_tag" type="number" class="form-control" required>
                </div>
                <div class="col-12">
                  <label class="form-label">Descripción del Permiso <span class="text-danger">*</span></label>
                  <input v-model="currentItem.descripcion" type="text" class="form-control" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Fecha Inicio</label>
                  <input v-model="currentItem.fecha_inicio" type="date" class="form-control">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Fecha Fin</label>
                  <input v-model="currentItem.fecha_fin" type="date" class="form-control">
                </div>
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea v-model="currentItem.observaciones" class="form-control" rows="2"></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="saveItem">
              <i class="fas fa-save me-1"></i>Guardar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de auditoría global -->
    <div class="modal fade" :class="{ show: showAuditModal }" :style="{ display: showAuditModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Auditoría Global de Privilegios</h5>
            <button type="button" class="btn-close" @click="showAuditModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-striped">
                <thead>
                  <tr>
                    <th>Usuario</th>
                    <th>Tag</th>
                    <th>Descripción</th>
                    <th>Acción</th>
                    <th>Fecha/Hora</th>
                    <th>Equipo</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="audit in globalAuditoria" :key="audit.id">
                    <td>{{ audit.usuario }}</td>
                    <td><span class="badge bg-secondary">{{ audit.num_tag }}</span></td>
                    <td>{{ audit.descripcion }}</td>
                    <td><span :class="getAuditActionClass(audit.proc)">{{ audit.proc }}</span></td>
                    <td>{{ formatDateTime(audit.fechahora) }}</td>
                    <td>{{ audit.equipo }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal || showAuditModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import Swal from 'sweetalert2'

export default {
  name: 'PrivilegiosPage',
  data() {
    return {
      usuarios: [],
      selectedUsuario: null,
      permisos: [],
      auditoria: [],
      globalAuditoria: [],
      loading: false,
      showModal: false,
      showAuditModal: false,
      modalTitle: '',
      currentItem: {
        usuario: '',
        num_tag: '',
        descripcion: '',
        fecha_inicio: '',
        fecha_fin: '',
        observaciones: ''
      },
      filters: {
        usuario: '',
        departamento: '',
        estado: ''
      },
      sortField: 'usuario',
      sortDir: 'asc',
      pagination: {
        page: 1,
        limit: 10,
        total: 0
      }
    }
  },
  mounted() {
    this.loadPrivilegios()
  },
  methods: {
    async loadPrivilegios() {
      this.loading = true
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_usuarios_privilegios_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_filtro_usuario', valor: this.filters.usuario || null },
              { nombre: 'p_filtro_departamento', valor: this.filters.departamento || null },
              { nombre: 'p_filtro_estado', valor: this.filters.estado || null },
              { nombre: 'p_campo_orden', valor: this.sortField },
              { nombre: 'p_direccion_orden', valor: this.sortDir },
              { nombre: 'p_limite_pag', valor: this.pagination.limit },
              { nombre: 'p_offset_pag', valor: (this.pagination.page - 1) * this.pagination.limit }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.success && response.data.data) {
          this.usuarios = response.data.data || []
          this.pagination.total = response.data.data[0]?.total_registros || 0
        }
      } catch (error) {
        console.error('Error cargando usuarios:', error)
        this.$toast?.error('Error al cargar los usuarios')
      } finally {
        this.loading = false
      }
    },

    async selectUsuario(usuario) {
      this.selectedUsuario = usuario
      this.permisos = []
      this.auditoria = []

      try {
        // Cargar permisos del usuario
        const permisosResponse = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_usuario_permisos_get',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario_buscar', valor: usuario.usuario }
            ],
            Tenant: 'public'
          }
        })

        if (permisosResponse.data?.success && permisosResponse.data?.data) {
          this.permisos = permisosResponse.data.data
        }

        // Cargar auditoría del usuario
        const auditoriaResponse = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_usuario_auditoria_get',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario_audit', valor: usuario.usuario },
              { nombre: 'p_limite_audit', valor: 20 }
            ],
            Tenant: 'public'
          }
        })

        if (auditoriaResponse.data?.success && auditoriaResponse.data?.data) {
          this.auditoria = auditoriaResponse.data.data
        }
      } catch (error) {
        console.error('Error cargando detalles del usuario:', error)
        this.$toast?.error('Error al cargar los detalles del usuario')
      }
    },

    async saveItem() {
      try {
        const isUpdate = this.currentItem.id
        const operation = isUpdate ? 'sp_privilegio_actualizar' : 'sp_privilegio_asignar'

        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: operation,
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario_destino', valor: this.currentItem.usuario },
              { nombre: 'p_numero_tag', valor: this.currentItem.num_tag },
              { nombre: 'p_descripcion_permiso', valor: this.currentItem.descripcion },
              { nombre: 'p_fecha_vigencia_inicio', valor: this.currentItem.fecha_inicio || null },
              { nombre: 'p_fecha_vigencia_fin', valor: this.currentItem.fecha_fin || null },
              { nombre: 'p_observaciones_permiso', valor: this.currentItem.observaciones || null },
              { nombre: 'p_usuario_asigna', valor: this.$store.state.auth?.user?.usuario || 'sistema' }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.success) {
          await Swal.fire({
            icon: 'success',
            title: 'Éxito',
            text: isUpdate ? 'Privilegio actualizado correctamente' : 'Privilegio asignado correctamente',
            timer: 3000,
            showConfirmButton: false
          })

          this.closeModal()
          this.loadPrivilegios()

          // Si hay usuario seleccionado, recargar sus permisos
          if (this.selectedUsuario) {
            this.selectUsuario(this.selectedUsuario)
          }
        } else {
          throw new Error(response.data?.message || 'Error en la operación')
        }
      } catch (error) {
        console.error('Error guardando privilegio:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message || 'Error al guardar el privilegio',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async revokePermission(permiso) {
      const result = await Swal.fire({
        title: '¿Revocar permiso?',
        text: `¿Desea revocar el permiso "${permiso.descripcion}" del usuario ${this.selectedUsuario.usuario}?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, revocar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_privilegio_revocar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_usuario_objetivo', valor: this.selectedUsuario.usuario },
                { nombre: 'p_numero_tag_revoke', valor: permiso.num_tag },
                { nombre: 'p_usuario_revoca', valor: this.$store.state.auth?.user?.usuario || 'sistema' },
                { nombre: 'p_motivo_revocacion', valor: 'Revocación manual desde interfaz' }
              ],
              Tenant: 'public'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'Permiso revocado',
              text: 'El permiso ha sido revocado correctamente',
              timer: 3000,
              showConfirmButton: false
            })

            // Recargar permisos del usuario
            this.selectUsuario(this.selectedUsuario)
          }
        } catch (error) {
          console.error('Error revocando permiso:', error)
          await Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al revocar el permiso',
            timer: 5000,
            showConfirmButton: false
          })
        }
      }
    },

    async editPrivileges(usuario) {
      this.currentItem = {
        usuario: usuario.usuario,
        num_tag: '',
        descripcion: '',
        fecha_inicio: '',
        fecha_fin: '',
        observaciones: ''
      }
      this.modalTitle = `Asignar Privilegio - ${usuario.usuario}`
      this.showModal = true
    },

    async viewAuditoria(usuario) {
      this.selectUsuario(usuario)
    },

    async loadGlobalAuditoria() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_auditoria_privilegios_global',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_limite_registros', valor: 100 },
              { nombre: 'p_fecha_desde', valor: null },
              { nombre: 'p_fecha_hasta', valor: null }
            ],
            Tenant: 'public'
          }
        })

        if (response.data?.success && response.data?.data) {
          this.globalAuditoria = response.data.data
          this.showAuditModal = true
        }
      } catch (error) {
        console.error('Error cargando auditoría global:', error)
        this.$toast?.error('Error al cargar la auditoría global')
      }
    },

    closeModal() {
      this.showModal = false
      this.currentItem = {
        usuario: '',
        num_tag: '',
        descripcion: '',
        fecha_inicio: '',
        fecha_fin: '',
        observaciones: ''
      }
    },

    resetFilters() {
      this.filters = {
        usuario: '',
        departamento: '',
        estado: ''
      }
      this.pagination.page = 1
      this.loadPrivilegios()
    },

    sortBy(field) {
      if (this.sortField === field) {
        this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortField = field
        this.sortDir = 'asc'
      }
      this.loadPrivilegios()
    },

    changePage(page) {
      this.pagination.page = page
      this.loadPrivilegios()
    },

    getPageNumbers() {
      const total = Math.ceil(this.pagination.total / this.pagination.limit)
      const current = this.pagination.page
      const pages = []

      for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages.push(i)
      }

      return pages
    },

    getAuditActionClass(action) {
      const classes = {
        'INSERT': 'badge bg-success',
        'UPDATE': 'badge bg-warning',
        'DELETE': 'badge bg-danger',
        'GRANT': 'badge bg-info',
        'REVOKE': 'badge bg-secondary'
      }
      return classes[action] || 'badge bg-light'
    },

    formatDateTime(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleString('es-MX', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  },

  watch: {
    showAuditModal(newVal) {
      if (newVal) {
        this.loadGlobalAuditoria()
      }
    }
  }
}
</script>

<style scoped>
.container-fluid {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.breadcrumb {
  background: none;
  padding: 0.75rem 1rem;
}

.breadcrumb-item a {
  text-decoration: none;
  color: #6c757d;
}

.breadcrumb-item.active {
  color: #495057;
  font-weight: 500;
}

.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border-radius: 0.5rem;
}

.card-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  font-weight: 600;
}

.table th {
  border-top: none;
  font-weight: 600;
  color: #495057;
  background-color: #f8f9fa;
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 123, 255, 0.075);
}

.table-active {
  background-color: rgba(13, 110, 253, 0.075) !important;
}

.sortable {
  cursor: pointer;
  user-select: none;
}

.sortable:hover {
  background-color: rgba(0, 123, 255, 0.1);
}

.btn {
  border-radius: 0.375rem;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75em;
}

.modal-content {
  border: none;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.form-label {
  font-weight: 500;
  color: #495057;
}

.text-danger {
  color: #dc3545 !important;
}

.sticky-top {
  position: sticky;
  top: 0;
  z-index: 1020;
}

@media (max-width: 768px) {
  .container-fluid {
    padding-left: 15px;
    padding-right: 15px;
  }

  .table-responsive {
    border: none;
  }

  .btn-sm {
    padding: 0.125rem 0.25rem;
    font-size: 0.75rem;
  }

  .badge {
    font-size: 0.65em;
  }
}

/* Animaciones */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter, .fade-leave-to {
  opacity: 0;
}

/* Estilos para iconos */
.fas {
  transition: transform 0.2s;
}

.btn:hover .fas {
  transform: scale(1.1);
}

/* Estilos para tablas responsive */
@media (max-width: 576px) {
  .table-responsive table {
    font-size: 0.875rem;
  }

  .table-responsive td,
  .table-responsive th {
    padding: 0.5rem 0.25rem;
  }
}
</style>
