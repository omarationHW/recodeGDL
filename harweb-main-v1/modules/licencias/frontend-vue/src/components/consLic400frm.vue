<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Licencia 400</li>
      </ol>
    </nav>
    
    <h2 class="mb-4 text-center">CONSULTA DE LICENCIAS DEL AS/400</h2>
    
    <!-- Formulario de Búsqueda -->
    <form @submit.prevent="buscarLicencia" class="row mb-4">
      <div class="col-md-6 offset-md-3">
        <div class="input-group">
          <span class="input-group-text">Licencia</span>
          <input 
            type="number" 
            v-model="filtros.licencia" 
            class="form-control" 
            placeholder="Número de licencia"
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
      <p class="mt-2">Cargando datos de licencia...</p>
    </div>
    
    <div v-if="error" class="alert alert-danger">
      <i class="bi bi-exclamation-triangle"></i>
      {{ error }}
    </div>

    <!-- Datos de la Licencia -->
    <div v-if="licData && !loading" class="card">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-file-text"></i>
          Datos de Licencia #{{ licData.numlic }}
        </h5>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-bordered table-sm">
            <tbody>
              <tr>
                <th class="bg-light">Recaudadora</th>
                <td>{{ licData.ofna }}</td>
                <th class="bg-light">Licencia</th>
                <td>{{ licData.numlic }}</td>
                <th class="bg-light">RFC</th>
                <td>{{ licData.inirfc }}{{ licData.fnarfc }}</td>
              </tr>
              <tr>
                <th class="bg-light">Homonimia</th>
                <td>{{ licData.homono }}</td>
                <th class="bg-light">Dígito Hom.</th>
                <td>{{ licData.dighom }}</td>
                <th class="bg-light">Código Giro</th>
                <td>{{ licData.codgir }}</td>
              </tr>
              <tr>
                <th class="bg-light">Giro 1</th>
                <td colspan="5">{{ licData.ilgir1 }}</td>
              </tr>
              <tr>
                <th class="bg-light">Giro 2</th>
                <td colspan="5">{{ licData.ilgir2 }}</td>
              </tr>
              <tr>
                <th class="bg-light">Giro 3</th>
                <td colspan="5">{{ licData.ilgir3 }}</td>
              </tr>
              <tr>
                <th class="bg-light">No. Cars</th>
                <td>{{ licData.nocars }}</td>
                <th class="bg-light">No. Grub</th>
                <td>{{ licData.nugrub }}</td>
                <th class="bg-light">Calle</th>
                <td>{{ licData.nomcal }}</td>
              </tr>
              <tr>
                <th class="bg-light">Núm. Ext.</th>
                <td>{{ licData.nuext }}</td>
                <th class="bg-light">Letra Ext.</th>
                <td>{{ licData.letext }}</td>
                <th class="bg-light">Núm. Int.</th>
                <td>{{ licData.numint }}</td>
              </tr>
              <tr>
                <th class="bg-light">Letra Int.</th>
                <td>{{ licData.letint }}</td>
                <th class="bg-light">Piso</th>
                <td>{{ licData.piso }}</td>
                <th class="bg-light">Letra Sec.</th>
                <td>{{ licData.letsec }}</td>
              </tr>
              <tr>
                <th class="bg-light">Núm. Zona</th>
                <td>{{ licData.numzon }}</td>
                <th class="bg-light">Zona Postal</th>
                <td>{{ licData.zonpos }}</td>
                <th class="bg-light">Fecha Alta</th>
                <td>{{ formatDate(licData.fecalt) }}</td>
              </tr>
              <tr>
                <th class="bg-light">Fecha Baja</th>
                <td>{{ formatDate(licData.fecbaj) }}</td>
                <th class="bg-light">Tomo/Medida</th>
                <td>{{ licData.tomesu }}</td>
                <th class="bg-light">Núm. Anuncio</th>
                <td>{{ licData.numanu }}</td>
              </tr>
              <tr>
                <th class="bg-light">Núm. Ayunt.</th>
                <td>{{ licData.nuayt }}</td>
                <th class="bg-light">Re Int.</th>
                <td>{{ licData.reint }}</td>
                <th class="bg-light">Rec. Lt.</th>
                <td>{{ licData.reclt }}</td>
              </tr>
              <tr>
                <th class="bg-light">Im. Lit.</th>
                <td>{{ licData.imlit }}</td>
                <th class="bg-light">Li. Imt.</th>
                <td>{{ licData.liimt }}</td>
                <th class="bg-light">Vigencia</th>
                <td>{{ licData.vigenc }}</td>
              </tr>
              <tr>
                <th class="bg-light">Act. Gral.</th>
                <td>{{ licData.actgrl }}</td>
                <th class="bg-light">Grabó</th>
                <td>{{ licData.grabo }}</td>
                <th class="bg-light">Resta</th>
                <td>{{ licData.resta }}</td>
              </tr>
              <tr>
                <th class="bg-light">Fut1</th>
                <td>{{ licData.fut1 }}</td>
                <th class="bg-light">Fut2</th>
                <td>{{ licData.fut2 }}</td>
                <td colspan="2"></td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Botón para Ver Pagos -->
        <div class="mt-3">
          <button @click="verPagos" class="btn btn-secondary">
            <i class="bi bi-credit-card"></i>
            Ver Pagos de esta Licencia
          </button>
        </div>
      </div>
    </div>

    <!-- Sección de Pagos -->
    <div v-if="mostrarPagos && pagos" class="card mt-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="bi bi-credit-card"></i>
          Pagos de Licencia #{{ filtros.licencia }}
        </h5>
      </div>
      <div class="card-body">
        <div v-if="pagos.length > 0" class="table-responsive">
          <table class="table table-striped table-sm">
            <thead class="table-dark">
              <tr>
                <th v-for="(value, key) in pagos[0]" :key="key">{{ key }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(pago, index) in pagos" :key="index">
                <td v-for="(value, key) in pago" :key="key">{{ value }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="alert alert-info">
          <i class="bi bi-info-circle"></i>
          No hay pagos registrados para esta licencia.
        </div>
      </div>
    </div>

    <!-- Mensaje sin resultados -->
    <div v-if="!licData && !loading && hasSearched" class="alert alert-warning">
      <i class="bi bi-search"></i>
      No se encontró información para la licencia {{ filtros.licencia }}
    </div>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import apiService from '../../../services/apiService'

export default {
  name: 'ConsLic400Frm',
  setup() {
    const loading = ref(false)
    const error = ref('')
    const licData = ref(null)
    const pagos = ref(null)
    const mostrarPagos = ref(false)
    const hasSearched = ref(false)
    
    const filtros = reactive({
      licencia: ''
    })

    const buscarLicencia = async () => {
      if (!filtros.licencia) {
        error.value = 'Ingrese el número de licencia'
        return
      }

      loading.value = true
      error.value = ''
      licData.value = null
      mostrarPagos.value = false
      pagos.value = null
      hasSearched.value = true

      try {
        const eRequest = {
          Operacion: 'get_lic_400',
          Base: 'licencias',
          Parametros: [
            {
              nombre: 'p_licencia',
              valor: parseInt(filtros.licencia),
              tipo: 'integer'
            }
          ],
          Tenant: 'guadalajara'
        }

        const response = await apiService.executeGeneric(eRequest)
        
        if (response.success && response.data.result && response.data.result.length > 0) {
          licData.value = response.data.result[0]
        } else {
          error.value = 'No se encontró la licencia especificada'
        }
      } catch (e) {
        console.error('Error al buscar licencia:', e)
        error.value = 'Error al consultar la licencia: ' + (e.message || 'Error desconocido')
      } finally {
        loading.value = false
      }
    }

    const verPagos = async () => {
      if (!licData.value || !licData.value.numlic) {
        error.value = 'No hay licencia seleccionada para consultar pagos'
        return
      }

      loading.value = true
      error.value = ''

      try {
        const eRequest = {
          Operacion: 'get_pago_lic_400',
          Base: 'licencias',
          Parametros: [
            {
              nombre: 'p_numlic',
              valor: parseInt(licData.value.numlic),
              tipo: 'integer'
            }
          ],
          Tenant: 'guadalajara'
        }

        const response = await apiService.executeGeneric(eRequest)
        
        if (response.success && response.data.result) {
          pagos.value = response.data.result
          mostrarPagos.value = true
        } else {
          pagos.value = []
          mostrarPagos.value = true
        }
      } catch (e) {
        console.error('Error al buscar pagos:', e)
        error.value = 'Error al consultar los pagos: ' + (e.message || 'Error desconocido')
      } finally {
        loading.value = false
      }
    }

    const formatDate = (dateString) => {
      if (!dateString) return ''
      try {
        return new Date(dateString).toLocaleDateString('es-MX')
      } catch {
        return dateString
      }
    }

    return {
      loading,
      error,
      licData,
      pagos,
      mostrarPagos,
      hasSearched,
      filtros,
      buscarLicencia,
      verPagos,
      formatDate
    }
  }
}
</script>

<style scoped>
.table th {
  width: 120px;
  white-space: nowrap;
}

.table td {
  word-wrap: break-word;
}

.bg-light {
  background-color: #f8f9fa !important;
}
</style>
