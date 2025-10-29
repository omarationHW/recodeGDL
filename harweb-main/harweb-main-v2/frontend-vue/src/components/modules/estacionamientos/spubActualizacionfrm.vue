<template>
  <div class="container-fluid mt-4">
    <div class="alert alert-info" role="alert">
      <h4 class="alert-heading">🅿️ Actualización de Estacionamientos Públicos</h4>
      <p>Sistema para la actualización de información de estacionamientos públicos municipales.</p>
      <hr>
      <p class="mb-0">
        <small><strong>Módulo:</strong> Estacionamientos | <strong>Componente:</strong> spubActualizacionfrm</small>
      </p>
    </div>
    
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Actualización de Estacionamiento Público</h5>
      </div>
      <div class="card-body">
        <!-- Formulario de búsqueda -->
        <div v-if="!estacionamiento" class="search-section">
          <h6 class="mb-3">Buscar Estacionamiento</h6>
          <form @submit.prevent="buscarEstacionamiento" class="row g-3">
            <div class="col-md-4">
              <label for="searchNumber" class="form-label">Número de Estacionamiento:</label>
              <input 
                v-model="numeroSearch" 
                type="number" 
                class="form-control" 
                id="searchNumber"
                placeholder="Ej: 001"
                required
              >
            </div>
            <div class="col-md-4">
              <label for="searchLicense" class="form-label">Número de Licencia:</label>
              <input 
                v-model="licenciaSearch" 
                type="text" 
                class="form-control" 
                id="searchLicense"
                placeholder="Ej: LIC-2024-001"
              >
            </div>
            <div class="col-md-4 d-flex align-items-end">
              <button type="submit" class="btn btn-primary" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="bi bi-search me-2"></i>
                Buscar
              </button>
            </div>
          </form>
          
          <div v-if="error" class="alert alert-danger mt-3">
            {{ error }}
          </div>
        </div>
        
        <!-- Formulario de actualización -->
        <div v-if="estacionamiento" class="update-section">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Actualizar Información</h6>
            <button class="btn btn-secondary btn-sm" @click="limpiarFormulario">
              <i class="bi bi-arrow-left me-1"></i> Nueva Búsqueda
            </button>
          </div>
          
          <form @submit.prevent="actualizarEstacionamiento">
            <div class="row g-3">
              <div class="col-md-6">
                <label for="numero" class="form-label">Número de Estacionamiento:</label>
                <input 
                  v-model="estacionamiento.numero" 
                  type="text" 
                  class="form-control" 
                  id="numero"
                  readonly
                >
              </div>
              <div class="col-md-6">
                <label for="licencia" class="form-label">Número de Licencia:</label>
                <input 
                  v-model="estacionamiento.licencia" 
                  type="text" 
                  class="form-control" 
                  id="licencia"
                >
              </div>
              
              <div class="col-md-6">
                <label for="nombre" class="form-label">Nombre del Estacionamiento:</label>
                <input 
                  v-model="estacionamiento.nombre" 
                  type="text" 
                  class="form-control" 
                  id="nombre"
                  required
                >
              </div>
              <div class="col-md-3">
                <label for="cajones" class="form-label">Número de Cajones:</label>
                <input 
                  v-model="estacionamiento.cajones" 
                  type="number" 
                  class="form-control" 
                  id="cajones"
                  min="1"
                  required
                >
              </div>
              <div class="col-md-3">
                <label for="categoria" class="form-label">Categoría:</label>
                <select v-model="estacionamiento.categoria" class="form-select" id="categoria" required>
                  <option value="">Seleccionar...</option>
                  <option value="Público">Público</option>
                  <option value="Privado">Privado</option>
                  <option value="Mixto">Mixto</option>
                </select>
              </div>
              
              <div class="col-md-6">
                <label for="calle" class="form-label">Calle:</label>
                <input 
                  v-model="estacionamiento.calle" 
                  type="text" 
                  class="form-control" 
                  id="calle"
                  required
                >
              </div>
              <div class="col-md-3">
                <label for="numext" class="form-label">Número Exterior:</label>
                <input 
                  v-model="estacionamiento.numext" 
                  type="text" 
                  class="form-control" 
                  id="numext"
                >
              </div>
              <div class="col-md-3">
                <label for="numint" class="form-label">Número Interior:</label>
                <input 
                  v-model="estacionamiento.numint" 
                  type="text" 
                  class="form-control" 
                  id="numint"
                >
              </div>
              
              <div class="col-md-4">
                <label for="sector" class="form-label">Sector:</label>
                <input 
                  v-model="estacionamiento.sector" 
                  type="text" 
                  class="form-control" 
                  id="sector"
                >
              </div>
              <div class="col-md-4">
                <label for="zona" class="form-label">Zona:</label>
                <input 
                  v-model="estacionamiento.zona" 
                  type="text" 
                  class="form-control" 
                  id="zona"
                >
              </div>
              <div class="col-md-4">
                <label for="subzona" class="form-label">Subzona:</label>
                <input 
                  v-model="estacionamiento.subzona" 
                  type="text" 
                  class="form-control" 
                  id="subzona"
                >
              </div>
              
              <div class="col-md-6">
                <label for="telefono" class="form-label">Teléfono:</label>
                <input 
                  v-model="estacionamiento.telefono" 
                  type="tel" 
                  class="form-control" 
                  id="telefono"
                >
              </div>
              <div class="col-md-6">
                <label for="cvepredial" class="form-label">Clave Predial:</label>
                <input 
                  v-model="estacionamiento.cvepredial" 
                  type="text" 
                  class="form-control" 
                  id="cvepredial"
                >
              </div>
              
              <div class="col-md-6">
                <label for="fechainicial" class="form-label">Fecha Inicial:</label>
                <input 
                  v-model="estacionamiento.fechainicial" 
                  type="date" 
                  class="form-control" 
                  id="fechainicial"
                >
              </div>
              <div class="col-md-6">
                <label for="fechavencimiento" class="form-label">Fecha de Vencimiento:</label>
                <input 
                  v-model="estacionamiento.fechavencimiento" 
                  type="date" 
                  class="form-control" 
                  id="fechavencimiento"
                >
              </div>
              
              <div class="col-12">
                <label for="observaciones" class="form-label">Observaciones:</label>
                <textarea 
                  v-model="estacionamiento.observaciones" 
                  class="form-control" 
                  id="observaciones"
                  rows="3"
                  placeholder="Observaciones adicionales..."
                ></textarea>
              </div>
            </div>
            
            <div class="d-flex justify-content-end mt-4">
              <button type="button" class="btn btn-secondary me-2" @click="limpiarFormulario">
                Cancelar
              </button>
              <button type="submit" class="btn btn-primary" :disabled="updating">
                <span v-if="updating" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="bi bi-check-lg me-2"></i>
                Actualizar
              </button>
            </div>
          </form>
          
          <div v-if="successMessage" class="alert alert-success mt-3">
            {{ successMessage }}
          </div>
          <div v-if="updateError" class="alert alert-danger mt-3">
            {{ updateError }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'spubActualizacionfrm',
  data() {
    return {
      numeroSearch: '',
      licenciaSearch: '',
      estacionamiento: null,
      loading: false,
      updating: false,
      error: '',
      updateError: '',
      successMessage: ''
    }
  },
  methods: {
    async buscarEstacionamiento() {
      if (!this.numeroSearch && !this.licenciaSearch) {
        this.error = 'Debe ingresar al menos un criterio de búsqueda'
        return
      }
      
      this.loading = true
      this.error = ''
      
      try {
        // Simular búsqueda
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        // En una implementación real, aquí haríamos la llamada al API
        this.estacionamiento = {
          numero: this.numeroSearch || 'EST001',
          licencia: this.licenciaSearch || 'LIC-2024-001',
          nombre: 'Estacionamiento Centro',
          cajones: 50,
          categoria: 'Público',
          calle: 'Av. Hidalgo',
          numext: '123',
          numint: '',
          sector: 'Centro',
          zona: 'Centro',
          subzona: 'A',
          telefono: '33-1234-5678',
          cvepredial: 'PRED-2024-001',
          fechainicial: '2024-01-01',
          fechavencimiento: '2024-12-31',
          observaciones: 'Estacionamiento en zona centro'
        }
        
        console.log('Estacionamiento encontrado:', this.estacionamiento)
      } catch (error) {
        this.error = 'Error al buscar el estacionamiento'
        console.error('Error:', error)
      } finally {
        this.loading = false
      }
    },
    
    async actualizarEstacionamiento() {
      this.updating = true
      this.updateError = ''
      this.successMessage = ''
      
      try {
        // Simular actualización
        await new Promise(resolve => setTimeout(resolve, 1500))
        
        // En una implementación real, aquí haríamos la llamada al API
        console.log('Actualizando estacionamiento:', this.estacionamiento)
        
        this.successMessage = 'Estacionamiento actualizado exitosamente'
        
        // Limpiar formulario después de 3 segundos
        setTimeout(() => {
          this.limpiarFormulario()
        }, 3000)
        
      } catch (error) {
        this.updateError = 'Error al actualizar el estacionamiento'
        console.error('Error:', error)
      } finally {
        this.updating = false
      }
    },
    
    limpiarFormulario() {
      this.numeroSearch = ''
      this.licenciaSearch = ''
      this.estacionamiento = null
      this.error = ''
      this.updateError = ''
      this.successMessage = ''
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

.search-section, .update-section {
  min-height: 200px;
}

.form-label {
  font-weight: 600;
  color: #495057;
}

.btn {
  font-weight: 500;
}

.spinner-border-sm {
  width: 0.875rem;
  height: 0.875rem;
}
</style>