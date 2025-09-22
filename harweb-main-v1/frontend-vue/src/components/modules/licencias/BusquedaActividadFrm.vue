<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-search me-2 text-primary"></i>
              Búsqueda de Actividades
            </h2>
            <p class="text-muted mb-0">Sistema de búsqueda y consulta de actividades comerciales</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Búsqueda Actividades</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-filter me-2"></i>
          Filtros de Búsqueda
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label for="filtroGiro" class="form-label">Giro (ID)</label>
            <select 
              class="form-select" 
              id="filtroGiro"
              v-model="filtroIdGiro"
              @change="buscarActividades"
            >
              <option value="">Todos los giros</option>
              <option 
                v-for="giro in girosDisponibles" 
                :key="giro.id_giro" 
                :value="giro.id_giro"
              >
                {{ giro.descripcion_giro }} ({{ giro.total_en_licencias }}L / {{ giro.total_en_tramites }}T)
              </option>
            </select>
          </div>
          <div class="col-md-6">
            <label for="filtroDescripcion" class="form-label">Descripción de Actividad</label>
            <input
              type="text"
              class="form-control"
              id="filtroDescripcion"
              v-model="filtroDescripcion"
              @input="debounceSearch"
              placeholder="Ingrese parte de la descripción de la actividad..."
              maxlength="100"
            >
          </div>
          <div class="col-md-2">
            <label for="filtroFuente" class="form-label">Fuente</label>
            <select 
              class="form-select" 
              id="filtroFuente"
              v-model="filtroFuente"
              @change="buscarActividades"
            >
              <option value="AMBOS">Ambos</option>
              <option value="LICENCIAS">Licencias</option>
              <option value="TRAMITES">Trámites</option>
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
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Resultados de Búsqueda
        </h5>
        <span class="badge bg-secondary">{{ actividades.length }} resultado(s)</span>
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
        
        <div v-else class="table-responsive">
          <table class="table table-striped table-hover">
            <thead class="table-dark">
              <tr>
                <th>ID Giro</th>
                <th>Actividad</th>
                <th>Fuente</th>
                <th class="text-center">Total</th>
                <th class="text-center">Activos</th>
                <th class="text-center">Bloqueados</th>
                <th class="text-center">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr 
                v-for="actividad in actividades" 
                :key="`${actividad.id_giro}-${actividad.fuente}-${actividad.actividad}`"
                :class="{'table-primary': actividad === actividadSeleccionada}"
                style="cursor: pointer;"
                @click="seleccionarActividad(actividad)"
              >
                <td>{{ actividad.id_giro || 'N/A' }}</td>
                <td>{{ actividad.actividad }}</td>
                <td>
                  <span :class="`badge ${getFuenteClass(actividad.fuente)}`">
                    {{ actividad.fuente }}
                  </span>
                </td>
                <td class="text-center">{{ actividad.total_registros }}</td>
                <td class="text-center">{{ actividad.registros_activos }}</td>
                <td class="text-center">
                  <span :class="`badge ${actividad.registros_bloqueados > 0 ? 'bg-danger' : 'bg-success'}`">
                    {{ actividad.registros_bloqueados }}
                  </span>
                </td>
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
          <div class="col-md-8">
            <div class="mb-2">
              <strong>ID Giro:</strong> {{ actividadSeleccionada.id_giro || 'N/A' }}
            </div>
            <div class="mb-2">
              <strong>Descripción:</strong> {{ actividadSeleccionada.actividad }}
            </div>
            <div class="mb-2">
              <strong>Fuente:</strong> 
              <span :class="`badge ${getFuenteClass(actividadSeleccionada.fuente)} ms-2`">
                {{ actividadSeleccionada.fuente }}
              </span>
            </div>
          </div>
          <div class="col-md-4">
            <div class="mb-2">
              <strong>Total registros:</strong> {{ actividadSeleccionada.total_registros }}
            </div>
            <div class="mb-2">
              <strong>Activos:</strong> {{ actividadSeleccionada.registros_activos }}
            </div>
            <div class="mb-2">
              <strong>Bloqueados:</strong> {{ actividadSeleccionada.registros_bloqueados }}
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
</template>

<script>
import { eRequest } from '../../../services/api'

