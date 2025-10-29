<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-search me-2"></i>Búsqueda de Actividades Comerciales</h1>
          <p class="mb-0 opacity-75">Sistema de consulta y búsqueda de actividades y giros comerciales</p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
            <li class="breadcrumb-item text-white active">Búsqueda Actividades</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Controls -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-home"></i>
          </button>
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-search"></i>
          </button>
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-list"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="p-4">

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">
          <i class="fas fa-filter me-2"></i>
          Filtros de Búsqueda
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label for="scian" class="form-label">Código SCIAN</label>
            <input
              type="number"
              class="form-control"
              id="scian"
              v-model="scian"
              @input="debounceSearch"
              @keyup.enter="buscarActividades"
              placeholder="Ej: 462112"
            >
          </div>
          <div class="col-md-6">
            <label for="filtroDescripcion" class="form-label">Descripción de Actividad</label>
            <input
              type="text"
              class="form-control"
              id="filtroDescripcion"
              v-model="filtroDescripcion"
              @input="debounceSearch"
              @keyup.enter="buscarActividades"
              placeholder="Ingrese descripción de la actividad para buscar..."
              maxlength="255"
            >
          </div>
          <div class="col-md-3">
            <label for="clasificacion" class="form-label">Clasificación</label>
            <select
              id="clasificacion"
              class="form-select"
              v-model="clasificacion"
              @change="debounceSearch"
            >
              <option value="">Todas</option>
              <option value="AGRICULTURA">Agricultura</option>
              <option value="MINERIA">Minería</option>
              <option value="MANUFACTURA">Manufactura</option>
              <option value="COMERCIO">Comercio</option>
              <option value="TRANSPORTE">Transporte</option>
              <option value="INFORMACION">Información</option>
              <option value="FINANCIERO">Financiero</option>
              <option value="INMOBILIARIO">Inmobiliario</option>
              <option value="PROFESIONALES">Profesionales</option>
              <option value="EDUCACION">Educación</option>
              <option value="ENTRETENIMIENTO">Entretenimiento</option>
              <option value="HOSPEDAJE">Hospedaje</option>
              <option value="OTROS_SERVICIOS">Otros Servicios</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 d-flex gap-2">
            <button
              type="button"
              class="btn btn-primary"
              @click="buscarActividades"
              :disabled="buscando"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              type="button"
              class="btn btn-success"
              @click="actualizarDatos"
              :disabled="buscando"
            >
              <i class="fas fa-sync-alt me-2"></i>
              {{ buscando ? 'Actualizando...' : 'Actualizar' }}
            </button>
            <button
              v-if="modoDesarrollo"
              type="button"
              class="btn btn-warning"
              @click="generarDatosSimulados"
            >
              <i class="fas fa-database me-2"></i>
              Datos Simulados
            </button>
            <button
              type="button"
              class="btn btn-outline-secondary"
              @click="limpiarFiltros"
            >
              <i class="fas fa-times me-2"></i>
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados de búsqueda -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Resultados de Búsqueda
          <span v-if="totalRegistros > 0" class="badge bg-light text-dark ms-2">{{ totalRegistros }}</span>
        </h5>
        <div class="d-flex gap-2">
          <select
            v-model="limitePorPagina"
            class="form-select form-select-sm"
            @change="buscarActividades"
            style="width: auto;"
          >
            <option value="10">10 por página</option>
            <option value="25">25 por página</option>
            <option value="50">50 por página</option>
            <option value="100">100 por página</option>
          </select>
        </div>
      </div>
      <div class="card-body">
        <div v-if="buscando" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2">Buscando actividades...</p>
        </div>
        
        <div v-else-if="actividades.length === 0 && !primeraBusqueda" class="text-center py-4">
          <i class="fas fa-search fa-3x text-muted mb-3"></i>
          <p class="text-muted">No se encontraron actividades con los criterios especificados</p>
        </div>

        <div v-else-if="primeraBusqueda" class="text-center py-4">
          <i class="fas fa-info-circle fa-3x text-info mb-3"></i>
          <p class="text-muted">Utilice los filtros de arriba para buscar actividades</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th style="width: 80px;">SCIAN</th>
                  <th>Descripción</th>
                  <th style="width: 120px;">Clasificación</th>
                  <th style="width: 100px;">Costo</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="actividad in actividades"
                  :key="actividad.id_giro"
                  :class="{'table-primary': actividad === actividadSeleccionada}"
                  style="cursor: pointer;"
                  @click="seleccionarActividad(actividad)"
                >
                  <td>{{ actividad.cod_giro }}</td>
                  <td>{{ actividad.descripcion }}</td>
                  <td>
                    <span class="badge bg-secondary">{{ actividad.clasificacion || 'SIN_CLASIFICAR' }}</span>
                  </td>
                  <td>{{ actividad.costo ? '$' + Number(actividad.costo).toFixed(2) : 'N/A' }}</td>
                  <td class="text-center">
                    <button
                      class="btn btn-sm btn-outline-primary"
                      @click.stop="verDetalleActividad(actividad)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="card-footer d-flex justify-content-between align-items-center">
            <small class="text-muted">
              Mostrando {{ ((paginaActual - 1) * limitePorPagina) + 1 }} a
              {{ Math.min(paginaActual * limitePorPagina, totalRegistros) }} de
              {{ totalRegistros }} registros
            </small>
            <nav aria-label="Paginación de resultados">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <button class="page-link" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                    <i class="fas fa-chevron-left"></i>
                  </button>
                </li>
                <li
                  v-for="pagina in paginasVisibles"
                  :key="pagina"
                  class="page-item"
                  :class="{ active: pagina === paginaActual }"
                >
                  <button class="page-link" @click="cambiarPagina(pagina)" v-if="typeof pagina === 'number'">{{ pagina }}</button>
                  <span class="page-link" v-else>{{ pagina }}</span>
                </li>
                <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                  <button class="page-link" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel de actividad seleccionada -->
    <div v-if="actividadSeleccionada" class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">
          <i class="fas fa-check-circle me-2"></i>
          Actividad Seleccionada
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <div class="mb-2">
              <strong>SCIAN:</strong> {{ actividadSeleccionada.cod_giro }}
            </div>
            <div class="mb-2">
              <strong>Descripción:</strong> {{ actividadSeleccionada.descripcion }}
            </div>
            <div class="mb-2">
              <strong>Clasificación:</strong>
              <span class="badge bg-secondary">{{ actividadSeleccionada.clasificacion || 'SIN_CLASIFICAR' }}</span>
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-2">
              <strong>Costo:</strong> {{ actividadSeleccionada.costo ? '$' + Number(actividadSeleccionada.costo).toFixed(2) : 'N/A' }}
            </div>
            <div class="mb-2">
              <strong>Tipo:</strong>
              <span class="badge bg-info">{{ actividadSeleccionada.tipo_actividad || 'MIXTO' }}</span>
            </div>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 d-flex gap-2">
            <button 
              class="btn btn-success"
              @click="confirmarSeleccion"
            >
              <i class="fas fa-check me-2"></i>
              Confirmar Selección
            </button>
            <button 
              class="btn btn-outline-secondary"
              @click="limpiarSeleccion"
            >
              <i class="fas fa-times me-2"></i>
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="alertMessage" :class="`alert alert-${alertType} alert-dismissible fade show`">
      <i :class="`fas ${alertType === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2`"></i>
      {{ alertMessage }}
      <button type="button" class="btn-close" @click="clearAlert"></button>
    </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaActividadFrm',
  data() {
    return {
      // Filtros de búsqueda
      filtroDescripcion: '',
      scian: '', // Parámetro requerido por el SP
      clasificacion: '',

      // Datos
      actividades: [],
      actividadSeleccionada: null,

      // Estados de UI
      buscando: false,
      primeraBusqueda: true,
      debounceTimer: null,
      modoDesarrollo: process.env.NODE_ENV === 'development',

      // Paginación
      paginaActual: 1,
      limitePorPagina: 25,
      totalRegistros: 0,

      // Alertas
      alertMessage: '',
      alertType: 'info',

      // Configuración API
      apiConfig: {
        url: 'http://localhost:8000/api/generic',
        tenant: 'guadalajara',
        base: 'padron_licencias'
      }
    }
  },
  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.limitePorPagina);
    },
    paginasVisibles() {
      const total = this.totalPaginas;
      const actual = this.paginaActual;
      const paginas = [];

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          paginas.push(i);
        }
      } else {
        if (actual <= 4) {
          for (let i = 1; i <= 5; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        } else if (actual >= total - 3) {
          paginas.push(1);
          paginas.push('...');
          for (let i = total - 4; i <= total; i++) {
            paginas.push(i);
          }
        } else {
          paginas.push(1);
          paginas.push('...');
          for (let i = actual - 1; i <= actual + 1; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        }
      }

      return paginas;
    }
  },
  
  async mounted() {
    // Obtener parámetros desde query params
    this.scian = this.$route.query.scian || ''
    this.filtroDescripcion = this.$route.query.descripcion || ''
    this.clasificacion = this.$route.query.clasificacion || ''

    // Si hay parámetros de query, realizar búsqueda inicial
    if (this.scian || this.filtroDescripcion) {
      this.buscarActividades()
    }
  },
  
  methods: {
    async buscarActividades() {
      // Validar criterios mínimos de búsqueda
      if (!this.scian && (!this.filtroDescripcion || this.filtroDescripcion.trim().length < 3)) {
        this.actividades = []
        this.totalRegistros = 0
        this.primeraBusqueda = true
        this.showAlert('Ingrese un código SCIAN o al menos 3 caracteres en la descripción', 'warning')
        return
      }

      this.buscando = true
      this.primeraBusqueda = false
      this.clearAlert()

      try {
        // Construir parámetros para el SP
        const params = {
          scian: this.scian ? parseInt(this.scian) : null,
          descripcion: this.filtroDescripcion.trim() || '',
          clasificacion: this.clasificacion || '',
          limite: this.limitePorPagina,
          offset: (this.paginaActual - 1) * this.limitePorPagina
        }

        // Request usando patrón eRequest/eResponse
        const requestBody = {
          eRequest: 'SP_BUSQUEDA_ACTIVIDAD_LIST',
          eData: {
            tenant: this.apiConfig.tenant,
            base: this.apiConfig.base,
            params: params
          }
        }

        console.log('Enviando request:', requestBody)

        const response = await fetch(this.apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Response recibida:', data)

        if (data.eResponse && data.eResponse.success) {
          const records = data.eResponse.data || []
          console.log('Records encontrados:', records)

          this.actividades = records
          this.totalRegistros = records.length

          if (this.totalRegistros === 0) {
            this.showAlert('No se encontraron actividades con los criterios especificados', 'info')
          } else {
            this.showAlert(`Se encontraron ${this.totalRegistros} actividade(s)`, 'success')
          }
        } else {
          console.error('Error en eResponse:', data.eResponse?.error || data.eResponse?.message)
          this.actividades = []
          this.totalRegistros = 0
          this.showAlert(data.eResponse?.error || data.eResponse?.message || 'Error al buscar actividades', 'danger')
        }

      } catch (error) {
        console.error('Error en buscarActividades:', error)
        this.showAlert('Error de conexión al buscar actividades', 'danger')
        this.actividades = []
        this.totalRegistros = 0
      } finally {
        this.buscando = false
      }
    },

    async actualizarDatos() {
      // Force refresh de los datos sin cambiar filtros
      if (this.scian || (this.filtroDescripcion && this.filtroDescripcion.trim().length >= 3)) {
        this.showAlert('Actualizando datos desde el servidor...', 'info')
        // Reset paginación y forzar nueva búsqueda
        this.paginaActual = 1
        await this.buscarActividades()
      } else {
        this.showAlert('Ingrese un código SCIAN o al menos 3 caracteres en la descripción', 'warning')
      }
    },

    cambiarPagina(nuevaPagina) {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= this.totalPaginas) {
        this.paginaActual = nuevaPagina;
        this.buscarActividades();
      }
    },
    
    debounceSearch() {
      // Limpiar timer anterior
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer)
      }

      // Establecer nuevo timer
      this.debounceTimer = setTimeout(() => {
        // Reset paginación en nueva búsqueda
        this.paginaActual = 1
        this.buscarActividades()
      }, 1000) // Buscar después de 1 segundo de inactividad
    },
    
    limpiarFiltros() {
      this.scian = ''
      this.filtroDescripcion = ''
      this.clasificacion = ''
      this.actividades = []
      this.actividadSeleccionada = null
      this.primeraBusqueda = true
      // Reset paginación
      this.paginaActual = 1
      this.totalRegistros = 0
      this.clearAlert()
    },
    
    seleccionarActividad(actividad) {
      this.actividadSeleccionada = actividad
      this.showAlert(`Actividad seleccionada: ${actividad.descripcion}`, 'info')
    },
    
    limpiarSeleccion() {
      this.actividadSeleccionada = null
      this.showAlert('Selección cancelada', 'info')
    },
    
    confirmarSeleccion() {
      if (!this.actividadSeleccionada) return
      
      // Emitir evento para componente padre
      this.$emit('actividad-seleccionada', this.actividadSeleccionada)

      // Mostrar confirmación
      this.showAlert(
        `Actividad confirmada: ${this.actividadSeleccionada.descripcion}`,
        'success'
      )
      
      // Si es una ventana modal o popup, cerrarla
      if (this.$route.query.modal === 'true') {
        window.close()
      }
      
      // Alternativamente, navegar a otra página con los datos
      // this.$router.push({
      //   name: 'OtraPagina',
      //   params: { id_giro: this.actividadSeleccionada.id_giro },
      //   query: { actividad: this.actividadSeleccionada.actividad }
      // })
    },
    
    async verDetalleActividad(actividad) {
      try {
        // Obtener detalle completo usando SP_BUSQUEDA_ACTIVIDAD_GET
        const requestBody = {
          eRequest: 'SP_BUSQUEDA_ACTIVIDAD_GET',
          eData: {
            tenant: this.apiConfig.tenant,
            base: this.apiConfig.base,
            params: {
              id_giro: actividad.id_giro
            }
          }
        }

        const response = await fetch(this.apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        const data = await response.json()

        if (data.eResponse && data.eResponse.success && data.eResponse.data.length > 0) {
          const detalle = data.eResponse.data[0]
          const detalles = [
            `SCIAN: ${detalle.cod_giro}`,
            `Descripción: ${detalle.descripcion}`,
            `Clasificación: ${detalle.clasificacion}`,
            `Tipo: ${detalle.tipo_actividad}`,
            `Costo: ${detalle.costo_actual ? '$' + Number(detalle.costo_actual).toFixed(2) : 'N/A'}`,
            `Refrendo: ${detalle.refrendo_actual ? '$' + Number(detalle.refrendo_actual).toFixed(2) : 'N/A'}`,
            `Licencias: ${detalle.total_licencias || 0}`,
            `Trámites: ${detalle.total_tramites || 0}`
          ].join('\n')

          alert(`Detalle Completo de Actividad:\n\n${detalles}`)
        } else {
          // Fallback con datos básicos
          const detalles = [
            `SCIAN: ${actividad.cod_giro}`,
            `Descripción: ${actividad.descripcion}`,
            `Clasificación: ${actividad.clasificacion || 'SIN_CLASIFICAR'}`,
            `Costo: ${actividad.costo ? '$' + Number(actividad.costo).toFixed(2) : 'N/A'}`
          ].join('\n')

          alert(`Detalle de Actividad:\n\n${detalles}`)
        }
      } catch (error) {
        console.error('Error al obtener detalle:', error)
        // Mostrar datos básicos como fallback
        const detalles = [
          `SCIAN: ${actividad.cod_giro}`,
          `Descripción: ${actividad.descripcion}`,
          `Costo: ${actividad.costo ? '$' + actividad.costo : 'N/A'}`
        ].join('\n')

        alert(`Detalle de Actividad:\n\n${detalles}`)
      }
    },
    
    showAlert(message, type = 'info') {
      this.alertMessage = message
      this.alertType = type
      
      // Auto-hide después de 5 segundos para success/info
      if (type === 'success' || type === 'info') {
        setTimeout(() => {
          this.clearAlert()
        }, 5000)
      }
    },
    
    clearAlert() {
      this.alertMessage = ''
      this.alertType = 'info'
    },

    // Método para generar datos simulados en desarrollo
    generarDatosSimulados() {
      if (!this.modoDesarrollo) return

      const actividadesSimuladas = [
        {
          id_giro: 5001,
          cod_giro: 431110,
          descripcion: 'Comercio al por mayor de abarrotes, alimentos, bebidas, hielo y tabaco',
          vigente: 'V',
          axo: 2024,
          costo: 2500.00,
          refrendo: 1250.00,
          clasificacion: 'COMERCIO',
          tipo_actividad: 'COMERCIAL'
        },
        {
          id_giro: 5002,
          cod_giro: 311111,
          descripcion: 'Elaboración de alimentos para animales',
          vigente: 'V',
          axo: 2024,
          costo: 3500.00,
          refrendo: 1750.00,
          clasificacion: 'MANUFACTURA',
          tipo_actividad: 'INDUSTRIAL'
        },
        {
          id_giro: 5003,
          cod_giro: 722511,
          descripcion: 'Servicios de preparación de alimentos a la carta o de comida corrida',
          vigente: 'V',
          axo: 2024,
          costo: 1800.00,
          refrendo: 900.00,
          clasificacion: 'HOSPEDAJE',
          tipo_actividad: 'SERVICIOS'
        },
        {
          id_giro: 5004,
          cod_giro: 541211,
          descripcion: 'Servicios de contabilidad, auditoría y teneduría de libros',
          vigente: 'V',
          axo: 2024,
          costo: 2200.00,
          refrendo: 1100.00,
          clasificacion: 'PROFESIONALES',
          tipo_actividad: 'SERVICIOS'
        },
        {
          id_giro: 5005,
          cod_giro: 811121,
          descripcion: 'Reparación y mantenimiento de automóviles y camiones',
          vigente: 'V',
          axo: 2024,
          costo: 1500.00,
          refrendo: 750.00,
          clasificacion: 'OTROS_SERVICIOS',
          tipo_actividad: 'SERVICIOS'
        }
      ]

      // Filtrar por criterios actuales si existen
      let actividadesFiltradas = actividadesSimuladas

      if (this.scian) {
        actividadesFiltradas = actividadesFiltradas.filter(act =>
          act.cod_giro.toString().includes(this.scian.toString())
        )
      }

      if (this.filtroDescripcion && this.filtroDescripcion.trim()) {
        actividadesFiltradas = actividadesFiltradas.filter(act =>
          act.descripcion.toLowerCase().includes(this.filtroDescripcion.toLowerCase())
        )
      }

      if (this.clasificacion) {
        actividadesFiltradas = actividadesFiltradas.filter(act =>
          act.clasificacion === this.clasificacion
        )
      }

      this.actividades = actividadesFiltradas
      this.totalRegistros = actividadesFiltradas.length
      this.primeraBusqueda = false

      this.showAlert(`Datos simulados generados: ${this.totalRegistros} actividades`, 'info')
    }
  },
  
  beforeUnmount() {
    // Limpiar timer si existe
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }
}
</script>

