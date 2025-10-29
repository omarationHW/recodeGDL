<template>
  <div class="municipal-form-page">
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
            <h2 class="municipal-header"><i class="fas fa-check-circle me-2"></i>Licencias Vigentes</h2>
            <p class="text-muted mb-0">Consulta y gestión de licencias activas</p>
          </div>
          <div>
            <button class="btn-municipal-success me-2" @click="exportarDatos" title="Exportar a Excel">
              <i class="fas fa-file-excel me-1"></i>Exportar
            </button>
            <button class="btn-municipal-info" @click="generarReporte" title="Generar Reporte">
              <i class="fas fa-file-pdf me-1"></i>Reporte
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Buscar licencia:</label>
            <input v-model="filtros.busqueda" @input="cargarDatos" type="text" class="municipal-form-control" placeholder="Número de licencia o propietario...">
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Giro:</label>
            <select v-model="filtros.giro" @change="cargarDatos" class="municipal-form-control">
              <option value="">Todos</option>
              <option v-for="giro in giros" :key="giro.id" :value="giro.id">{{ giro.nombre }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Año de vigencia:</label>
            <select v-model="filtros.anio" @change="cargarDatos" class="municipal-form-control">
              <option value="">Todos</option>
              <option v-for="year in aniosDisponibles" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Zona:</label>
            <select v-model="filtros.zona" @change="cargarDatos" class="municipal-form-control">
              <option value="">Todas</option>
              <option v-for="zona in zonas" :key="zona.id" :value="zona.id">{{ zona.nombre }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Registros por página:</label>
            <select v-model="itemsPerPage" @change="cargarDatos" class="municipal-form-control">
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>
          <div class="col-md-1 d-flex align-items-end">
            <button @click="limpiarFiltros" class="btn-municipal-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de licencias vigentes -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Listado de Licencias Vigentes</h5>
          <div class="d-flex align-items-center">
            <span class="municipal-badge-success me-2">Total: {{ totalRegistros }}</span>
            <span class="municipal-badge-info">Vigentes: {{ licenciasVigentes.length }}</span>
          </div>
        </div>
      </div>
      <div class="municipal-card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando licencias vigentes...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="municipal-table municipal-table-hover mb-0">
              <thead class="municipal-table-header">
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
                    <span class="municipal-badge-primary">Zona {{ licencia.zona }}</span>
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
                    <button @click="verDetalle(licencia)" class="btn-municipal-info btn-sm me-1" title="Ver detalle">
                      <i class="fas fa-eye"></i>
                    </button>
                    <button @click="imprimirLicencia(licencia)" class="btn-municipal-primary btn-sm me-1" title="Imprimir">
                      <i class="fas fa-print"></i>
                    </button>
                    <button @click="renovarLicencia(licencia)" class="btn-municipal-warning btn-sm" title="Renovar">
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
                  <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(currentPage - 1)">Anterior</button>
                </li>
                <li v-for="page in getPageNumbers()" :key="page" class="page-item" :class="{ active: page === currentPage }">
                  <button class="btn-municipal-primary btn-sm" @click="cambiarPagina(page)">{{ page }}</button>
                </li>
                <li class="page-item" :class="{ disabled: currentPage >= Math.ceil(totalRegistros / itemsPerPage) }">
                  <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(currentPage + 1)">Siguiente</button>
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
                <label class="municipal-form-label">Número de Licencia:</label>
                <div class="fw-bold">{{ licenciaSeleccionada.numero_licencia }}</div>
              </div>
              <div class="col-md-6">
                <label class="municipal-form-label">Estado:</label>
                <div><span :class="getEstadoClass(licenciaSeleccionada.estado)">{{ licenciaSeleccionada.estado }}</span></div>
              </div>
              <div class="col-12">
                <label class="municipal-form-label">Propietario:</label>
                <div class="fw-bold">{{ licenciaSeleccionada.propietario }}</div>
              </div>
              <div class="col-12">
                <label class="municipal-form-label">Actividad:</label>
                <div>{{ licenciaSeleccionada.actividad }}</div>
              </div>
              <div class="col-12">
                <label class="municipal-form-label">Ubicación:</label>
                <div>{{ licenciaSeleccionada.direccion }}, {{ licenciaSeleccionada.colonia }}</div>
              </div>
              <div class="col-md-6">
                <label class="municipal-form-label">Zona:</label>
                <div>{{ licenciaSeleccionada.zona }}</div>
              </div>
              <div class="col-md-6">
                <label class="municipal-form-label">Giro:</label>
                <div>{{ licenciaSeleccionada.giro }}</div>
              </div>
              <div class="col-md-6">
                <label class="municipal-form-label">Vigencia desde:</label>
                <div class="text-success fw-bold">{{ formatDate(licenciaSeleccionada.fecha_vigencia_inicio) }}</div>
              </div>
              <div class="col-md-6">
                <label class="municipal-form-label">Vigencia hasta:</label>
                <div class="text-danger fw-bold">{{ formatDate(licenciaSeleccionada.fecha_vigencia_fin) }}</div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showDetalleModal = false">Cerrar</button>
            <button type="button" class="btn-municipal-primary" @click="imprimirLicencia(licenciaSeleccionada)">
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_LICENCIAS_VIGENTES_LIST',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_busqueda', valor: this.filtros.busqueda || null },
                { nombre: 'p_giro', valor: this.filtros.giro || null },
                { nombre: 'p_anio', valor: this.filtros.anio ? parseInt(this.filtros.anio) : null },
                { nombre: 'p_zona', valor: this.filtros.zona || null },
                { nombre: 'p_estado', valor: 'vigente' },
                { nombre: 'p_limite', valor: parseInt(this.itemsPerPage) },
                { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
              ]
            }
          })
        });

        const result = await response.json();
        if (result.eResponse && result.eResponse.resultado === 'success') {
          this.licenciasVigentes = result.eResponse.data || [];
          this.totalRegistros = this.licenciasVigentes[0]?.total_registros || 0;
        } else {
          // Usar datos simulados si falla
          this.licenciasVigentes = this.generarDatosSimulados();
          this.totalRegistros = 50;
        }
      } catch (error) {
        console.error('Error cargando licencias vigentes:', error);
        // Usar datos simulados en desarrollo
        this.licenciasVigentes = this.generarDatosSimulados();
        this.totalRegistros = 50;
      } finally {
        this.loading = false;
      }
    },

    async cargarGiros() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_giros_list',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'public'
            }
          })
        })
        const data = await response.json()

        if (data && data.eResponse.success && data.eResponse.data.result) {
          this.giros = data.eResponse.data.result
        }
      } catch (error) {
        console.error('Error cargando giros:', error)
      }
    },

    async cargarZonas() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_zonas_list',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'public'
            }
          })
        })
        const data = await response.json()

        if (data && data.eResponse.success && data.eResponse.data.result) {
          this.zonas = data.eResponse.data.result
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
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
        })
        const data = await response.json()

        if (data && data.eResponse.success) {
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
          const response = await fetch('http://localhost:8000/api/generic', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
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
          })
          const data = await response.json()

          if (data && data.eResponse.success) {
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
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
        })
        const data = await response.json()

        if (data && data.eResponse.success) {
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
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
        })
        const data = await response.json()

        if (data && data.eResponse.success) {
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
        'vigente': 'municipal-badge-success',
        'por_vencer': 'municipal-badge-warning',
        'vencida': 'municipal-badge-danger',
        'suspendida': 'municipal-badge-secondary'
      }
      return classes[estado] || 'municipal-badge-light'
    },

    formatDate(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleDateString('es-MX')
    },

    generarDatosSimulados() {
      const estados = ['vigente', 'por_vencer', 'vencida'];
      const giros = ['ABARROTES', 'RESTAURANTE', 'FARMACIA', 'ROPA', 'SERVICIOS'];
      const zonas = ['A', 'B', 'C', 'D'];
      const colonias = ['CENTRO', 'AMERICANA', 'MODERNA', 'LIBERTAD', 'PROVIDENCIA'];

      return Array.from({ length: this.itemsPerPage }, (_, i) => ({
        id: i + 1,
        numero_licencia: `LIC-2025-${String(i + 1).padStart(6, '0')}`,
        propietario: `PROPIETARIO ${i + 1}`,
        rfc: i % 3 === 0 ? `RFC${i}80515XXX` : null,
        actividad: `${giros[i % giros.length]} Y SERVICIOS RELACIONADOS CON LA ACTIVIDAD COMERCIAL`,
        giro: giros[i % giros.length],
        direccion: `AV. JUÁREZ ${i + 100}`,
        colonia: colonias[i % colonias.length],
        zona: zonas[i % zonas.length],
        fecha_vigencia_inicio: new Date(2025, 0, 1 + (i * 5)),
        fecha_vigencia_fin: new Date(2025, 11, 31 + (i * 5)),
        estado: i % 10 === 0 ? estados[1] : estados[0], // Algunos "por vencer"
        dias_restantes: 365 - (i * 10),
        numero_empleados: (i % 10) + 1,
        superficie_construida: (i * 15.5 + 45).toFixed(2),
        telefono: i % 2 === 0 ? `33-1234-567${i % 10}` : null,
        email: i % 3 === 0 ? `propietario${i}@email.com` : null,
        fecha_expedicion: new Date(2025, 0, 1 + (i * 3)),
        observaciones: i % 5 === 0 ? 'Licencia renovada automáticamente' : null,
        total_registros: 50
      }));
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