export default {
  name: 'BusquedaActividadFrm',
  data() {
    return {
      // Filtros de búsqueda
      filtroIdGiro: '',
      filtroDescripcion: '',
      filtroFuente: 'AMBOS',
      
      // Datos
      actividades: [],
      girosDisponibles: [],
      actividadSeleccionada: null,
      
      // Estados de UI
      buscando: false,
      primeraBusqueda: true,
      debounceTimer: null,
      
      // Alertas
      alertMessage: '',
      alertType: 'info'
    }
  },
  
  async mounted() {
    await this.cargarGirosDisponibles()
    // Si hay parámetros de query, realizar búsqueda inicial
    if (this.$route.query.id_giro || this.$route.query.descripcion) {
      this.filtroIdGiro = this.$route.query.id_giro || ''
      this.filtroDescripcion = this.$route.query.descripcion || ''
      this.buscarActividades()
    }
  },
  
  methods: {
    async cargarGirosDisponibles() {
      try {
        const response = await eRequest('sp_obtener_giros_disponibles', {})
        if (response.success && response.data) {
          this.girosDisponibles = response.data
        }
      } catch (error) {
        console.error('Error cargando giros disponibles:', error)
        this.showAlert('Error cargando catálogo de giros', 'danger')
      }
    },
    
    async buscarActividades() {
      this.buscando = true
      this.primeraBusqueda = false
      this.clearAlert()
      
      try {
        const params = {}
        
        if (this.filtroIdGiro) {
          params.p_id_giro = parseInt(this.filtroIdGiro)
        }
        
        if (this.filtroDescripcion && this.filtroDescripcion.trim()) {
          params.p_descripcion = this.filtroDescripcion.trim()
        }
        
        if (this.filtroFuente) {
          params.p_fuente = this.filtroFuente
        }
        
        const response = await eRequest('sp_buscar_actividades_combinado', params)
        
        if (response.success && response.data) {
          this.actividades = response.data
          
          if (this.actividades.length === 0) {
            this.showAlert('No se encontraron actividades con los criterios especificados', 'info')
          } else {
            this.showAlert(`Se encontraron ${this.actividades.length} actividade(s)`, 'success')
          }
        } else {
          this.actividades = []
          this.showAlert(response.message || 'Error al buscar actividades', 'danger')
        }
      } catch (error) {
        console.error('Error buscando actividades:', error)
        this.showAlert('Error al realizar la búsqueda', 'danger')
        this.actividades = []
      } finally {
        this.buscando = false
      }
    },
    
    debounceSearch() {
      // Limpiar timer anterior
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer)
      }
      
      // Establecer nuevo timer
      this.debounceTimer = setTimeout(() => {
        this.buscarActividades()
      }, 500) // Buscar después de 500ms de inactividad
    },
    
    limpiarFiltros() {
      this.filtroIdGiro = ''
      this.filtroDescripcion = ''
      this.filtroFuente = 'AMBOS'
      this.actividades = []
      this.actividadSeleccionada = null
      this.primeraBusqueda = true
      this.clearAlert()
    },
    
    seleccionarActividad(actividad) {
      this.actividadSeleccionada = actividad
      this.showAlert(`Actividad seleccionada: ${actividad.actividad}`, 'info')
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
        `Actividad confirmada: ${this.actividadSeleccionada.actividad}`, 
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
    
    verDetalleActividad(actividad) {
      // Mostrar más información sobre la actividad
      const detalles = [
        `ID Giro: ${actividad.id_giro || 'N/A'}`,
        `Actividad: ${actividad.actividad}`,
        `Fuente: ${actividad.fuente}`,
        `Total registros: ${actividad.total_registros}`,
        `Activos: ${actividad.registros_activos}`,
        `Bloqueados: ${actividad.registros_bloqueados}`
      ].join('\n')
      
      alert(`Detalle de Actividad:\n\n${detalles}`)
      
      // Alternativamente, abrir un modal con más información
      // this.$modal.show('actividad-detalle-modal', { actividad })
    },
    
    getFuenteClass(fuente) {
      switch (fuente) {
        case 'LICENCIAS':
          return 'bg-primary'
        case 'TRAMITES':
          return 'bg-info'
        default:
          return 'bg-secondary'
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
</style>