<style scoped>
.table th {
  border-top: none;
  font-weight: 500;
}

.card-header {
  font-weight: 500;
}

.badge {
  font-size: 0.75rem;
}

.btn:disabled {
  opacity: 0.65;
}

.alert {
  margin-top: 1rem;
}

.form-select:focus,
.form-control:focus {
  border-color: #86b7fe;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 0, 0, 0.075);
}

.table-primary {
  --bs-table-accent-bg: var(--bs-primary-bg-subtle);
  border-color: var(--bs-primary-border-subtle);
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}

.table-responsive {
  max-height: 500px;
  overflow-y: auto;
}

.gap-2 {
  gap: 0.5rem;
}

.text-decoration-none:hover {
  text-decoration: underline !important;
}

.badge {
  font-size: 0.7rem;
  font-weight: 500;
}

.btn-warning {
  background-color: #ffc107;
  border-color: #ffc107;
  color: #000;
}

.btn-warning:hover {
  background-color: #ffca2c;
  border-color: #ffc720;
  color: #000;
}

.municipal-controls .btn-group .btn {
  border-radius: 0;
}

.municipal-controls .btn-group .btn:first-child {
  border-top-left-radius: 0.25rem;
  border-bottom-left-radius: 0.25rem;
}

.municipal-controls .btn-group .btn:last-child {
  border-top-right-radius: 0.25rem;
  border-bottom-right-radius: 0.25rem;
}
</style>
