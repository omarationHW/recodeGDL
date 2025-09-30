<template>
  <div class="catalogo-giros-importes">
    <!-- Header Municipal -->
    <div class="municipal-header mb-4">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h2 class="municipal-title">
            <i class="fas fa-money-check-alt me-2 text-warning"></i>
            Catálogo de Giros - Gestión de Importes
          </h2>
          <p class="municipal-subtitle">Sistema de costos para usuarios perfil ingresos</p>
        </div>
        <div class="municipal-badge">
          <span class="badge bg-warning text-dark">PRIORIDAD 2</span>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
    </div>

    <!-- Controls Panel -->
    <div class="municipal-controls mb-4" v-if="!loading">
      <div class="card">
        <div class="card-header municipal-card-header">
          <h5 class="mb-0">
            <i class="fas fa-filter me-2"></i>
            Filtros y Controles
          </h5>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-3">
              <label class="form-label">Búsqueda:</label>
              <input
                type="text"
                class="form-control"
                v-model="filtros.busqueda"
                @input="cargarDatos"
                placeholder="Buscar giro..."
              >
            </div>
            <div class="col-md-3">
              <label class="form-label">Categoría:</label>
              <select class="form-select" v-model="filtros.categoria" @change="cargarDatos">
                <option value="TODOS">Todas las categorías</option>
                <option value="ALIMENTACION">Alimentación</option>
                <option value="COMERCIO">Comercio</option>
                <option value="SERVICIOS">Servicios</option>
                <option value="ENTRETENIMIENTO">Entretenimiento</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Estado Importe:</label>
              <select class="form-select" v-model="filtros.estado_importe" @change="cargarDatos">
                <option value="TODOS">Todos</option>
                <option value="ASIGNADO">Con importe asignado</option>
                <option value="PENDIENTE">Pendiente de asignar</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Vigencia:</label>
              <select class="form-select" v-model="filtros.vigencia" @change="cargarDatos">
                <option value="TODOS">Todas</option>
                <option value="VIGENTE">Vigente</option>
                <option value="PROXIMO_VENCER">Próximo a vencer</option>
              </select>
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-12">
              <button class="btn btn-success me-2" @click="abrirModalAsignacionMasiva">
                <i class="fas fa-dollar-sign me-2"></i>Asignación Masiva
              </button>
              <button class="btn btn-outline-primary me-2" @click="exportarDatos">
                <i class="fas fa-download me-2"></i>Exportar
              </button>
              <button class="btn btn-outline-secondary" @click="limpiarFiltros">
                <i class="fas fa-times me-2"></i>Limpiar Filtros
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estadísticas Dashboard -->
    <div class="municipal-stats mb-4" v-if="!loading">
      <div class="row">
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-success h-100">
            <div class="card-body text-center">
              <i class="fas fa-check-circle text-success mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-success">{{ estadisticas.giros_con_importe || 0 }}</h3>
              <p class="mb-0">Giros con Importe</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-warning h-100">
            <div class="card-body text-center">
              <i class="fas fa-exclamation-triangle text-warning mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-warning">{{ estadisticas.giros_pendientes || 0 }}</h3>
              <p class="mb-0">Pendientes</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-info h-100">
            <div class="card-body text-center">
              <i class="fas fa-chart-line text-info mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-info">${{ formatearMoneda(estadisticas.ingresos_estimados_mensual) }}</h3>
              <p class="mb-0">Ingresos Estimados</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-primary h-100">
            <div class="card-body text-center">
              <i class="fas fa-clock text-primary mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-primary">{{ estadisticas.giros_proximos_vencer || 0 }}</h3>
              <p class="mb-0">Próximos a Vencer</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla Principal -->
    <div class="municipal-table" v-if="!loading">
      <div class="card">
        <div class="card-header municipal-table-header">
          <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Catálogo de Giros ({{ totalRegistros }} registros)</h5>
            <div class="municipal-pagination-info">
              <select class="form-select form-select-sm" v-model="itemsPerPage" @change="cambiarItemsPorPagina" style="width: auto;">
                <option value="10">10 por página</option>
                <option value="25">25 por página</option>
                <option value="50">50 por página</option>
                <option value="100">100 por página</option>
              </select>
            </div>
          </div>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover municipal-data-table">
              <thead class="municipal-table-head">
                <tr>
                  <th>Código</th>
                  <th>Descripción del Giro</th>
                  <th>Categoría</th>
                  <th>Importe Base</th>
                  <th>Zona A</th>
                  <th>Zona B</th>
                  <th>Zona C</th>
                  <th>Estado</th>
                  <th>Vigencia</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="giro in giros" :key="giro.id_giro" class="municipal-table-row">
                  <td><strong>{{ giro.codigo_giro }}</strong></td>
                  <td class="text-truncate" style="max-width: 300px;" :title="giro.nombre_giro">
                    {{ giro.nombre_giro }}
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeCategoria(giro.categoria)">
                      {{ giro.categoria }}
                    </span>
                  </td>
                  <td class="text-end">
                    <span v-if="giro.importe_base > 0" class="fw-bold text-success">
                      ${{ formatearMoneda(giro.importe_base) }}
                    </span>
                    <span v-else class="text-danger fw-bold">PENDIENTE</span>
                  </td>
                  <td class="text-end text-muted">${{ formatearMoneda(giro.importe_zona_a) }}</td>
                  <td class="text-end text-muted">${{ formatearMoneda(giro.importe_zona_b) }}</td>
                  <td class="text-end text-muted">${{ formatearMoneda(giro.importe_zona_c) }}</td>
                  <td>
                    <span class="badge" :class="getBadgeEstado(giro.estado_importe)">
                      {{ formatearEstado(giro.estado_importe) }}
                    </span>
                  </td>
                  <td>
                    <small v-if="giro.dias_hasta_vencimiento >= 0" class="text-muted">
                      {{ giro.dias_hasta_vencimiento }} días
                    </small>
                    <small v-else class="text-success">Sin vencimiento</small>
                  </td>
                  <td>
                    <div class="btn-group btn-group-sm" role="group">
                      <button
                        class="btn btn-outline-warning"
                        @click="editarImporte(giro)"
                        title="Editar Importe"
                      >
                        <i class="fas fa-edit"></i>
                      </button>
                      <button
                        class="btn btn-outline-info"
                        @click="verHistorial(giro)"
                        title="Ver Historial"
                      >
                        <i class="fas fa-history"></i>
                      </button>
                      <button
                        class="btn btn-outline-primary"
                        @click="verDetalle(giro)"
                        title="Ver Detalle"
                      >
                        <i class="fas fa-eye"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer">
          <nav>
            <ul class="pagination municipal-pagination justify-content-center mb-0">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button class="page-link" @click="irAPagina(currentPage - 1)" :disabled="currentPage === 1">
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>
              <li
                v-for="pagina in paginasVisibles"
                :key="pagina"
                class="page-item"
                :class="{ active: pagina === currentPage }"
              >
                <button class="page-link" @click="irAPagina(pagina)">{{ pagina }}</button>
              </li>
              <li class="page-item" :class="{ disabled: currentPage === totalPaginas }">
                <button class="page-link" @click="irAPagina(currentPage + 1)" :disabled="currentPage === totalPaginas">
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal Editar Importe -->
    <div class="modal fade" id="modalEditarImporte" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-edit me-2"></i>
              Editar Importe - {{ giroSeleccionado?.nombre_giro }}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarImporte">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Importe Base (MXN):</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="formImporte.importe_base"
                    step="0.01"
                    min="0"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Factor de Indexación:</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="formImporte.factor_indexacion"
                    step="0.0001"
                    min="0.1"
                    max="2"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-4">
                  <label class="form-label">Zona A (80%):</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="formImporte.importe_zona_a"
                    step="0.01"
                    readonly
                  >
                </div>
                <div class="col-md-4">
                  <label class="form-label">Zona B (60%):</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="formImporte.importe_zona_b"
                    step="0.01"
                    readonly
                  >
                </div>
                <div class="col-md-4">
                  <label class="form-label">Zona C (40%):</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="formImporte.importe_zona_c"
                    step="0.01"
                    readonly
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Fecha Vigencia Inicio:</label>
                  <input
                    type="date"
                    class="form-control"
                    v-model="formImporte.fecha_vigencia_inicio"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Fecha Vigencia Fin:</label>
                  <input
                    type="date"
                    class="form-control"
                    v-model="formImporte.fecha_vigencia_fin"
                  >
                </div>
              </div>
              <div class="mt-3">
                <label class="form-label">Observaciones:</label>
                <textarea
                  class="form-control"
                  v-model="formImporte.observaciones"
                  rows="3"
                  placeholder="Comentarios sobre el cambio de importe..."
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cancelar
            </button>
            <button type="button" class="btn btn-success" @click="guardarImporte" :disabled="guardando">
              <i class="fas fa-save me-2"></i>
              <span v-if="guardando">Guardando...</span>
              <span v-else>Guardar Importe</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Asignación Masiva -->
    <div class="modal fade" id="modalAsignacionMasiva" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-dollar-sign me-2"></i>
              Asignación Masiva de Importes
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="ejecutarAsignacionMasiva">
              <div class="mb-3">
                <label class="form-label">Categoría a Procesar:</label>
                <select class="form-select" v-model="formMasivo.categoria" required>
                  <option value="TODOS">Todas las categorías</option>
                  <option value="ALIMENTACION">Alimentación</option>
                  <option value="COMERCIO">Comercio</option>
                  <option value="SERVICIOS">Servicios</option>
                  <option value="ENTRETENIMIENTO">Entretenimiento</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Factor de Incremento:</label>
                <input
                  type="number"
                  class="form-control"
                  v-model="formMasivo.factor_incremento"
                  step="0.0001"
                  min="0.1"
                  max="5"
                  required
                >
                <div class="form-text">1.0 = sin cambio, 1.1 = incremento 10%, 0.9 = reducción 10%</div>
              </div>
              <div class="mb-3">
                <label class="form-label">Importe Base Mínimo:</label>
                <input
                  type="number"
                  class="form-control"
                  v-model="formMasivo.importe_base_minimo"
                  step="0.01"
                  min="1"
                  required
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Observaciones:</label>
                <textarea
                  class="form-control"
                  v-model="formMasivo.observaciones"
                  rows="3"
                  placeholder="Motivo de la actualización masiva..."
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cancelar
            </button>
            <button type="button" class="btn btn-warning" @click="ejecutarAsignacionMasiva" :disabled="procesandoMasivo">
              <i class="fas fa-cogs me-2"></i>
              <span v-if="procesandoMasivo">Procesando...</span>
              <span v-else>Ejecutar Asignación</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Modal } from 'bootstrap'

