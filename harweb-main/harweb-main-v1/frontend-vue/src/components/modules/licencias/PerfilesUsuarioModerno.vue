<template>
  <div class="container-fluid p-0 h-100">
    <!-- Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">
            <i class="fas fa-users-cog me-2"></i>Perfiles de Usuario Modernos
          </h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 bg-transparent p-0">
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
              <li class="breadcrumb-item text-white active">Perfiles de Usuario</li>
            </ol>
          </nav>
        </div>
        <div class="text-white-50">
          <small>{{ new Date().toLocaleDateString('es-ES') }}</small>
        </div>
      </div>
    </div>

    <!-- 🆕 NUEVO COMPONENTE - SEPARACIÓN DE PERFILES GRANULAR -->
    <div class="alert alert-success m-3">
      <h4 class="alert-heading">🆕 NUEVO: Separación de Perfiles de Usuario</h4>
      <p class="mb-0">Sistema modernizado para separar perfiles de usuarios de padrón, licencias e ingresos</p>
    </div>

    <!-- Controles -->
    <div class="municipal-controls border-bottom p-3">
      <div class="row g-3 align-items-center">
        <!-- Botones de acción -->
        <div class="col-lg-6">
          <div class="btn-group" role="group" aria-label="Acciones de perfiles">
            <button type="button" class="btn municipal-group-btn" @click="modificarPerfil" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar Perfil
            </button>
            <button type="button" class="btn municipal-group-btn" @click="verHistorial" :disabled="!selectedRow">
              <i class="fas fa-history me-1"></i> Historial
            </button>
            <button type="button" class="btn municipal-group-btn" @click="exportarDatos" :disabled="loading">
              <i class="fas fa-file-export me-1"></i> Exportar
            </button>
            <button type="button" class="btn municipal-group-btn" @click="cargarDatos" :disabled="formActive">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
          </div>
        </div>

        <!-- Filtros por tipo de perfil -->
        <div class="col-lg-3">
          <select v-model="filtroTipoPerfil" @change="aplicarFiltros" class="form-select">
            <option value="TODOS">Todos los perfiles</option>
            <option value="PADRON">Solo Padrón</option>
            <option value="LICENCIAS">Solo Licencias</option>
            <option value="INGRESOS">Solo Ingresos</option>
            <option value="COMPLETO">Perfiles Completos</option>
          </select>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-3">
          <div class="input-group">
            <input
              v-model="searchValue"
              @input="buscar"
              placeholder="Buscar usuario o nombre..."
              class="form-control"
            />
            <span class="input-group-text municipal-primary text-white">
              <strong>Total: {{ totalRegistros }}</strong>
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border municipal-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <div class="mt-2">{{ loadingMessage }}</div>
    </div>

    <!-- Estadísticas -->
    <div v-if="!loading && estadisticas" class="municipal-stats p-3">
      <div class="row g-2">
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.usuarios_activos }}</div>
              <div class="municipal-stat-label">Activos</div>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.con_perfil_padron }}</div>
              <div class="municipal-stat-label">Padrón</div>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.con_perfil_licencias }}</div>
              <div class="municipal-stat-label">Licencias</div>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.con_perfil_ingresos }}</div>
              <div class="municipal-stat-label">Ingresos</div>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.perfiles_completos }}</div>
              <div class="municipal-stat-label">Completos</div>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <div class="card municipal-stat-card text-center">
            <div class="card-body p-2">
              <div class="municipal-stat-number">{{ estadisticas.perfiles_basicos }}</div>
              <div class="municipal-stat-label">Básicos</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla -->
    <div class="flex-grow-1 p-3">
      <div class="card municipal-card">
        <div class="card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="table table-hover table-sm mb-0" style="min-width: 1200px;">
              <thead class="municipal-table-header sticky-top">
                <tr>
                  <th style="width: 100px;">Usuario</th>
                  <th style="width: 200px;">Nombre Completo</th>
                  <th style="width: 150px;">Tipo de Perfil</th>
                  <th style="width: 80px;" class="text-center">Padrón</th>
                  <th style="width: 80px;" class="text-center">Licencias</th>
                  <th style="width: 80px;" class="text-center">Ingresos</th>
                  <th style="width: 180px;">Departamento</th>
                  <th style="width: 200px;">Dependencia</th>
                  <th style="width: 120px;">Fecha Alta</th>
                  <th style="width: 80px;" class="text-center">Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="perfiles.length === 0 && !loading">
                  <td colspan="10" class="text-center py-4 text-muted">
                    <i class="fas fa-users fa-2x mb-2"></i>
                    <div>No hay perfiles para mostrar</div>
                  </td>
                </tr>
                <tr v-for="(perfil, index) in perfiles"
                    :key="perfil.usuario"
                    :class="{ 'municipal-table-selected': isSelected(perfil) }"
                    @click="selectRow(perfil)"
                    style="cursor: pointer;">
                  <td>
                    <strong>{{ perfil.usuario }}</strong>
                  </td>
                  <td>
                    {{ perfil.nombres }} {{ perfil.apellidos }}
                  </td>
                  <td>
                    <span :class="getTipoPerfilClass(perfil.tipo_perfil)">
                      {{ formatTipoPerfil(perfil.tipo_perfil) }}
                    </span>
                  </td>
                  <td class="text-center">
                    <i :class="perfil.perfil_padron === 'S' ? 'fas fa-check text-success' : 'fas fa-times text-muted'"></i>
                  </td>
                  <td class="text-center">
                    <i :class="perfil.perfil_licencias === 'S' ? 'fas fa-check text-success' : 'fas fa-times text-muted'"></i>
                  </td>
                  <td class="text-center">
                    <i :class="perfil.perfil_ingresos === 'S' ? 'fas fa-check text-success' : 'fas fa-times text-muted'"></i>
                  </td>
                  <td>{{ perfil.departamento }}</td>
                  <td class="small">{{ perfil.dependencia }}</td>
                  <td>{{ formatDate(perfil.fecha_alta) }}</td>
                  <td class="text-center">
                    <span :class="perfil.activo === 'S' ? 'badge bg-success' : 'badge bg-secondary'">
                      {{ perfil.activo === 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="row p-3 border-top">
            <div class="col-sm-6">
              <div v-if="totalPages > 1" class="d-flex align-items-center">
                <nav>
                  <ul class="pagination pagination-sm mb-0">
                    <li class="page-item" :class="{ disabled: currentPage === 1 }">
                      <button class="page-link" @click="cambiarPagina(currentPage - 1)" :disabled="currentPage === 1">
                        <i class="fas fa-chevron-left"></i>
                      </button>
                    </li>
                    <li v-for="page in getVisiblePages()" :key="page" class="page-item" :class="{ active: currentPage === page }">
                      <button class="page-link" @click="cambiarPagina(page)">{{ page }}</button>
                    </li>
                    <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                      <button class="page-link" @click="cambiarPagina(currentPage + 1)" :disabled="currentPage === totalPages">
                        <i class="fas fa-chevron-right"></i>
                      </button>
                    </li>
                  </ul>
                </nav>
              </div>
              <div v-else class="text-start">
                <small class="text-muted">Página 1 de 1</small>
              </div>
            </div>
            <div class="col-sm-6">
              <div class="d-flex align-items-center justify-content-end gap-2">
                <span class="text-muted small">Mostrar:</span>
                <select v-model="itemsPerPage" @change="onItemsPerPageChange" class="form-select form-select-sm" style="width: auto;">
                  <option value="10">10</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
                <span class="text-muted small">registros</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para editar perfil -->
    <div v-if="showModal" class="modal-overlay municipal-modal-overlay" @click="cerrarModal">
      <div class="modal-content municipal-modal-content" @click.stop style="max-width: 800px;">
        <div class="modal-header municipal-modal-header">
          <h5>
            <i class="fas fa-user-edit me-2"></i>
            Modificar Perfil: {{ perfilSeleccionado?.usuario }}
          </h5>
          <button type="button" class="close-btn" @click="cerrarModal">&times;</button>
        </div>

        <div class="modal-body p-4">
          <div v-if="perfilDetalle" class="row g-3">
            <!-- Información básica -->
            <div class="col-12">
              <div class="card border-primary">
                <div class="card-header bg-primary text-white">
                  <h6 class="mb-0"><i class="fas fa-user me-2"></i>Información Básica</h6>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <strong>Usuario:</strong> {{ perfilDetalle.usuario }}<br>
                      <strong>Nombre:</strong> {{ perfilDetalle.nombres }} {{ perfilDetalle.apellidos }}
                    </div>
                    <div class="col-md-6">
                      <strong>Departamento:</strong> {{ perfilDetalle.departamento }}<br>
                      <strong>Dependencia:</strong> {{ perfilDetalle.dependencia }}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Configuración de perfiles -->
            <div class="col-12">
              <div class="card border-success">
                <div class="card-header bg-success text-white">
                  <h6 class="mb-0"><i class="fas fa-cogs me-2"></i>Configuración de Perfiles</h6>
                </div>
                <div class="card-body">
                  <div class="row g-3">
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          v-model="formData.perfil_padron"
                          class="form-check-input"
                          type="checkbox"
                          true-value="S"
                          false-value="N"
                          id="perfilPadron"
                        >
                        <label class="form-check-label" for="perfilPadron">
                          <i class="fas fa-database me-2 text-info"></i>
                          <strong>Perfil Padrón</strong>
                          <small class="d-block text-muted">Acceso a datos de contribuyentes</small>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          v-model="formData.perfil_licencias"
                          class="form-check-input"
                          type="checkbox"
                          true-value="S"
                          false-value="N"
                          id="perfilLicencias"
                        >
                        <label class="form-check-label" for="perfilLicencias">
                          <i class="fas fa-store me-2 text-warning"></i>
                          <strong>Perfil Licencias</strong>
                          <small class="d-block text-muted">Gestión de licencias comerciales</small>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          v-model="formData.perfil_ingresos"
                          class="form-check-input"
                          type="checkbox"
                          true-value="S"
                          false-value="N"
                          id="perfilIngresos"
                        >
                        <label class="form-check-label" for="perfilIngresos">
                          <i class="fas fa-coins me-2 text-success"></i>
                          <strong>Perfil Ingresos</strong>
                          <small class="d-block text-muted">Manejo de ingresos y tarifas</small>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Observaciones -->
            <div class="col-12">
              <div class="card border-secondary">
                <div class="card-header bg-secondary text-white">
                  <h6 class="mb-0"><i class="fas fa-sticky-note me-2"></i>Observaciones</h6>
                </div>
                <div class="card-body">
                  <textarea
                    v-model="formData.observaciones"
                    class="form-control"
                    rows="3"
                    placeholder="Notas adicionales sobre el perfil del usuario..."
                  ></textarea>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer municipal-modal-footer">
          <button type="button" class="btn btn-secondary" @click="cerrarModal">
            <i class="fas fa-times me-1"></i> Cancelar
          </button>
          <button type="button" class="btn btn-primary" @click="guardarPerfil" :disabled="guardando">
            <i class="fas fa-save me-1"></i>
            {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Toast para notificaciones -->
    <div v-if="showToast" :class="['toast-notification', 'municipal-toast', toastType]">
      <i :class="getToastIcon()"></i>
      {{ toastMessage }}
    </div>
  </div>
</template>

<script>

export default {
  name: 'PerfilesUsuarioModerno',
  data() {
    return {
      // Estado de carga
      loading: false,
      loadingMessage: 'Cargando perfiles...',
      guardando: false,

      // Datos principales
      perfiles: [],
      estadisticas: null,
      perfilDetalle: null,
      selectedRow: null,

      // Búsqueda y filtros
      searchValue: '',
      filtroTipoPerfil: 'TODOS',

      // Paginación
      currentPage: 1,
      itemsPerPage: 25,
      totalRegistros: 0,

      // Modales y formularios
      showModal: false,
      formActive: false,
      formData: {
        perfil_padron: 'N',
        perfil_licencias: 'N',
        perfil_ingresos: 'N',
        observaciones: ''
      },

      // Notificaciones
      showToast: false,
      toastMessage: '',
      toastType: 'success'
    }
  },

  computed: {
    totalPages() {
      return Math.ceil(this.totalRegistros / this.itemsPerPage)
    },

    perfilSeleccionado() {
      return this.selectedRow
    }
  },

  async mounted() {
    await Promise.all([
      this.cargarDatos(),
      this.cargarEstadisticas()
    ])
  },

  methods: {
    async cargarDatos() {
      this.loading = true
      this.loadingMessage = 'Cargando perfiles de usuarios...'

      try {
        const eRequest = {
          Operacion: 'sp_perfiles_usuario_list',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage },
            { nombre: 'p_filtro', valor: this.searchValue },
            { nombre: 'p_tipo_perfil', valor: this.filtroTipoPerfil }
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success) {
          this.perfiles = data.eResponse.data.result || []
          if (this.perfiles.length > 0) {
            this.totalRegistros = this.perfiles[0].total_count || 0
          }
          this.showToast = false
        } else {
          this.perfiles = []
          this.totalRegistros = 0
          this.mostrarToast('error', 'Error al cargar perfiles: ' + data.eResponse.message)
        }
      } catch (error) {
        console.error('Error loading perfiles:', error)
        this.mostrarToast('error', 'Error de conexión al cargar perfiles')
        this.perfiles = []
        this.totalRegistros = 0
      } finally {
        this.loading = false
      }
    },

    async cargarEstadisticas() {
      try {
        const eRequest = {
          Operacion: 'sp_perfiles_usuario_estadisticas',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: []
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success) {
          const result = data.eResponse.data.result || []
          this.estadisticas = result[0] || {}
        }
      } catch (error) {
        console.error('Error loading estadisticas:', error)
      }
    },

    async cargarPerfilDetalle(usuario) {
      try {
        const eRequest = {
          Operacion: 'sp_perfiles_usuario_detalle',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_usuario', valor: usuario }
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success) {
          const result = data.eResponse.data.result || []
          this.perfilDetalle = result[0] || {}

          // Cargar datos en el formulario
          this.formData = {
            perfil_padron: this.perfilDetalle.perfil_padron || 'N',
            perfil_licencias: this.perfilDetalle.perfil_licencias || 'N',
            perfil_ingresos: this.perfilDetalle.perfil_ingresos || 'N',
            observaciones: this.perfilDetalle.observaciones || ''
          }
        }
      } catch (error) {
        console.error('Error loading perfil detalle:', error)
        this.mostrarToast('error', 'Error al cargar detalle del perfil')
      }
    },

    async guardarPerfil() {
      if (!this.perfilSeleccionado) return

      this.guardando = true

      try {
        const eRequest = {
          Operacion: 'sp_perfiles_usuario_update',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_usuario', valor: this.perfilSeleccionado.usuario },
            { nombre: 'p_perfil_padron', valor: this.formData.perfil_padron },
            { nombre: 'p_perfil_licencias', valor: this.formData.perfil_licencias },
            { nombre: 'p_perfil_ingresos', valor: this.formData.perfil_ingresos },
            { nombre: 'p_observaciones', valor: this.formData.observaciones },
            { nombre: 'p_usuario_modificacion', valor: 'SISTEMA' } // TODO: Usuario actual
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success) {
          this.mostrarToast('success', 'Perfil actualizado correctamente')
          this.cerrarModal()
          await Promise.all([
            this.cargarDatos(),
            this.cargarEstadisticas()
          ])
        } else {
          this.mostrarToast('error', 'Error al actualizar perfil: ' + data.eResponse.message)
        }
      } catch (error) {
        console.error('Error saving perfil:', error)
        this.mostrarToast('error', 'Error de conexión al guardar perfil')
      } finally {
        this.guardando = false
      }
    },

    // Métodos de interfaz
    selectRow(perfil) {
      this.selectedRow = this.selectedRow?.usuario === perfil.usuario ? null : perfil
    },

    isSelected(perfil) {
      return this.selectedRow?.usuario === perfil.usuario
    },

    async modificarPerfil() {
      if (!this.selectedRow) return

      await this.cargarPerfilDetalle(this.selectedRow.usuario)
      this.showModal = true
      this.formActive = true
    },

    cerrarModal() {
      this.showModal = false
      this.formActive = false
      this.perfilDetalle = null
      this.formData = {
        perfil_padron: 'N',
        perfil_licencias: 'N',
        perfil_ingresos: 'N',
        observaciones: ''
      }
    },

    // Búsqueda y filtros
    buscar() {
      this.currentPage = 1
      this.cargarDatos()
    },

    aplicarFiltros() {
      this.currentPage = 1
      this.cargarDatos()
    },

    // Paginación
    cambiarPagina(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        this.cargarDatos()
      }
    },

    onItemsPerPageChange() {
      this.currentPage = 1
      this.cargarDatos()
    },

    getVisiblePages() {
      const delta = 2
      const range = []
      const rangeWithDots = []

      for (let i = Math.max(2, this.currentPage - delta);
           i <= Math.min(this.totalPages - 1, this.currentPage + delta);
           i++) {
        range.push(i)
      }

      if (this.currentPage - delta > 2) {
        rangeWithDots.push(1, '...')
      } else {
        rangeWithDots.push(1)
      }

      rangeWithDots.push(...range)

      if (this.currentPage + delta < this.totalPages - 1) {
        rangeWithDots.push('...', this.totalPages)
      } else {
        rangeWithDots.push(this.totalPages)
      }

      return rangeWithDots.filter((item, index, arr) => arr.indexOf(item) === index)
    },

    // Utilidades de formato
    formatDate(dateString) {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('es-ES')
    },

    formatTipoPerfil(tipo) {
      const tipos = {
        'COMPLETO': 'Completo',
        'PADRON_LICENCIAS': 'Padrón + Licencias',
        'LICENCIAS_INGRESOS': 'Licencias + Ingresos',
        'PADRON': 'Padrón',
        'LICENCIAS': 'Licencias',
        'INGRESOS': 'Ingresos',
        'BASICO': 'Básico'
      }
      return tipos[tipo] || tipo
    },

    getTipoPerfilClass(tipo) {
      const clases = {
        'COMPLETO': 'badge bg-success',
        'PADRON_LICENCIAS': 'badge bg-info',
        'LICENCIAS_INGRESOS': 'badge bg-warning text-dark',
        'PADRON': 'badge bg-primary',
        'LICENCIAS': 'badge bg-secondary',
        'INGRESOS': 'badge bg-success',
        'BASICO': 'badge bg-light text-dark'
      }
      return clases[tipo] || 'badge bg-secondary'
    },

    // Notificaciones
    mostrarToast(tipo, mensaje) {
      this.toastType = tipo
      this.toastMessage = mensaje
      this.showToast = true
      setTimeout(() => {
        this.showToast = false
      }, 5000)
    },

    getToastIcon() {
      const iconos = {
        'success': 'fas fa-check-circle',
        'error': 'fas fa-exclamation-triangle',
        'warning': 'fas fa-exclamation-circle',
        'info': 'fas fa-info-circle'
      }
      return iconos[this.toastType] || 'fas fa-info-circle'
    },

    // Métodos adicionales
    verHistorial() {
      if (!this.selectedRow) return
      // TODO: Implementar modal de historial
      this.mostrarToast('info', 'Función de historial en desarrollo')
    },

    exportarDatos() {
      // TODO: Implementar exportación
      this.mostrarToast('info', 'Función de exportación en desarrollo')
    }
  }
}
</script>

