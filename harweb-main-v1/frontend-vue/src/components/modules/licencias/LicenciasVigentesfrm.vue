<template>
  <div class="container-fluid px-4 py-3">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-certificate"></i> Licencias</li>
        <li class="breadcrumb-item active" aria-current="page">Licencias Vigentes</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h3 mb-1"><i class="fas fa-certificate text-success me-2"></i>Licencias Vigentes</h2>
            <p class="text-muted mb-0">Consulta y gestión de licencias activas</p>
          </div>
          <div>
            <button class="btn btn-success me-2" @click="exportarDatos" title="Exportar a Excel">
              <i class="fas fa-file-excel me-1"></i>Exportar
            </button>
            <button class="btn btn-info" @click="generarReporte" title="Generar Reporte">
              <i class="fas fa-file-pdf me-1"></i>Reporte
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label">Buscar licencia:</label>
            <input v-model="filtros.busqueda" @input="cargarDatos" type="text" class="form-control" placeholder="Número de licencia o propietario...">
          </div>
          <div class="col-md-2">
            <label class="form-label">Giro:</label>
            <select v-model="filtros.giro" @change="cargarDatos" class="form-select">
              <option value="">Todos</option>
              <option v-for="giro in giros" :key="giro.id" :value="giro.id">{{ giro.nombre }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Año de vigencia:</label>
            <select v-model="filtros.anio" @change="cargarDatos" class="form-select">
              <option value="">Todos</option>
              <option v-for="year in aniosDisponibles" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Zona:</label>
            <select v-model="filtros.zona" @change="cargarDatos" class="form-select">
              <option value="">Todas</option>
              <option v-for="zona in zonas" :key="zona.id" :value="zona.id">{{ zona.nombre }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Registros por página:</label>
            <select v-model="itemsPerPage" @change="cargarDatos" class="form-select">
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>
          <div class="col-md-1 d-flex align-items-end">
            <button @click="limpiarFiltros" class="btn btn-outline-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de licencias vigentes -->
    <div class="card">
      <div class="card-header bg-light">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Listado de Licencias Vigentes</h5>
          <div class="d-flex align-items-center">
            <span class="badge bg-success me-2">Total: {{ totalRegistros }}</span>
            <span class="badge bg-info">Vigentes: {{ licenciasVigentes.length }}</span>
          </div>
        </div>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando licencias vigentes...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>Actividad/Giro</th>
                  <th>Ubicación</th>
                  <th>Zona</th>
                  <th>Vigencia</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="licencia in licenciasVigentes" :key="licencia.id">
                  <td>
                    <div class="d-flex align-items-center">
                      <i class="fas fa-certificate text-success me-2"></i>
                      <span class="font-monospace fw-bold">{{ licencia.numero_licencia }}</span>
                    </div>
                  </td>
                  <td>{{ licencia.propietario }}</td>
                  <td>
                    <div>
                      <div class="fw-bold">{{ licencia.actividad }}</div>
                      <small class="text-muted">{{ licencia.giro }}</small>
                    </div>
                  </td>
                  <td>
                    <div>
                      <div>{{ licencia.direccion }}</div>
                      <small class="text-muted">{{ licencia.colonia }}</small>
                    </div>
                  </td>
                  <td>
                    <span class="badge bg-primary">Zona {{ licencia.zona }}</span>
                  </td>
                  <td>
                    <div>
                      <div class="fw-bold text-success">{{ formatDate(licencia.fecha_vigencia_inicio) }}</div>
                      <small class="text-muted">hasta {{ formatDate(licencia.fecha_vigencia_fin) }}</small>
                    </div>
                  </td>
                  <td>
                    <span :class="getEstadoClass(licencia.estado)">{{ licencia.estado }}</span>
                  </td>
                  <td>
                    <button @click="verDetalle(licencia)" class="btn btn-sm btn-outline-info me-1" title="Ver detalle">
                      <i class="fas fa-eye"></i>
                    </button>
                    <button @click="imprimirLicencia(licencia)" class="btn btn-sm btn-outline-primary me-1" title="Imprimir">
                      <i class="fas fa-print"></i>
                    </button>
                    <button @click="renovarLicencia(licencia)" class="btn btn-sm btn-outline-warning" title="Renovar">
                      <i class="fas fa-sync-alt"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="totalRegistros > itemsPerPage" class="d-flex justify-content-between align-items-center p-3 bg-light">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, totalRegistros) }} de {{ totalRegistros }} registros
            </span>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: currentPage <= 1 }">
                  <button class="page-link" @click="cambiarPagina(currentPage - 1)">Anterior</button>
                </li>
                <li v-for="page in getPageNumbers()" :key="page" class="page-item" :class="{ active: page === currentPage }">
                  <button class="page-link" @click="cambiarPagina(page)">{{ page }}</button>
                </li>
                <li class="page-item" :class="{ disabled: currentPage >= Math.ceil(totalRegistros / itemsPerPage) }">
                  <button class="page-link" @click="cambiarPagina(currentPage + 1)">Siguiente</button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de detalle -->
    <div class="modal fade" :class="{ show: showDetalleModal }" :style="{ display: showDetalleModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle de Licencia {{ licenciaSeleccionada?.numero_licencia }}</h5>
            <button type="button" class="btn-close" @click="showDetalleModal = false"></button>
          </div>
          <div class="modal-body">
            <div v-if="licenciaSeleccionada" class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Número de Licencia:</label>
                <div class="fw-bold">{{ licenciaSeleccionada.numero_licencia }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Estado:</label>
                <div><span :class="getEstadoClass(licenciaSeleccionada.estado)">{{ licenciaSeleccionada.estado }}</span></div>
              </div>
              <div class="col-12">
                <label class="form-label">Propietario:</label>
                <div class="fw-bold">{{ licenciaSeleccionada.propietario }}</div>
              </div>
              <div class="col-12">
                <label class="form-label">Actividad:</label>
                <div>{{ licenciaSeleccionada.actividad }}</div>
              </div>
              <div class="col-12">
                <label class="form-label">Ubicación:</label>
                <div>{{ licenciaSeleccionada.direccion }}, {{ licenciaSeleccionada.colonia }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Zona:</label>
                <div>{{ licenciaSeleccionada.zona }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Giro:</label>
                <div>{{ licenciaSeleccionada.giro }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Vigencia desde:</label>
                <div class="text-success fw-bold">{{ formatDate(licenciaSeleccionada.fecha_vigencia_inicio) }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Vigencia hasta:</label>
                <div class="text-danger fw-bold">{{ formatDate(licenciaSeleccionada.fecha_vigencia_fin) }}</div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showDetalleModal = false">Cerrar</button>
            <button type="button" class="btn btn-primary" @click="imprimirLicencia(licenciaSeleccionada)">
              <i class="fas fa-print me-1"></i>Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showDetalleModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import Swal from 'sweetalert2'

export default {
  name: 'LicenciasVigentesPage',
  data() {
    return {
      licenciasVigentes: [],
      giros: [],
      zonas: [],
      loading: false,
      showDetalleModal: false,
      licenciaSeleccionada: null,
      filtros: {
        busqueda: '',
        giro: '',
        anio: '',
        zona: ''
      },
      currentPage: 1,
      itemsPerPage: 25,
      totalRegistros: 0,
      aniosDisponibles: []
    }
  },
  mounted() {
    this.inicializarDatos()
  },
  methods: {
    async inicializarDatos() {
      this.generarAniosDisponibles()
      await Promise.all([
        this.cargarGiros(),
        this.cargarZonas(),
        this.cargarDatos()
      ])
    },

    async cargarDatos() {
      this.loading = true
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_licencias_vigentes',
            Base: 'padron_licencias',
            Parametros: [
              {
                nombre: 'filtro',
                valor: JSON.stringify({
                  busqueda: this.filtros.busqueda || null,
                  giro: this.filtros.giro || null,
                  anio: this.filtros.anio || null,
                  zona: this.filtros.zona || null,
                  limite: this.itemsPerPage,
                  offset: (this.currentPage - 1) * this.itemsPerPage,
                  vigencia: 'todas'
                })
              }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.licenciasVigentes = response.data.eResponse.data.result
          this.totalRegistros = response.data.eResponse.data.result[0]?.total_registros || 0
        }
      } catch (error) {
        console.error('Error cargando licencias vigentes:', error)
        this.$toast.error('Error al cargar las licencias vigentes')
      } finally {
        this.loading = false
      }
    },

    async cargarGiros() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_giros_list',
            Base: 'padron_licencias',
            Parametros: [],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.giros = response.data.eResponse.data.result
        }
      } catch (error) {
        console.error('Error cargando giros:', error)
      }
    },

    async cargarZonas() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_zonas_list',
            Base: 'padron_licencias',
            Parametros: [],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.zonas = response.data.eResponse.data.result
        }
      } catch (error) {
        console.error('Error cargando zonas:', error)
      }
    },

    generarAniosDisponibles() {
      const currentYear = new Date().getFullYear()
      this.aniosDisponibles = []
      for (let year = currentYear - 5; year <= currentYear + 2; year++) {
        this.aniosDisponibles.push(year)
      }
    },

    limpiarFiltros() {
      this.filtros = {
        busqueda: '',
        giro: '',
        anio: '',
        zona: ''
      }
      this.currentPage = 1
      this.cargarDatos()
    },

    cambiarPagina(page) {
      if (page >= 1 && page <= Math.ceil(this.totalRegistros / this.itemsPerPage)) {
        this.currentPage = page
        this.cargarDatos()
      }
    },

    getPageNumbers() {
      const total = Math.ceil(this.totalRegistros / this.itemsPerPage)
      const current = this.currentPage
      const pages = []

      for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages.push(i)
      }

      return pages
    },

    verDetalle(licencia) {
      this.licenciaSeleccionada = licencia
      this.showDetalleModal = true
    },

    async imprimirLicencia(licencia) {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_generar_licencia_pdf',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_numero_licencia', valor: licencia.numero_licencia },
              { nombre: 'p_formato', valor: 'pdf' }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success) {
          // Simular descarga de PDF
          Swal.fire({
            icon: 'success',
            title: 'PDF Generado',
            text: `Se ha generado el PDF para la licencia ${licencia.numero_licencia}`,
            timer: 3000,
            showConfirmButton: false
          })
        }
      } catch (error) {
        console.error('Error generando PDF:', error)
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al generar el PDF de la licencia',
          timer: 3000,
          showConfirmButton: false
        })
      }
    },

    async renovarLicencia(licencia) {
      const result = await Swal.fire({
        title: '¿Renovar Licencia?',
        text: `¿Desea renovar la licencia ${licencia.numero_licencia}?`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, renovar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_renovar_licencia',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_numero_licencia', valor: licencia.numero_licencia },
                { nombre: 'p_anio_renovacion', valor: new Date().getFullYear() + 1 },
                { nombre: 'p_observaciones', valor: 'Renovación automática desde sistema web' }
              ],
              Tenant: 'public'
            }
          })

          if (response.data && response.data.eResponse.success) {
            Swal.fire({
              icon: 'success',
              title: 'Licencia Renovada',
              text: `La licencia ${licencia.numero_licencia} ha sido renovada exitosamente`,
              timer: 3000,
              showConfirmButton: false
            })
            this.cargarDatos()
          }
        } catch (error) {
          console.error('Error renovando licencia:', error)
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al renovar la licencia',
            timer: 3000,
            showConfirmButton: false
          })
        }
      }
    },

    async exportarDatos() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_exportar_licencias_vigentes',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_formato', valor: 'excel' },
              { nombre: 'p_filtros', valor: JSON.stringify(this.filtros) }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success) {
          Swal.fire({
            icon: 'success',
            title: 'Archivo Generado',
            text: 'El archivo Excel se ha generado correctamente',
            timer: 3000,
            showConfirmButton: false
          })
        }
      } catch (error) {
        console.error('Error exportando datos:', error)
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al generar el archivo Excel',
          timer: 3000,
          showConfirmButton: false
        })
      }
    },

    async generarReporte() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_reporte_licencias_vigentes',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_formato', valor: 'pdf' },
              { nombre: 'p_filtros', valor: JSON.stringify(this.filtros) }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success) {
          Swal.fire({
            icon: 'success',
            title: 'Reporte Generado',
            text: 'El reporte PDF se ha generado correctamente',
            timer: 3000,
            showConfirmButton: false
          })
        }
      } catch (error) {
        console.error('Error generando reporte:', error)
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al generar el reporte PDF',
          timer: 3000,
          showConfirmButton: false
        })
      }
    },

    getEstadoClass(estado) {
      const classes = {
        'vigente': 'badge bg-success',
        'por_vencer': 'badge bg-warning',
        'vencida': 'badge bg-danger',
        'suspendida': 'badge bg-secondary'
      }
      return classes[estado] || 'badge bg-light'
    },

    formatDate(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleDateString('es-MX')
    }
  },

  watch: {
    itemsPerPage() {
      this.currentPage = 1
      this.cargarDatos()
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

.font-monospace {
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
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
</style>