<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Baja de Anuncio</li>
      </ol>
    </nav>
    
    <h2 class="mb-4 text-center">BAJA DE ANUNCIO</h2>
    
    <!-- Formulario de Búsqueda -->
    <form @submit.prevent="buscarAnuncio" class="row mb-4">
      <div class="col-md-6 offset-md-3">
        <div class="input-group">
          <span class="input-group-text">No. Anuncio</span>
          <input 
            type="number" 
            v-model="filtros.anuncio" 
            class="form-control" 
            placeholder="Número de anuncio"
            required 
            autofocus 
          />
          <button type="submit" class="btn btn-primary" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
            Buscar
          </button>
        </div>
      </div>
    </form>

    <!-- Loading y Error -->
    <div v-if="loading" class="text-center my-4">
      <div class="spinner-border"></div>
      <p class="mt-2">Cargando datos del anuncio...</p>
    </div>
    
    <div v-if="error" class="alert alert-danger">
      <i class="bi bi-exclamation-triangle"></i>
      {{ error }}
    </div>

    <!-- Información del Anuncio -->
    <div v-if="anuncioData && !loading" class="card">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-signpost"></i>
          Información del Anuncio #{{ anuncioData.id_anuncio }}
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <table class="table table-borderless table-sm">
              <tbody>
                <tr>
                  <th class="text-muted">Licencia de referencia:</th>
                  <td>{{ anuncioData.id_licencia }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Fecha de otorgamiento:</th>
                  <td>{{ formatDate(anuncioData.fecha_otorgamiento) }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Texto del anuncio:</th>
                  <td>{{ anuncioData.texto_anuncio || 'No especificado' }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Medidas:</th>
                  <td>{{ anuncioData.medidas1 }} x {{ anuncioData.medidas2 }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Área:</th>
                  <td>{{ anuncioData.area_anuncio }} m²</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="col-md-6">
            <table class="table table-borderless table-sm">
              <tbody>
                <tr>
                  <th class="text-muted">Ubicación:</th>
                  <td>{{ anuncioData.ubicacion }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Dirección:</th>
                  <td>
                    Ext: {{ anuncioData.numext_ubic }}{{ anuncioData.letraext_ubic ? '-' + anuncioData.letraext_ubic : '' }}
                    <span v-if="anuncioData.numint_ubic">
                      / Int: {{ anuncioData.numint_ubic }}{{ anuncioData.letraint_ubic ? '-' + anuncioData.letraint_ubic : '' }}
                    </span>
                  </td>
                </tr>
                <tr>
                  <th class="text-muted">Colonia:</th>
                  <td>{{ anuncioData.colonia_ubic || 'No registrada' }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Base impuesto:</th>
                  <td>{{ anuncioData.base_impuesto || '$0.00' }}</td>
                </tr>
                <tr>
                  <th class="text-muted">Estado:</th>
                  <td>
                    <span class="badge" :class="anuncioData.vigente === 'V' ? 'bg-success' : 'bg-danger'">
                      {{ anuncioData.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Adeudos -->
        <div v-if="anuncioData.adeudos && anuncioData.adeudos.length > 0" class="mt-4">
          <div class="alert alert-danger">
            <i class="bi bi-exclamation-triangle"></i>
            <strong>El anuncio cuenta con adeudos, no se podrá dar de baja.</strong>
          </div>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead class="table-dark">
                <tr>
                  <th>Año</th>
                  <th>Saldo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in anuncioData.adeudos" :key="adeudo.axo">
                  <td>{{ adeudo.axo }}</td>
                  <td class="text-end">{{ formatCurrency(adeudo.saldo) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Estado del Anuncio -->
        <div v-if="anuncioData.vigente !== 'V'" class="alert alert-warning mt-4">
          <i class="bi bi-info-circle"></i>
          El anuncio ya se encuentra cancelado.
        </div>

        <!-- Formulario de Baja -->
        <div v-if="anuncioData.vigente === 'V' && (!anuncioData.adeudos || anuncioData.adeudos.length === 0)" class="mt-4">
          <div class="card">
            <div class="card-header bg-warning">
              <h6 class="mb-0">
                <i class="bi bi-exclamation-triangle"></i>
                Procesar Baja de Anuncio
              </h6>
            </div>
            <div class="card-body">
              <form @submit.prevent="procesarBaja">
                <div class="row">
                  <div class="col-md-12 mb-3">
                    <label for="motivo" class="form-label">Motivo de la baja:</label>
                    <input 
                      type="text" 
                      v-model="formBaja.motivo" 
                      id="motivo" 
                      class="form-control"
                      placeholder="Descripción del motivo"
                      required
                    />
                  </div>
                </div>
                
                <div class="row mb-3">
                  <div class="col-md-6">
                    <div class="form-check">
                      <input 
                        type="checkbox" 
                        v-model="formBaja.baja_error" 
                        id="baja_error" 
                        class="form-check-input"
                        @change="formBaja.baja_tiempo = false"
                      />
                      <label for="baja_error" class="form-check-label">Baja por error</label>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-check">
                      <input 
                        type="checkbox" 
                        v-model="formBaja.baja_tiempo" 
                        id="baja_tiempo" 
                        class="form-check-input"
                        @change="formBaja.baja_error = false"
                      />
                      <label for="baja_tiempo" class="form-check-label">Baja en tiempo</label>
                    </div>
                  </div>
                </div>

                <div v-if="!formBaja.baja_error && !formBaja.baja_tiempo" class="row mb-3">
                  <div class="col-md-6">
                    <label for="axo_baja" class="form-label">Año de baja:</label>
                    <input 
                      type="number" 
                      v-model="formBaja.axo_baja" 
                      id="axo_baja" 
                      class="form-control"
                      required
                    />
                  </div>
                  <div class="col-md-6">
                    <label for="folio_baja" class="form-label">Folio de baja:</label>
                    <input 
                      type="number" 
                      v-model="formBaja.folio_baja" 
                      id="folio_baja" 
                      class="form-control"
                      required
                    />
                  </div>
                </div>

                <div class="d-grid">
                  <button 
                    type="submit" 
                    class="btn btn-danger" 
                    :disabled="procesandoBaja"
                  >
                    <span v-if="procesandoBaja" class="spinner-border spinner-border-sm me-2"></span>
                    <i class="bi bi-trash"></i>
                    Dar de Baja Anuncio
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Resultado de Baja -->
        <div v-if="resultadoBaja" class="mt-4">
          <div v-if="resultadoBaja.success" class="alert alert-success">
            <i class="bi bi-check-circle"></i>
            <strong>Baja realizada correctamente.</strong>
            <p class="mb-0 mt-2">{{ resultadoBaja.message }}</p>
          </div>
          <div v-else class="alert alert-danger">
            <i class="bi bi-x-circle"></i>
            <strong>Error al procesar la baja:</strong>
            <p class="mb-0 mt-2">{{ resultadoBaja.message }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Mensaje sin resultados -->
    <div v-if="!anuncioData && !loading && hasSearched" class="alert alert-warning">
      <i class="bi bi-search"></i>
      No se encontró información para el anuncio {{ filtros.anuncio }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'BajaAnuncioFrm',
  data() {
    return {
      loading: false,
      error: '',
      anuncioData: null,
      resultadoBaja: null,
      procesandoBaja: false,
      hasSearched: false,
      
      filtros: {
        anuncio: ''
      },

      formBaja: {
        motivo: '',
        axo_baja: new Date().getFullYear(),
        folio_baja: '',
        baja_error: false,
        baja_tiempo: false
      }
    }
  },
  
  methods: {

    async buscarAnuncio() {
      if (!this.filtros.anuncio) {
        this.error = 'Ingrese el número de anuncio'
        return
      }

      this.loading = true
      this.error = ''
      this.anuncioData = null
      this.resultadoBaja = null
      this.hasSearched = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_baja_anuncio_buscar',
              Base: 'padron_licencias',
              Parametros: [
                {
                  nombre: 'p_anuncio',
                  valor: parseInt(this.filtros.anuncio),
                  tipo: 'integer'
                }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result && data.eResponse.data.result.length > 0) {
          this.anuncioData = data.eResponse.data.result[0]

          // Parsear adeudos si vienen como JSON string
          if (this.anuncioData.adeudos && typeof this.anuncioData.adeudos === 'string') {
            try {
              this.anuncioData.adeudos = JSON.parse(this.anuncioData.adeudos)
            } catch (e) {
              this.anuncioData.adeudos = []
            }
          }
        } else {
          this.error = 'No se encontró el anuncio especificado'
        }
      } catch (e) {
        console.error('Error al buscar anuncio:', e)
        this.error = 'Error al consultar el anuncio: ' + (e.message || 'Error desconocido')
      } finally {
        this.loading = false
      }
    },

    async procesarBaja() {
      if (!this.formBaja.motivo.trim()) {
        this.error = 'Debe especificar un motivo para la baja'
        return
      }

      this.procesandoBaja = true
      this.error = ''
      this.resultadoBaja = null

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_baja_anuncio_procesar',
              Base: 'padron_licencias',
              Parametros: [
                {
                  nombre: 'p_anuncio',
                  valor: parseInt(this.filtros.anuncio),
                  tipo: 'integer'
                },
                {
                  nombre: 'p_motivo',
                  valor: this.formBaja.motivo,
                  tipo: 'string'
                },
                {
                  nombre: 'p_axo_baja',
                  valor: this.formBaja.baja_error || this.formBaja.baja_tiempo ? null : parseInt(this.formBaja.axo_baja),
                  tipo: 'integer'
                },
                {
                  nombre: 'p_folio_baja',
                  valor: this.formBaja.baja_error || this.formBaja.baja_tiempo ? null : parseInt(this.formBaja.folio_baja),
                  tipo: 'integer'
                },
                {
                  nombre: 'p_fecha_baja',
                  valor: new Date().toISOString().split('T')[0],
                  tipo: 'date'
                }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result) {
          const result = data.eResponse.data.result[0]
          this.resultadoBaja = {
            success: result.success || false,
            message: result.message || 'Operación completada'
          }

          if (result.success) {
            // Refrescar datos del anuncio
            setTimeout(() => {
              this.buscarAnuncio()
            }, 1000)
          }
        } else {
          this.resultadoBaja = {
            success: false,
            message: 'Error al procesar la baja del anuncio'
          }
        }
      } catch (e) {
        console.error('Error al procesar baja:', e)
        this.resultadoBaja = {
          success: false,
          message: 'Error al procesar la baja: ' + (e.message || 'Error desconocido')
        }
      } finally {
        this.procesandoBaja = false
      }
    },

    formatDate(dateString) {
      if (!dateString) return ''
      try {
        return new Date(dateString).toLocaleDateString('es-MX')
      } catch {
        return dateString
      }
    },

    formatCurrency(amount) {
      if (!amount) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(amount)
    }
  }
}
</script>

<style scoped>
.baja-anuncio-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.info-block {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}
.alert {
  margin: 1rem 0;
}
.form-group, .form-row {
  margin-bottom: 1rem;
}
</style>
