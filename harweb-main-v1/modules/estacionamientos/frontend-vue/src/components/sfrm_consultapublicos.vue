<template>
  <div class="container-fluid mt-4">
    <div class="alert alert-info" role="alert">
      <h4 class="alert-heading">🅿️ Sistema de Consulta Públicos</h4>
      <p>Consulta de información de estacionamientos públicos del sistema municipal.</p>
      <hr>
      <p class="mb-0">
        <small><strong>Módulo:</strong> Estacionamientos | <strong>Componente:</strong> sfrm_consultapublicos</small>
      </p>
    </div>
    
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Consulta de Estacionamientos Públicos</h5>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="sr-only">Cargando...</span>
          </div>
          <p class="mt-2">Cargando información de estacionamientos públicos...</p>
        </div>
        
        <div v-else-if="error" class="alert alert-danger">
          {{ error }}
        </div>
        
        <div v-else>
          <!-- Filtros de búsqueda -->
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="filterName" class="form-label">Filtrar por nombre:</label>
              <input 
                type="text" 
                id="filterName" 
                class="form-control" 
                v-model="filterName" 
                placeholder="Nombre del estacionamiento"
              >
            </div>
            <div class="col-md-3">
              <label for="filterZone" class="form-label">Zona:</label>
              <select id="filterZone" class="form-select" v-model="filterZone">
                <option value="">Todas las zonas</option>
                <option v-for="zone in availableZones" :key="zone" :value="zone">
                  {{ zone }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label for="filterStatus" class="form-label">Estado:</label>
              <select id="filterStatus" class="form-select" v-model="filterStatus">
                <option value="">Todos</option>
                <option value="activo">Activo</option>
                <option value="vencido">Vencido</option>
              </select>
            </div>
            <div class="col-md-2 d-flex align-items-end">
              <button class="btn btn-primary" @click="fetchParkings">
                <i class="bi bi-search"></i> Buscar
              </button>
            </div>
          </div>
          
          <!-- Tabla de resultados -->
          <div class="table-responsive">
            <table class="table table-striped table-hover">
              <thead class="table-dark">
                <tr>
                  <th>Número</th>
                  <th>Cajones</th>
                  <th>Categoría</th>
                  <th>Nombre</th>
                  <th>Dirección</th>
                  <th>Zona</th>
                  <th>Licencia</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="parking in filteredParkings" :key="parking.id">
                  <td>{{ parking.numero || 'N/A' }}</td>
                  <td>{{ parking.cajones || '0' }}</td>
                  <td>{{ parking.categoria || 'Sin categoría' }}</td>
                  <td>{{ parking.nombre || 'Sin nombre' }}</td>
                  <td>{{ parking.direccion || 'Sin dirección' }}</td>
                  <td>{{ parking.zona || 'Sin zona' }}</td>
                  <td>{{ parking.licencia || 'Sin licencia' }}</td>
                  <td>
                    <span :class="getStatusClass(parking.estado)">
                      {{ parking.estado || 'Desconocido' }}
                    </span>
                  </td>
                  <td>
                    <div class="btn-group btn-group-sm">
                      <button 
                        class="btn btn-outline-primary" 
                        @click="viewDetails(parking)"
                        title="Ver detalles"
                      >
                        <i class="bi bi-eye"></i>
                      </button>
                      <button 
                        class="btn btn-outline-secondary" 
                        @click="viewDebts(parking)"
                        title="Ver adeudos"
                      >
                        <i class="bi bi-currency-dollar"></i>
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="filteredParkings.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    No se encontraron estacionamientos públicos
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'sfrm_consultapublicos',
  data() {
    return {
      parkings: [],
      loading: false,
      error: '',
      filterName: '',
      filterZone: '',
      filterStatus: ''
    }
  },
  computed: {
    availableZones() {
      const zones = [...new Set(this.parkings.map(p => p.zona).filter(z => z))]
      return zones.sort()
    },
    filteredParkings() {
      return this.parkings.filter(parking => {
        const matchesName = !this.filterName || 
          (parking.nombre && parking.nombre.toLowerCase().includes(this.filterName.toLowerCase()))
        const matchesZone = !this.filterZone || parking.zona === this.filterZone
        const matchesStatus = !this.filterStatus || parking.estado === this.filterStatus
        
        return matchesName && matchesZone && matchesStatus
      })
    }
  },
  mounted() {
    this.fetchParkings()
  },
  methods: {
    async fetchParkings() {
      this.loading = true
      this.error = ''
      
      try {
        // Simular datos para demostración
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        // En una implementación real, aquí haríamos la llamada al API
        this.parkings = [
          {
            id: 1,
            numero: 'EST001',
            cajones: 50,
            categoria: 'Público',
            nombre: 'Estacionamiento Centro',
            direccion: 'Av. Hidalgo 123',
            zona: 'Centro',
            licencia: 'LIC-2024-001',
            estado: 'activo'
          },
          {
            id: 2,
            numero: 'EST002',
            cajones: 30,
            categoria: 'Público',
            nombre: 'Estacionamiento Plaza',
            direccion: 'Calle Morelos 456',
            zona: 'Centro',
            licencia: 'LIC-2023-002',
            estado: 'vencido'
          }
        ]
        
        console.log('Componente sfrm_consultapublicos cargado con datos de demostración')
      } catch (error) {
        this.error = 'Error al cargar los datos de estacionamientos públicos'
        console.error('Error:', error)
      } finally {
        this.loading = false
      }
    },
    
    getStatusClass(status) {
      switch(status) {
        case 'activo': return 'badge bg-success'
        case 'vencido': return 'badge bg-danger'
        case 'suspendido': return 'badge bg-warning'
        default: return 'badge bg-secondary'
      }
    },
    
    viewDetails(parking) {
      console.log('Ver detalles de:', parking)
      // Aquí se podría abrir un modal o navegar a una página de detalles
    },
    
    viewDebts(parking) {
      console.log('Ver adeudos de:', parking)
      // Aquí se podría abrir un modal o navegar a una página de adeudos
    }
  }
}
</script>

<style scoped>
.alert-heading {
  color: #0c5460;
}

.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.table th {
  font-weight: 600;
  font-size: 0.9rem;
}

.btn-group-sm .btn {
  padding: 0.25rem 0.5rem;
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}
</style>