<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Baja de Licencia</li>
      </ol>
    </nav>

    <h2 class="mb-4 text-center">BAJA DE LICENCIA COMERCIAL</h2>

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-search"></i>
          Buscar Licencia
        </h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscarLicencia" class="row g-3">
          <div class="col-md-8">
            <label for="licencia" class="form-label">Número de Licencia *</label>
            <input
              v-model="form.licencia"
              id="licencia"
              type="text"
              class="form-control"
              placeholder="Ingrese el número de licencia"
              required
              autofocus
            />
          </div>
          <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="btn btn-primary" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
              <i class="bi bi-search"></i>
              Buscar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading y Error -->
    <div v-if="loading" class="text-center my-4">
      <div class="spinner-border"></div>
      <p class="mt-2">Buscando licencia...</p>
    </div>

    <div v-if="error" class="alert alert-danger">
      <i class="bi bi-exclamation-triangle"></i>
      {{ error }}
    </div>

    <!-- Datos de la Licencia -->
    <div v-if="licencia && !loading" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-file-text"></i>
          Datos de Licencia #{{ licencia.numero_licencia }}
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <p><strong>Recaudadora:</strong> {{ licencia.recaudadora }}</p>
            <p><strong>Giro:</strong> {{ licencia.giro_descripcion }}</p>
            <p><strong>Actividad:</strong> {{ licencia.actividad }}</p>
            <p><strong>Propietario:</strong> {{ licencia.propietario_completo }}</p>
            <p><strong>Estado:</strong>
              <span :class="licencia.estado === 'A' ? 'badge bg-success' : 'badge bg-secondary'">
                {{ licencia.estado === 'A' ? 'Activa' : 'Inactiva' }}
              </span>
            </p>
          </div>
          <div class="col-md-6">
            <p><strong>Ubicación:</strong> {{ licencia.ubicacion_completa }}</p>
            <p><strong>Sup. construida:</strong> {{ licencia.superficie_construida }} m²</p>
            <p><strong>Sup. autorizada:</strong> {{ licencia.superficie_autorizada }} m²</p>
            <p><strong>Num. cajones:</strong> {{ licencia.num_cajones }}</p>
            <p><strong>Num. empleados:</strong> {{ licencia.num_empleados }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Adeudos -->
    <div v-if="adeudos && adeudos.length > 0 && !bajaError" class="card mb-4">
      <div class="card-header bg-warning">
        <h5 class="mb-0">
          <i class="bi bi-exclamation-triangle"></i>
          ¡PRECAUCIÓN! La licencia tiene adeudos
        </h5>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped">
            <thead>
              <tr>
                <th>Concepto</th>
                <th>Importe</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="adeudo in adeudos" :key="adeudo.concepto">
                <td>{{ adeudo.concepto }}</td>
                <td class="text-end">${{ adeudo.importe.toFixed(2) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="table-warning">
                <th>Total</th>
                <th class="text-end">${{ totalAdeudos.toFixed(2) }}</th>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Anuncios ligados -->
    <div v-if="anuncios && anuncios.length > 0" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-signpost"></i>
          Anuncios ligados a esta licencia ({{ anuncios.length }})
        </h5>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-hover table-sm">
            <thead class="table-dark">
              <tr>
                <th>No. Anuncio</th>
                <th>F. Otorgamiento</th>
                <th>Medidas</th>
                <th>Área</th>
                <th>Ubicación</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="anuncio in anuncios" :key="anuncio.id">
                <td>{{ anuncio.numero_anuncio }}</td>
                <td>{{ formatDate(anuncio.fecha_otorgamiento) }}</td>
                <td>{{ anuncio.medidas }}</td>
                <td>{{ anuncio.area_anuncio }} m²</td>
                <td>{{ anuncio.ubicacion_completa }}</td>
                <td>
                  <span :class="anuncio.estado === 'A' ? 'badge bg-success' : 'badge bg-secondary'">
                    {{ anuncio.estado === 'A' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Formulario de baja -->
    <div v-if="licencia && !loading" class="card">
      <div class="card-header bg-danger text-white">
        <h5 class="mb-0">
          <i class="bi bi-x-circle"></i>
          Procesar Baja de Licencia
        </h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="confirmarBaja">
          <div class="row mb-3">
            <div class="col-md-8">
              <label for="motivo" class="form-label">Motivo de la baja *</label>
              <textarea
                v-model="form.motivo"
                id="motivo"
                class="form-control"
                rows="3"
                placeholder="Describa el motivo de la baja de licencia"
                required
              ></textarea>
            </div>
            <div class="col-md-4">
              <label class="form-label">Opciones</label>
              <div class="form-check">
                <input v-model="bajaError" type="checkbox" class="form-check-input" id="bajaError">
                <label class="form-check-label" for="bajaError">
                  Baja por error administrativo
                </label>
              </div>
            </div>
          </div>

          <div v-if="!bajaError" class="row mb-3">
            <div class="col-md-6">
              <label for="anio" class="form-label">Año *</label>
              <input
                v-model.number="form.anio"
                id="anio"
                type="number"
                class="form-control"
                :min="2020"
                :max="new Date().getFullYear()"
                required
              />
            </div>
            <div class="col-md-6">
              <label for="folio" class="form-label">Folio *</label>
              <input
                v-model.number="form.folio"
                id="folio"
                type="number"
                class="form-control"
                min="1"
                required
              />
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-danger" :disabled="procesando">
              <span v-if="procesando" class="spinner-border spinner-border-sm me-2"></span>
              <i class="bi bi-x-circle"></i>
              Dar de Baja
            </button>
            <button type="button" class="btn btn-secondary" @click="limpiarFormulario">
              <i class="bi bi-arrow-counterclockwise"></i>
              Limpiar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Mensaje de resultado -->
    <div v-if="mensaje" :class="'alert mt-4 ' + (exito ? 'alert-success' : 'alert-danger')">
      <i :class="exito ? 'bi bi-check-circle' : 'bi bi-x-circle'"></i>
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'bajaLicenciafrm',
  data() {
    return {
      loading: false,
      error: '',
      procesando: false,
      form: {
        licencia: '',
        motivo: '',
        anio: new Date().getFullYear(),
        folio: ''
      },
      licencia: null,
      adeudos: [],
      anuncios: [],
      bajaError: false,
      mensaje: '',
      exito: false
    }
  },
  computed: {
    totalAdeudos() {
      return this.adeudos.reduce((total, adeudo) => total + (adeudo.importe || 0), 0)
    }
  },
  methods: {
    async buscarLicencia() {
      this.loading = true
      this.error = ''
      this.mensaje = ''
      this.licencia = null
      this.adeudos = []
      this.anuncios = []

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_licencia_buscar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_numero_licencia', valor: this.form.licencia, tipo: 'varchar' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result && data.eResponse.data.result.length > 0) {
          this.licencia = data.eResponse.data.result[0]
          await this.cargarAdeudos()
          await this.cargarAnuncios()
        } else {
          this.error = 'Licencia no encontrada'
        }
      } catch (e) {
        console.error('Error al buscar licencia:', e)
        this.error = 'Error al buscar la licencia: ' + (e.message || 'Error desconocido')
      } finally {
        this.loading = false
      }
    },

    async cargarAdeudos() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_licencia_adeudos',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_licencia', valor: this.licencia.id, tipo: 'integer' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result) {
          this.adeudos = data.eResponse.data.result
        }
      } catch (e) {
        console.error('Error al cargar adeudos:', e)
      }
    },

    async cargarAnuncios() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_licencia_anuncios',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_licencia', valor: this.licencia.id, tipo: 'integer' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result) {
          this.anuncios = data.eResponse.data.result
        }
      } catch (e) {
        console.error('Error al cargar anuncios:', e)
      }
    },

    async confirmarBaja() {
      this.procesando = true
      this.error = ''
      this.mensaje = ''

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_licencia_baja',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_licencia', valor: this.licencia.id, tipo: 'integer' },
                { nombre: 'p_motivo', valor: this.form.motivo, tipo: 'varchar' },
                { nombre: 'p_anio', valor: this.bajaError ? null : this.form.anio, tipo: 'integer' },
                { nombre: 'p_folio', valor: this.bajaError ? null : this.form.folio, tipo: 'integer' },
                { nombre: 'p_baja_error', valor: this.bajaError ? 'S' : 'N', tipo: 'varchar' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.exito = true
          this.mensaje = 'Licencia dada de baja exitosamente'
          this.limpiarFormulario()
        } else {
          this.exito = false
          this.mensaje = data.eResponse?.message || 'Error al procesar la baja'
        }
      } catch (e) {
        console.error('Error al confirmar baja:', e)
        this.exito = false
        this.mensaje = 'Error al procesar la baja: ' + (e.message || 'Error desconocido')
      } finally {
        this.procesando = false
      }
    },

    limpiarFormulario() {
      this.form = {
        licencia: '',
        motivo: '',
        anio: new Date().getFullYear(),
        folio: ''
      }
      this.licencia = null
      this.adeudos = []
      this.anuncios = []
      this.bajaError = false
      this.mensaje = ''
      this.error = ''
    },

    formatDate(dateString) {
      if (!dateString) return ''
      try {
        return new Date(dateString).toLocaleDateString('es-MX')
      } catch {
        return dateString
      }
    }
  }
}
</script>

<style scoped>
.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.table th {
  white-space: nowrap;
}

.table td {
  vertical-align: middle;
}

.form-label {
  font-weight: 600;
}

.bg-warning {
  background-color: #fff3cd !important;
}

.text-end {
  text-align: end;
}
</style>
