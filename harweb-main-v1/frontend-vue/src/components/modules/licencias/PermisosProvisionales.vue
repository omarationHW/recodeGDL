<template>
  <div class="permisos-provisionales">
    <!-- Header Municipal -->
    <div class="municipal-header mb-4">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h2 class="municipal-title">
            <i class="fas fa-clock me-2 text-warning"></i>
            Permisos Provisionales
          </h2>
          <p class="municipal-subtitle">Sistema de permisos temporales con vigencia limitada</p>
        </div>
        <div class="municipal-badge">
          <span class="badge bg-info text-dark">PRIORIDAD 3</span>
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
                placeholder="Buscar por folio, nombre..."
              >
            </div>
            <div class="col-md-3">
              <label class="form-label">Estado:</label>
              <select class="form-select" v-model="filtros.estado" @change="cargarDatos">
                <option value="TODOS">Todos los estados</option>
                <option value="VIGENTE">Vigentes</option>
                <option value="PROXIMO_VENCER">Próximos a vencer</option>
                <option value="VENCIDO">Vencidos</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Mostrar por página:</label>
              <select class="form-select" v-model="itemsPerPage" @change="cambiarItemsPorPagina">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Acciones:</label>
              <div class="d-flex gap-2">
                <button class="btn btn-outline-primary btn-sm" @click="exportarDatos">
                  <i class="fas fa-download"></i>
                </button>
                <button class="btn btn-outline-secondary btn-sm" @click="limpiarFiltros">
                  <i class="fas fa-times"></i>
                </button>
              </div>
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
              <h3 class="text-success">{{ estadisticas.permisos_vigentes || 0 }}</h3>
              <p class="mb-0">Permisos Vigentes</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-warning h-100">
            <div class="card-body text-center">
              <i class="fas fa-exclamation-triangle text-warning mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-warning">{{ estadisticas.permisos_proximo_vencer || 0 }}</h3>
              <p class="mb-0">Próximos a Vencer</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-danger h-100">
            <div class="card-body text-center">
              <i class="fas fa-times-circle text-danger mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-danger">{{ estadisticas.permisos_vencidos || 0 }}</h3>
              <p class="mb-0">Vencidos</p>
            </div>
          </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-3">
          <div class="card border-info h-100">
            <div class="card-body text-center">
              <i class="fas fa-dollar-sign text-info mb-2" style="font-size: 2rem;"></i>
              <h3 class="text-info">${{ formatearMoneda(estadisticas.ingresos_mes_actual) }}</h3>
              <p class="mb-0">Ingresos del Mes</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs por Tipo de Permiso -->
    <div class="municipal-table" v-if="!loading">
      <div class="card">
        <div class="card-header municipal-table-header">
          <ul class="nav nav-tabs card-header-tabs" role="tablist">
            <li class="nav-item" role="presentation">
              <button
                class="nav-link"
                :class="{ active: tipoActivo === 'ESPECTACULOS' }"
                @click="cambiarTipo('ESPECTACULOS')"
                type="button"
              >
                <i class="fas fa-music me-2"></i>Espectáculos
                <span class="badge bg-light text-dark ms-2">{{ estadisticas.espectaculos_activos || 0 }}</span>
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button
                class="nav-link"
                :class="{ active: tipoActivo === 'LICENCIAS' }"
                @click="cambiarTipo('LICENCIAS')"
                type="button"
              >
                <i class="fas fa-certificate me-2"></i>Licencias Temporales
                <span class="badge bg-light text-dark ms-2">{{ estadisticas.licencias_temporales_activas || 0 }}</span>
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button
                class="nav-link"
                :class="{ active: tipoActivo === 'ANUNCIOS' }"
                @click="cambiarTipo('ANUNCIOS')"
                type="button"
              >
                <i class="fas fa-bullhorn me-2"></i>Anuncios Temporales
                <span class="badge bg-light text-dark ms-2">{{ estadisticas.anuncios_temporales_activos || 0 }}</span>
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button
                class="nav-link"
                :class="{ active: tipoActivo === 'TODOS' }"
                @click="cambiarTipo('TODOS')"
                type="button"
              >
                <i class="fas fa-list me-2"></i>Todos
                <span class="badge bg-light text-dark ms-2">{{ totalRegistros }}</span>
              </button>
            </li>
          </ul>
        </div>

        <div class="card-body p-0">
          <!-- Botón de acción según tipo -->
          <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
            <h5 class="mb-0">
              <i :class="getIconoTipo(tipoActivo)" class="me-2"></i>
              {{ getTituloTipo(tipoActivo) }}
            </h5>
            <button class="btn btn-success btn-sm" @click="abrirModalNuevo">
              <i class="fas fa-plus me-2"></i>Nuevo {{ getNombreTipo(tipoActivo) }}
            </button>
          </div>

          <!-- Tabla Principal -->
          <div class="table-responsive">
            <table class="table table-hover municipal-data-table">
              <thead class="municipal-table-head">
                <tr>
                  <th>Folio</th>
                  <th>Tipo/Evento</th>
                  <th>Solicitante</th>
                  <th v-if="tipoActivo === 'ANUNCIOS'">Ubicación</th>
                  <th v-else>Fecha Evento</th>
                  <th>Vigencia</th>
                  <th>Estado</th>
                  <th>Importe</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="permiso in permisos" :key="permiso.id_permiso" class="municipal-table-row">
                  <td><strong>{{ permiso.folio }}</strong></td>
                  <td class="text-truncate" style="max-width: 200px;" :title="permiso.tipo_especifico">
                    {{ permiso.tipo_especifico }}
                  </td>
                  <td>
                    {{ permiso.nombre_solicitante }}
                    <small v-if="permiso.razon_social" class="d-block text-muted">
                      {{ permiso.razon_social }}
                    </small>
                  </td>
                  <td>
                    <span v-if="tipoActivo === 'ANUNCIOS'">{{ permiso.ubicacion }}</span>
                    <span v-else>{{ formatearFecha(permiso.fecha_inicio) }}</span>
                  </td>
                  <td>
                    <span v-if="permiso.dias_restantes > 0" :class="getClaseVigencia(permiso.dias_restantes)">
                      {{ permiso.dias_restantes }} días restantes
                    </span>
                    <span v-else class="text-danger">VENCIDO</span>
                    <small class="d-block text-muted">
                      Hasta: {{ formatearFecha(permiso.fecha_fin) }}
                    </small>
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeEstado(permiso.estado_vigencia)">
                      {{ formatearEstado(permiso.estado_vigencia) }}
                    </span>
                  </td>
                  <td class="text-end">
                    <span v-if="permiso.importe_pagado > 0" class="fw-bold text-success">
                      ${{ formatearMoneda(permiso.importe_pagado) }}
                    </span>
                    <span v-else class="text-muted">Sin costo</span>
                  </td>
                  <td>
                    <div class="btn-group btn-group-sm" role="group">
                      <button
                        class="btn btn-outline-info"
                        @click="verDetalle(permiso)"
                        title="Ver detalles"
                      >
                        <i class="fas fa-eye"></i>
                      </button>
                      <button
                        v-if="permiso.estado_vigencia !== 'VENCIDO'"
                        class="btn btn-outline-warning"
                        @click="extenderPermiso(permiso)"
                        title="Extender vigencia"
                      >
                        <i class="fas fa-calendar-plus"></i>
                      </button>
                      <button
                        v-if="tipoActivo === 'LICENCIAS' && permiso.estado_vigencia === 'VIGENTE'"
                        class="btn btn-outline-success"
                        @click="convertirPermanente(permiso)"
                        title="Convertir a permanente"
                      >
                        <i class="fas fa-arrow-up"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
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

    <!-- Modal Detalle -->
    <div class="modal fade" id="modalDetalle" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-eye me-2"></i>
              Detalle del Permiso - {{ permisoSeleccionado?.folio }}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="permisoSeleccionado">
            <!-- Contenido del detalle -->
            <div class="row">
              <div class="col-md-6">
                <h6>Información General</h6>
                <table class="table table-sm">
                  <tr><td><strong>Folio:</strong></td><td>{{ permisoSeleccionado.folio }}</td></tr>
                  <tr><td><strong>Tipo:</strong></td><td>{{ permisoSeleccionado.tipo_especifico }}</td></tr>
                  <tr><td><strong>Solicitante:</strong></td><td>{{ permisoSeleccionado.nombre_solicitante }}</td></tr>
                  <tr><td><strong>Estado:</strong></td><td>
                    <span class="badge" :class="getBadgeEstado(permisoSeleccionado.estado_vigencia)">
                      {{ formatearEstado(permisoSeleccionado.estado_vigencia) }}
                    </span>
                  </td></tr>
                </table>
              </div>
              <div class="col-md-6">
                <h6>Vigencia y Fechas</h6>
                <table class="table table-sm">
                  <tr><td><strong>Fecha Inicio:</strong></td><td>{{ formatearFecha(permisoSeleccionado.fecha_inicio) }}</td></tr>
                  <tr><td><strong>Fecha Fin:</strong></td><td>{{ formatearFecha(permisoSeleccionado.fecha_fin) }}</td></tr>
                  <tr><td><strong>Días Vigencia:</strong></td><td>{{ permisoSeleccionado.dias_vigencia }}</td></tr>
                  <tr><td><strong>Días Restantes:</strong></td><td>{{ permisoSeleccionado.dias_restantes }}</td></tr>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Extender -->
    <div class="modal fade" id="modalExtender" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-calendar-plus me-2"></i>
              Extender Vigencia
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarExtension">
              <div class="mb-3">
                <label class="form-label">Nueva Fecha de Vencimiento:</label>
                <input
                  type="date"
                  class="form-control"
                  v-model="formExtension.nueva_fecha_fin"
                  :min="fechaMinima"
                  required
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Motivo de la Extensión:</label>
                <textarea
                  class="form-control"
                  v-model="formExtension.motivo_extension"
                  rows="3"
                  placeholder="Describir el motivo..."
                  required
                ></textarea>
              </div>
              <div class="mb-3">
                <label class="form-label">Importe Adicional (opcional):</label>
                <input
                  type="number"
                  class="form-control"
                  v-model="formExtension.importe_adicional"
                  step="0.01"
                  min="0"
                >
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cancelar
            </button>
            <button type="button" class="btn btn-warning" @click="guardarExtension" :disabled="extendiendoPermiso">
              <i class="fas fa-save me-2"></i>
              <span v-if="extendiendoPermiso">Extendiendo...</span>
              <span v-else>Extender Permiso</span>
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
  name: 'PermisosProvisionales',
  data() {
    return {
      // Estado de la aplicación
      loading: false,
      extendiendoPermiso: false,

      // Datos principales
      permisos: [],
      estadisticas: {},
      permisoSeleccionado: null,

      // Filtros y controles
      tipoActivo: 'ESPECTACULOS',
      filtros: {
        busqueda: '',
        estado: 'TODOS'
      },

      // Paginación
      currentPage: 1,
      itemsPerPage: 25,
      totalRegistros: 0,

      // Formularios
      formExtension: {
        nueva_fecha_fin: '',
        motivo_extension: '',
        importe_adicional: 0
      },

      // Modales
      modalDetalle: null,
      modalExtender: null
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
    },

    fechaMinima() {
      const hoy = new Date()
      hoy.setDate(hoy.getDate() + 1) // Mínimo mañana
      return hoy.toISOString().split('T')[0]
    }
  },

  async mounted() {
    await this.inicializar()
  },

  methods: {
    async inicializar() {
      try {
        // Inicializar modales
        this.modalDetalle = new Modal(document.getElementById('modalDetalle'))
        this.modalExtender = new Modal(document.getElementById('modalExtender'))

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
          Operacion: 'sp_permisos_provisionales_list',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_tipo_permiso', valor: this.tipoActivo },
            { nombre: 'p_estado', valor: this.filtros.estado },
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage },
            { nombre: 'p_filtro', valor: this.filtros.busqueda }
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
          this.permisos = data.eResponse.data || []
          this.totalRegistros = this.permisos.length > 0 ? this.permisos[0].total_count : 0
        } else {
          throw new Error(data?.eResponse?.message || 'Error al cargar permisos')
        }
      } catch (error) {
        console.error('Error cargando permisos:', error)
        this.mostrarError('Error al cargar los permisos provisionales')
      } finally {
        this.loading = false
      }
    },

    async cargarEstadisticas() {
      try {
        const eRequest = {
          Operacion: 'sp_permisos_provisionales_estadisticas',
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
    cambiarTipo(nuevoTipo) {
      this.tipoActivo = nuevoTipo
      this.currentPage = 1
      this.cargarDatos()
    },

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
        estado: 'TODOS'
      }
      this.currentPage = 1
      this.cargarDatos()
    },

    // Acciones de permisos
    async verDetalle(permiso) {
      try {
        const eRequest = {
          Operacion: 'sp_permisos_provisionales_detalle',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_id_permiso', valor: permiso.id_permiso }
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
          this.permisoSeleccionado = data.eResponse.data[0]
          this.modalDetalle.show()
        } else {
          throw new Error('No se pudo obtener el detalle del permiso')
        }
      } catch (error) {
        console.error('Error obteniendo detalle:', error)
        this.mostrarError('Error al obtener el detalle del permiso')
      }
    },

    extenderPermiso(permiso) {
      this.permisoSeleccionado = permiso
      this.formExtension = {
        nueva_fecha_fin: '',
        motivo_extension: '',
        importe_adicional: 0
      }
      this.modalExtender.show()
    },

    async guardarExtension() {
      if (!this.permisoSeleccionado) return

      this.extendiendoPermiso = true
      try {
        const eRequest = {
          Operacion: 'sp_permisos_provisionales_extender',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_id_permiso', valor: this.permisoSeleccionado.id_permiso },
            { nombre: 'p_nueva_fecha_fin', valor: this.formExtension.nueva_fecha_fin },
            { nombre: 'p_motivo_extension', valor: this.formExtension.motivo_extension },
            { nombre: 'p_importe_adicional', valor: parseFloat(this.formExtension.importe_adicional) || 0 },
            { nombre: 'p_usuario_modificacion', valor: 'USUARIO_SESION' }
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
          this.mostrarExito('Permiso extendido correctamente')
          this.modalExtender.hide()
          await Promise.all([
            this.cargarDatos(),
            this.cargarEstadisticas()
          ])
        } else {
          throw new Error(data?.eResponse?.message || 'Error al extender permiso')
        }
      } catch (error) {
        console.error('Error extendiendo permiso:', error)
        this.mostrarError('Error al extender el permiso')
      } finally {
        this.extendiendoPermiso = false
      }
    },

    convertirPermanente(permiso) {
      // TODO: Implementar conversión a permanente
      this.mostrarInfo(`Conversión a permanente para: ${permiso.folio}`)
    },

    abrirModalNuevo() {
      // TODO: Implementar creación de nuevos permisos
      this.mostrarInfo(`Crear nuevo ${this.getNombreTipo(this.tipoActivo)}`)
    },

    exportarDatos() {
      // TODO: Implementar exportación
      this.mostrarInfo('Función de exportación en desarrollo')
    },

    // Utilidades de formato
    formatearFecha(fecha) {
      if (!fecha) return '-'
      return new Date(fecha).toLocaleDateString('es-MX')
    },

    formatearMoneda(valor) {
      if (!valor || valor === 0) return '0.00'
      return new Intl.NumberFormat('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(valor)
    },

    formatearEstado(estado) {
      const estados = {
        'VIGENTE': 'Vigente',
        'PROXIMO_VENCER': 'Próximo a vencer',
        'VENCIDO': 'Vencido'
      }
      return estados[estado] || estado
    },

    getBadgeEstado(estado) {
      const badges = {
        'VIGENTE': 'bg-success',
        'PROXIMO_VENCER': 'bg-warning text-dark',
        'VENCIDO': 'bg-danger'
      }
      return badges[estado] || 'bg-secondary'
    },

    getClaseVigencia(dias) {
      if (dias <= 3) return 'text-danger'
      if (dias <= 7) return 'text-warning'
      return 'text-success'
    },

    getIconoTipo(tipo) {
      const iconos = {
        'ESPECTACULOS': 'fas fa-music text-primary',
        'LICENCIAS': 'fas fa-certificate text-warning',
        'ANUNCIOS': 'fas fa-bullhorn text-success',
        'TODOS': 'fas fa-list text-info'
      }
      return iconos[tipo] || 'fas fa-file'
    },

    getTituloTipo(tipo) {
      const titulos = {
        'ESPECTACULOS': 'Permisos de Espectáculos',
        'LICENCIAS': 'Licencias Temporales',
        'ANUNCIOS': 'Anuncios Temporales',
        'TODOS': 'Todos los Permisos'
      }
      return titulos[tipo] || 'Permisos'
    },

    getNombreTipo(tipo) {
      const nombres = {
        'ESPECTACULOS': 'Permiso de Espectáculo',
        'LICENCIAS': 'Licencia Temporal',
        'ANUNCIOS': 'Anuncio Temporal',
        'TODOS': 'Permiso'
      }
      return nombres[tipo] || 'Permiso'
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
  }
}
</script>

<style scoped>
/* Estilos base del componente */
.permisos-provisionales {
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
  background: linear-gradient(90deg, #17a2b8 0%, #138496 100%);
  color: white;
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
  padding: 0;
}

.municipal-table-header .nav-tabs {
  border-bottom: none;
  margin-bottom: 0;
}

.municipal-table-header .nav-link {
  background: transparent;
  border: none;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 500;
  padding: 1rem 1.5rem;
  transition: all 0.3s ease;
}

.municipal-table-header .nav-link:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.municipal-table-header .nav-link.active {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border-bottom: 3px solid #ffc107;
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
  .permisos-provisionales {
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

  .municipal-table-header .nav-link {
    padding: 0.75rem 1rem;
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