export default {
  name: 'CatalogoGirosImportes',
  data() {
    return {
      // Estado de la aplicación
      loading: false,
      guardando: false,
      procesandoMasivo: false,

      // Datos principales
      giros: [],
      estadisticas: {},

      // Paginación
      currentPage: 1,
      itemsPerPage: 25,
      totalRegistros: 0,

      // Filtros
      filtros: {
        busqueda: '',
        categoria: 'TODOS',
        estado_importe: 'TODOS',
        vigencia: 'TODOS'
      },

      // Formularios
      giroSeleccionado: null,
      formImporte: {
        importe_base: 0,
        importe_zona_a: 0,
        importe_zona_b: 0,
        importe_zona_c: 0,
        factor_indexacion: 1.0000,
        fecha_vigencia_inicio: '',
        fecha_vigencia_fin: '',
        observaciones: ''
      },

      formMasivo: {
        categoria: 'TODOS',
        factor_incremento: 1.0000,
        importe_base_minimo: 1000.00,
        observaciones: 'Actualización masiva de importes'
      },

      // Modales
      modalEditarImporte: null,
      modalAsignacionMasiva: null
    }
  },

  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.itemsPerPage)
    },

    paginasVisibles() {
      const total = this.totalPaginas
      const current = this.currentPage
      const visibles = []

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          visibles.push(i)
        }
      } else {
        if (current <= 4) {
          for (let i = 1; i <= 5; i++) {
            visibles.push(i)
          }
          visibles.push('...')
          visibles.push(total)
        } else if (current >= total - 3) {
          visibles.push(1)
          visibles.push('...')
          for (let i = total - 4; i <= total; i++) {
            visibles.push(i)
          }
        } else {
          visibles.push(1)
          visibles.push('...')
          for (let i = current - 1; i <= current + 1; i++) {
            visibles.push(i)
          }
          visibles.push('...')
          visibles.push(total)
        }
      }

      return visibles
    }
  },

  async mounted() {
    await this.inicializar()
  },

  methods: {
    async inicializar() {
      try {
        // Inicializar modales
        this.modalEditarImporte = new Modal(document.getElementById('modalEditarImporte'))
        this.modalAsignacionMasiva = new Modal(document.getElementById('modalAsignacionMasiva'))

        // Cargar datos iniciales
        await Promise.all([
          this.cargarDatos(),
          this.cargarEstadisticas()
        ])
      } catch (error) {
        console.error('Error en inicialización:', error)
        this.mostrarError('Error al inicializar el componente')
      }
    },

    async cargarDatos() {
      this.loading = true
      try {
        const eRequest = {
          Operacion: 'sp_catalogo_giros_importes_list',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage },
            { nombre: 'p_filtro', valor: this.filtros.busqueda },
            { nombre: 'p_categoria', valor: this.filtros.categoria },
            { nombre: 'p_estado_importe', valor: this.filtros.estado_importe },
            { nombre: 'p_vigencia', valor: this.filtros.vigencia }
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

        if (data?.eResponse?.success) {
          this.giros = data.eResponse.data || []
          this.totalRegistros = this.giros.length > 0 ? this.giros[0].total_count : 0
        } else {
          throw new Error(data?.eResponse?.message || 'Error al cargar giros')
        }
      } catch (error) {
        console.error('Error cargando giros:', error)
        this.mostrarError('Error al cargar el catálogo de giros')
      } finally {
        this.loading = false
      }
    },

    async cargarEstadisticas() {
      try {
        const eRequest = {
          Operacion: 'sp_catalogo_giros_importes_estadisticas',
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

        if (data?.eResponse?.success && data.eResponse.data.length > 0) {
          this.estadisticas = data.eResponse.data[0]
        }
      } catch (error) {
        console.error('Error cargando estadísticas:', error)
      }
    },

    // Navegación y filtros
    irAPagina(pagina) {
      if (pagina !== '...' && pagina >= 1 && pagina <= this.totalPaginas) {
        this.currentPage = pagina
        this.cargarDatos()
      }
    },

    cambiarItemsPorPagina() {
      this.currentPage = 1
      this.cargarDatos()
    },

    limpiarFiltros() {
      this.filtros = {
        busqueda: '',
        categoria: 'TODOS',
        estado_importe: 'TODOS',
        vigencia: 'TODOS'
      }
      this.currentPage = 1
      this.cargarDatos()
    },

    // Gestión de importes
    editarImporte(giro) {
      this.giroSeleccionado = { ...giro }
      this.formImporte = {
        importe_base: giro.importe_base || 0,
        importe_zona_a: giro.importe_zona_a || 0,
        importe_zona_b: giro.importe_zona_b || 0,
        importe_zona_c: giro.importe_zona_c || 0,
        factor_indexacion: 1.0000,
        fecha_vigencia_inicio: giro.fecha_vigencia_inicio || new Date().toISOString().split('T')[0],
        fecha_vigencia_fin: giro.fecha_vigencia_fin || '',
        observaciones: ''
      }
      this.modalEditarImporte.show()
    },

    async guardarImporte() {
      if (!this.giroSeleccionado) return

      this.guardando = true
      try {
        const eRequest = {
          Operacion: 'sp_catalogo_giros_importes_update',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_id_giro', valor: this.giroSeleccionado.id_giro },
            { nombre: 'p_importe_base', valor: parseFloat(this.formImporte.importe_base) },
            { nombre: 'p_importe_zona_a', valor: parseFloat(this.formImporte.importe_zona_a) || null },
            { nombre: 'p_importe_zona_b', valor: parseFloat(this.formImporte.importe_zona_b) || null },
            { nombre: 'p_importe_zona_c', valor: parseFloat(this.formImporte.importe_zona_c) || null },
            { nombre: 'p_fecha_vigencia_inicio', valor: this.formImporte.fecha_vigencia_inicio || null },
            { nombre: 'p_fecha_vigencia_fin', valor: this.formImporte.fecha_vigencia_fin || null },
            { nombre: 'p_factor_indexacion', valor: parseFloat(this.formImporte.factor_indexacion) },
            { nombre: 'p_usuario_modificacion', valor: 'USUARIO_SESION' },
            { nombre: 'p_observaciones', valor: this.formImporte.observaciones }
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

        if (data?.eResponse?.success) {
          this.mostrarExito('Importe actualizado correctamente')
          this.modalEditarImporte.hide()
          await Promise.all([
            this.cargarDatos(),
            this.cargarEstadisticas()
          ])
        } else {
          throw new Error(data?.eResponse?.message || 'Error al guardar importe')
        }
      } catch (error) {
        console.error('Error guardando importe:', error)
        this.mostrarError('Error al guardar el importe')
      } finally {
        this.guardando = false
      }
    },

    // Asignación masiva
    abrirModalAsignacionMasiva() {
      this.modalAsignacionMasiva.show()
    },

    async ejecutarAsignacionMasiva() {
      this.procesandoMasivo = true
      try {
        const eRequest = {
          Operacion: 'sp_catalogo_giros_importes_masivo',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_categoria', valor: this.formMasivo.categoria },
            { nombre: 'p_factor_incremento', valor: parseFloat(this.formMasivo.factor_incremento) },
            { nombre: 'p_importe_base_minimo', valor: parseFloat(this.formMasivo.importe_base_minimo) },
            { nombre: 'p_fecha_vigencia_inicio', valor: null },
            { nombre: 'p_fecha_vigencia_fin', valor: null },
            { nombre: 'p_usuario_modificacion', valor: 'USUARIO_SESION' },
            { nombre: 'p_observaciones', valor: this.formMasivo.observaciones }
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

        if (data?.eResponse?.success && data.eResponse.data.length > 0) {
          const resultado = data.eResponse.data[0]
          this.mostrarExito(`Procesamiento completado: ${resultado.giros_actualizados} giros actualizados de ${resultado.giros_procesados} procesados`)
          this.modalAsignacionMasiva.hide()
          await Promise.all([
            this.cargarDatos(),
            this.cargarEstadisticas()
          ])
        } else {
          throw new Error(data?.eResponse?.message || 'Error en asignación masiva')
        }
      } catch (error) {
        console.error('Error en asignación masiva:', error)
        this.mostrarError('Error al ejecutar la asignación masiva')
      } finally {
        this.procesandoMasivo = false
      }
    },

    // Otras acciones
    verHistorial(giro) {
      // TODO: Implementar vista de historial
      this.mostrarInfo(`Ver historial de cambios para: ${giro.nombre_giro}`)
    },

    verDetalle(giro) {
      // TODO: Implementar vista detallada
      this.mostrarInfo(`Ver detalle completo de: ${giro.nombre_giro}`)
    },

    exportarDatos() {
      // TODO: Implementar exportación
      this.mostrarInfo('Función de exportación en desarrollo')
    },

    // Utilidades de formato
    formatearMoneda(valor) {
      if (!valor || valor === 0) return '0.00'
      return new Intl.NumberFormat('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(valor)
    },

    formatearEstado(estado) {
      const estados = {
        'PENDIENTE': 'Pendiente',
        'VIGENTE': 'Vigente',
        'PROXIMO_VENCER': 'Próximo a vencer',
        'VENCIDO': 'Vencido'
      }
      return estados[estado] || estado
    },

    getBadgeCategoria(categoria) {
      const badges = {
        'ALIMENTACION': 'bg-success',
        'COMERCIO': 'bg-primary',
        'SERVICIOS': 'bg-info',
        'ENTRETENIMIENTO': 'bg-warning text-dark',
        'SIN_CATEGORIA': 'bg-secondary'
      }
      return badges[categoria] || 'bg-secondary'
    },

    getBadgeEstado(estado) {
      const badges = {
        'PENDIENTE': 'bg-danger',
        'VIGENTE': 'bg-success',
        'PROXIMO_VENCER': 'bg-warning text-dark',
        'VENCIDO': 'bg-secondary'
      }
      return badges[estado] || 'bg-secondary'
    },

    // Notificaciones
    mostrarExito(mensaje) {
      // TODO: Implementar sistema de notificaciones
      alert('✅ ' + mensaje)
    },

    mostrarError(mensaje) {
      // TODO: Implementar sistema de notificaciones
      alert('❌ ' + mensaje)
    },

    mostrarInfo(mensaje) {
      // TODO: Implementar sistema de notificaciones
      alert('ℹ️ ' + mensaje)
    }
  },

  watch: {
    // Auto-calcular importes por zona
    'formImporte.importe_base'(nuevoImporte) {
      if (nuevoImporte && nuevoImporte > 0) {
        this.formImporte.importe_zona_a = (nuevoImporte * 0.8).toFixed(2)
        this.formImporte.importe_zona_b = (nuevoImporte * 0.6).toFixed(2)
        this.formImporte.importe_zona_c = (nuevoImporte * 0.4).toFixed(2)
      }
    }
  }
}
</script>

<style scoped>
/* Estilos base del componente */
.catalogo-giros-importes {
  padding: 1.5rem;
  background-color: #f8f9fa;
  min-height: 100vh;
}

/* Header Municipal */
.municipal-header {
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  color: white;
  padding: 2rem;
  border-radius: 0.5rem;
  box-shadow: 0 4px 12px rgba(30, 60, 114, 0.3);
}

.municipal-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.municipal-subtitle {
  font-size: 1rem;
  opacity: 0.9;
  margin-bottom: 0;
}

.municipal-badge .badge {
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
}

/* Controls Panel */
.municipal-controls .card {
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.municipal-card-header {
  background: linear-gradient(90deg, #ffc107 0%, #ff8c00 100%);
  color: #212529;
  border-bottom: 2px solid #e9ecef;
  font-weight: 600;
}

/* Estadísticas */
.municipal-stats .card {
  transition: transform 0.2s ease-in-out;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.municipal-stats .card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

/* Tabla Principal */
.municipal-table .card {
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.municipal-table-header {
  background: linear-gradient(90deg, #1e3c72 0%, #2a5298 100%);
  color: white;
  border-bottom: none;
}

.municipal-data-table {
  margin-bottom: 0;
}

.municipal-table-head {
  background: linear-gradient(90deg, #495057 0%, #6c757d 100%);
  color: white;
}

.municipal-table-head th {
  border-bottom: 2px solid #dee2e6;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.875rem;
  letter-spacing: 0.5px;
}

.municipal-table-row {
  transition: background-color 0.2s ease;
}

.municipal-table-row:hover {
  background-color: #f8f9fa;
  transform: scale(1.002);
}

/* Paginación */
.municipal-pagination .page-link {
  color: #1e3c72;
  border-color: #dee2e6;
  transition: all 0.2s ease;
}

.municipal-pagination .page-link:hover {
  color: white;
  background-color: #1e3c72;
  border-color: #1e3c72;
  transform: translateY(-1px);
}

.municipal-pagination .page-item.active .page-link {
  background-color: #1e3c72;
  border-color: #1e3c72;
}

.municipal-pagination-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* Modales */
.municipal-modal-header {
  background: linear-gradient(90deg, #1e3c72 0%, #2a5298 100%);
  color: white;
  border-bottom: none;
}

.municipal-modal-header .btn-close {
  filter: invert(1);
}

/* Badges y estados */
.badge {
  font-size: 0.75rem;
  padding: 0.35em 0.65em;
}

/* Botones de acción */
.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

/* Responsive */
@media (max-width: 768px) {
  .catalogo-giros-importes {
    padding: 1rem;
  }

  .municipal-header {
    padding: 1.5rem;
  }

  .municipal-title {
    font-size: 1.5rem;
  }

  .municipal-stats .col-lg-3 {
    margin-bottom: 1rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }
}

/* Animaciones */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.municipal-controls,
.municipal-stats,
.municipal-table {
  animation: fadeInUp 0.5s ease-out;
}

/* Estados de carga */
.spinner-border {
  width: 3rem;
  height: 3rem;
}

/* Truncate text */
.text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>