<template>
  <div class="container-fluid">
    <!-- Loading Overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-content">
        <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-3 mb-0">Consultando licencia AS/400...</p>
      </div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container position-fixed top-0 end-0 p-3">
      <div v-for="(toast, index) in toasts" :key="index"
           :class="`toast ${toast.show ? 'show' : ''}`" role="alert">
        <div class="toast-header">
          <i :class="`fas ${toast.icon} me-2`" :style="`color: ${toast.color}`"></i>
          <strong class="me-auto">{{ toast.title }}</strong>
          <button type="button" class="btn-close" @click="removeToast(index)"></button>
        </div>
        <div class="toast-body">{{ toast.message }}</div>
      </div>
    </div>

    <!-- SweetAlert-style Modal -->
    <div v-if="sweetAlert.show" class="swal-overlay" @click.self="closeSweetAlert">
      <div class="swal-modal">
        <div class="swal-icon">
          <i :class="`fas ${sweetAlert.icon}`" :style="`color: ${sweetAlert.color}`"></i>
        </div>
        <h3 class="swal-title">{{ sweetAlert.title }}</h3>
        <p class="swal-text">{{ sweetAlert.text }}</p>
        <div class="swal-footer">
          <button @click="closeSweetAlert" :class="`btn ${sweetAlert.buttonClass}`">
            {{ sweetAlert.buttonText }}
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
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
  </div>
</template>

<script>
export default {
  name: 'ConsLic400Frm',
  data() {
    return {
      loading: false,
      error: '',
      licData: null,
      pagos: null,
      mostrarPagos: false,
      hasSearched: false,
      filtros: {
        licencia: ''
      },
      toasts: [],
      sweetAlert: {
        show: false,
        type: 'success',
        title: '',
        text: '',
        icon: 'fa-check-circle',
        color: '#28a745',
        buttonText: 'OK',
        buttonClass: 'btn-success'
      }
    }
  },
  methods: {
    async buscarLicencia() {
      if (!this.filtros.licencia) {
        this.error = 'Ingrese el número de licencia'
        return
      }

      this.loading = true
      this.error = ''
      this.licData = null
      this.mostrarPagos = false
      this.pagos = null
      this.hasSearched = true

      try {
        const eRequest = {
          Operacion: 'sp_conslic400_get',
          Base: 'padron_licencias',
          Parametros: [
            {
              nombre: 'p_licencia',
              valor: parseInt(this.filtros.licencia)
            }
          ],
          Tenant: 'informix'
        }

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.success && data.data && data.data.length > 0) {
          this.licData = data.data[0]
          this.showSweetAlert('success', '¡Éxito!', 'Licencia encontrada exitosamente')
          this.showToast('Éxito', 'Licencia cargada correctamente', 'success')
        } else {
          this.showSweetAlert('warning', 'No encontrado', 'No se encontró la licencia especificada')
        }
      } catch (e) {
        console.error('Error al buscar licencia:', e)
        this.showSweetAlert('error', 'Error', 'Error al consultar la licencia: ' + (e.message || 'Error desconocido'))
        this.showToast('Error', 'No se pudo consultar la licencia', 'error')
      } finally {
        this.loading = false
      }
    },

    async verPagos() {
      if (!this.licData || !this.licData.numlic) {
        this.error = 'No hay licencia seleccionada para consultar pagos'
        return
      }

      this.loading = true
      this.error = ''

      try {
        const eRequest = {
          Operacion: 'sp_conslic400_pagos',
          Base: 'padron_licencias',
          Parametros: [
            {
              nombre: 'p_licencia',
              valor: parseInt(this.licData.numlic)
            }
          ],
          Tenant: 'informix'
        }

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.success && data.data) {
          this.pagos = data.data
          this.mostrarPagos = true
          this.showToast('Información', `Se encontraron ${this.pagos.length} pagos`, 'info')
        } else {
          this.pagos = []
          this.mostrarPagos = true
          this.showToast('Información', 'No hay pagos registrados', 'info')
        }
      } catch (e) {
        console.error('Error al buscar pagos:', e)
        this.showSweetAlert('error', 'Error', 'Error al consultar los pagos: ' + (e.message || 'Error desconocido'))
        this.showToast('Error', 'No se pudieron consultar los pagos', 'error')
      } finally {
        this.loading = false
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

    showSweetAlert(type, title, text) {
      const config = {
        success: { icon: 'fa-check-circle', color: '#28a745', buttonClass: 'btn-success' },
        error: { icon: 'fa-times-circle', color: '#dc3545', buttonClass: 'btn-danger' },
        warning: { icon: 'fa-exclamation-triangle', color: '#ffc107', buttonClass: 'btn-warning' },
        info: { icon: 'fa-info-circle', color: '#17a2b8', buttonClass: 'btn-info' }
      };

      this.sweetAlert = {
        show: true,
        type: type,
        title: title,
        text: text,
        icon: config[type].icon,
        color: config[type].color,
        buttonText: 'OK',
        buttonClass: config[type].buttonClass
      };

      // Auto cerrar después de 3 segundos para success e info, 5 segundos para error y warning
      const autoCloseTime = (type === 'success' || type === 'info') ? 3000 : 5000;
      setTimeout(() => {
        this.closeSweetAlert();
      }, autoCloseTime);
    },

    closeSweetAlert() {
      this.sweetAlert.show = false;
    },

    showToast(title, message, type) {
      const config = {
        success: { icon: 'fa-check-circle', color: '#28a745' },
        error: { icon: 'fa-times-circle', color: '#dc3545' },
        warning: { icon: 'fa-exclamation-triangle', color: '#ffc107' },
        info: { icon: 'fa-info-circle', color: '#17a2b8' }
      };

      const toast = {
        title: title,
        message: message,
        icon: config[type].icon,
        color: config[type].color,
        show: false
      };

      this.toasts.push(toast);

      setTimeout(() => {
        toast.show = true;
      }, 100);

      setTimeout(() => {
        this.removeToast(this.toasts.length - 1);
      }, 4000);
    },

    removeToast(index) {
      if (this.toasts[index]) {
        this.toasts[index].show = false;
        setTimeout(() => {
          this.toasts.splice(index, 1);
        }, 300);
      }
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

/* Estilos específicos del componente (los globales están en src/styles/global.css) */
</style>
