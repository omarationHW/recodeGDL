<template>
  <div class="container-fluid">
    <!-- Loading Overlay -->
    <div v-if="cargando" class="loading-overlay">
      <div class="loading-content">
        <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-3 mb-0">Consultando anuncio AS/400...</p>
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
    <div class="row">
      <div class="col-12">
        <!-- Header Card -->
        <div class="card mb-4">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">
              <i class="fas fa-search text-primary me-2"></i>
              Consulta de Anuncios AS/400
            </h4>
          </div>
          <div class="card-body">
            <nav aria-label="breadcrumb" class="mb-3">
              <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item">
                  <router-link to="/" class="text-decoration-none">
                    <i class="fas fa-home me-1"></i>Inicio
                  </router-link>
                </li>
                <li class="breadcrumb-item active" aria-current="page">
                  Consulta de Anuncios AS/400
                </li>
              </ol>
            </nav>
          </div>
        </div>

        <!-- Search Card -->
        <div class="card mb-4">
          <div class="card-header">
            <h5 class="mb-0">
              <i class="fas fa-filter text-secondary me-2"></i>
              Búsqueda de Anuncio
            </h5>
          </div>
          <div class="card-body">
            <form @submit.prevent="buscarAnuncio" class="row g-3">
              <div class="col-md-4">
                <label class="form-label">Número de Anuncio <span class="text-danger">*</span></label>
                <input
                  type="number"
                  v-model="anuncio"
                  class="form-control"
                  required
                  placeholder="Ingrese el número de anuncio"
                  @keyup.enter="buscarAnuncio">
              </div>
              <div class="col-md-8 d-flex align-items-end">
                <button
                  type="submit"
                  class="btn btn-primary me-2"
                  :disabled="cargando">
                  <i class="fas fa-search me-1"></i>
                  {{ cargando ? 'Buscando...' : 'Buscar' }}
                </button>
                <button
                  type="button"
                  @click="limpiarBusqueda"
                  class="btn btn-secondary">
                  <i class="fas fa-eraser me-1"></i>Limpiar
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="cargando" class="card">
          <div class="card-body text-center py-4">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-2">Consultando datos del anuncio...</p>
          </div>
        </div>

        <!-- Error Alert -->
        <div v-if="alerta.mostrar" :class="`alert alert-${alerta.tipo} alert-dismissible fade show`">
          <i :class="`fas ${alerta.icono} me-2`"></i>
          {{ alerta.mensaje }}
          <button type="button" class="btn-close" @click="cerrarAlerta"></button>
        </div>

        <!-- Results Card -->
        <div v-if="anuncioData" class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">
              <i class="fas fa-info-circle text-success me-2"></i>
              Datos del Anuncio {{ anuncioData.numanu }}
            </h5>
            <div class="btn-group">
              <router-link
                :to="'/anuncio400/' + anuncio + '/pagos'"
                class="btn btn-outline-primary btn-sm">
                <i class="fas fa-credit-card me-1"></i>Ver Pagos
              </router-link>
              <button
                @click="exportarDatos"
                class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-download me-1"></i>Exportar
              </button>
            </div>
          </div>
          <div class="card-body">
            <!-- Información Principal -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-building me-2"></i>Información Principal
                </h6>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">Recaudación:</th>
                    <td>{{ anuncioData.cvemc || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">No. Anuncio:</th>
                    <td><span class="badge bg-primary">{{ anuncioData.numanu || '-' }}</span></td>
                  </tr>
                  <tr>
                    <th class="text-muted">RFC:</th>
                    <td><code>{{ anuncioData.rfc || '-' }}</code></td>
                  </tr>
                  <tr>
                    <th class="text-muted">No. Licencia:</th>
                    <td>{{ anuncioData.numlica || '-' }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">No. Diligencia:</th>
                    <td>{{ anuncioData.numdili || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Grupo:</th>
                    <td>{{ anuncioData.ngrupo || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Sector:</th>
                    <td>{{ anuncioData.lsector || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Zona:</th>
                    <td>{{ anuncioData.zona || '-' }}</td>
                  </tr>
                </table>
              </div>
            </div>

            <!-- Establecimiento -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-store me-2"></i>Establecimiento
                </h6>
                <div class="p-3 bg-light rounded">
                  <strong>{{ anuncioData.nomesta || 'No especificado' }}</strong>
                </div>
              </div>
            </div>

            <!-- Ubicación del Establecimiento -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-map-marker-alt me-2"></i>Ubicación del Establecimiento
                </h6>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">Colonia:</th>
                    <td>{{ anuncioData.nomcol || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Calle:</th>
                    <td>{{ anuncioData.nomcall || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">No. Exterior:</th>
                    <td>{{ anuncioData.noext || '-' }}{{ anuncioData.lext ? ' ' + anuncioData.lext : '' }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">No. Interior:</th>
                    <td>{{ anuncioData.nint || '-' }}{{ anuncioData.lint ? ' ' + anuncioData.lint : '' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Tipo Ubicación:</th>
                    <td>{{ anuncioData.tipubic || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">No. Ubicación:</th>
                    <td>{{ anuncioData.nubic || '-' }}</td>
                  </tr>
                </table>
              </div>
            </div>

            <!-- Propietario -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-user me-2"></i>Propietario
                </h6>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">Empresa:</th>
                    <td>{{ anuncioData.nempre || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Nombre Causante:</th>
                    <td>{{ anuncioData.nomcau || '-' }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">RFC Causante:</th>
                    <td><code>{{ anuncioData.crfc || '-' }}</code></td>
                  </tr>
                </table>
              </div>
            </div>

            <!-- Características del Anuncio -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-ad me-2"></i>Características del Anuncio
                </h6>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">Tipo Anuncio:</th>
                    <td>{{ anuncioData.tipanu || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Perímetro (m):</th>
                    <td>{{ anuncioData.pmetr || '-' }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-6">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted" style="width: 40%">Superficie (m²):</th>
                    <td>{{ anuncioData.smetr || '-' }}</td>
                  </tr>
                  <tr>
                    <th class="text-muted">Manzana:</th>
                    <td>{{ anuncioData.nmza || '-' }}</td>
                  </tr>
                </table>
              </div>
            </div>

            <!-- Fechas -->
            <div class="row mb-4">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-calendar me-2"></i>Fechas Importantes
                </h6>
              </div>
              <div class="col-md-4">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted">Fecha Alta:</th>
                    <td>{{ formatearFecha(anuncioData.fecalt) }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-4">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted">Fecha Cambio:</th>
                    <td>{{ formatearFecha(anuncioData.feccam) }}</td>
                  </tr>
                </table>
              </div>
              <div class="col-md-4">
                <table class="table table-sm table-borderless">
                  <tr>
                    <th class="text-muted">Fecha Baja:</th>
                    <td>
                      <span v-if="anuncioData.fecbaj" class="badge bg-danger">
                        {{ formatearFecha(anuncioData.fecbaj) }}
                      </span>
                      <span v-else class="badge bg-success">Activo</span>
                    </td>
                  </tr>
                </table>
              </div>
            </div>

            <!-- Información de Pagos (Últimos 3 años) -->
            <div class="row">
              <div class="col-12">
                <h6 class="text-primary border-bottom pb-2 mb-3">
                  <i class="fas fa-money-bill-wave me-2"></i>Historial de Pagos (Últimos 3 años)
                </h6>
                <div class="table-responsive">
                  <table class="table table-sm table-striped">
                    <thead class="table-dark">
                      <tr>
                        <th>Año</th>
                        <th>Clave Pago</th>
                        <th>Fecha Pago</th>
                        <th>Reintegro</th>
                        <th>Reclamación</th>
                        <th>No. Oficio</th>
                        <th>Importe Pagado</th>
                        <th>IVA</th>
                        <th>Periodo</th>
                        <th>No. Cuenta</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-if="anuncioData.nuay1">
                        <td><span class="badge bg-info">{{ anuncioData.nuay1 }}</span></td>
                        <td>{{ anuncioData.cvpa1 || '-' }}</td>
                        <td>{{ formatearFecha(anuncioData.fepa1) }}</td>
                        <td>{{ anuncioData.rein1 || '-' }}</td>
                        <td>{{ anuncioData.recl1 || '-' }}</td>
                        <td>{{ anuncioData.nuof1 || '-' }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.impe1) }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.imiv1) }}</td>
                        <td>{{ anuncioData.pdpa1 || '-' }}</td>
                        <td>{{ anuncioData.nuct1 || '-' }}</td>
                      </tr>
                      <tr v-if="anuncioData.nuay2">
                        <td><span class="badge bg-info">{{ anuncioData.nuay2 }}</span></td>
                        <td>{{ anuncioData.cvpa2 || '-' }}</td>
                        <td>{{ formatearFecha(anuncioData.fepa2) }}</td>
                        <td>{{ anuncioData.rein2 || '-' }}</td>
                        <td>{{ anuncioData.recl2 || '-' }}</td>
                        <td>{{ anuncioData.nuof2 || '-' }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.impe2) }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.imiv2) }}</td>
                        <td>{{ anuncioData.pdpa2 || '-' }}</td>
                        <td>{{ anuncioData.nuct2 || '-' }}</td>
                      </tr>
                      <tr v-if="anuncioData.nuay3">
                        <td><span class="badge bg-info">{{ anuncioData.nuay3 }}</span></td>
                        <td>{{ anuncioData.cvpa3 || '-' }}</td>
                        <td>{{ formatearFecha(anuncioData.fepa3) }}</td>
                        <td>{{ anuncioData.rein3 || '-' }}</td>
                        <td>{{ anuncioData.recl3 || '-' }}</td>
                        <td>{{ anuncioData.nuof3 || '-' }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.impe3) }}</td>
                        <td class="text-end">{{ formatearImporte(anuncioData.imiv3) }}</td>
                        <td>{{ anuncioData.pdpa3 || '-' }}</td>
                        <td>{{ anuncioData.nuct3 || '-' }}</td>
                      </tr>
                      <tr v-if="!anuncioData.nuay1 && !anuncioData.nuay2 && !anuncioData.nuay3">
                        <td colspan="10" class="text-center text-muted">
                          <i class="fas fa-inbox fa-2x mb-2"></i>
                          <br>No hay pagos registrados
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Alerts -->
    <div
      v-if="alerta.mostrar"
      :class="`alert alert-${alerta.tipo} alert-dismissible fade show position-fixed`"
      style="top: 20px; right: 20px; z-index: 9999; min-width: 300px;">
      <i :class="`fas ${alerta.icono} me-2`"></i>
      {{ alerta.mensaje }}
      <button type="button" class="btn-close" @click="cerrarAlerta"></button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsAnun400Frm',
  data() {
    return {
      anuncio: '',
      anuncioData: null,
      cargando: false,
      alerta: {
        mostrar: false,
        tipo: 'info',
        mensaje: '',
        icono: 'fa-info-circle'
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
    };
  },
  methods: {
    async buscarAnuncio() {
      if (!this.anuncio) {
        this.mostrarAlerta('warning', 'Debe ingresar el número de anuncio', 'fa-exclamation-triangle');
        return;
      }

      this.cargando = true;
      this.anuncioData = null;
      this.cerrarAlerta();

      try {
        const eRequest = {
          Operacion: 'sp_consanun400_get',
          Base: 'padron_licencias',
          Parametros: [
            { valor: this.anuncio }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest })
        });

        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result && data.eResponse.data.result.length > 0) {
          this.anuncioData = data.eResponse.data.result[0];
          this.showSweetAlert('success', '¡Éxito!', 'Anuncio encontrado exitosamente');
          this.showToast('Éxito', 'Anuncio cargado correctamente', 'success');
        } else {
          this.showSweetAlert('warning', 'No encontrado', 'No se encontró el anuncio especificado');
        }
      } catch (error) {
        console.error('Error al buscar anuncio:', error);
        this.showSweetAlert('error', 'Error', 'Error al consultar el anuncio: ' + error.message);
        this.showToast('Error', 'No se pudo consultar el anuncio', 'error');
      } finally {
        this.cargando = false;
      }
    },

    limpiarBusqueda() {
      this.anuncio = '';
      this.anuncioData = null;
      this.cerrarAlerta();
    },

    exportarDatos() {
      if (!this.anuncioData) return;

      const datos = {
        anuncio: this.anuncioData,
        fecha_exportacion: new Date().toISOString(),
        usuario: 'admin'
      };

      const dataStr = JSON.stringify(datos, null, 2);
      const dataBlob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(dataBlob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `anuncio_${this.anuncio}_${new Date().toISOString().split('T')[0]}.json`;
      link.click();
      URL.revokeObjectURL(url);

      this.showToast('Éxito', 'Datos exportados exitosamente', 'success');
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        return new Date(fecha).toLocaleDateString('es-ES');
      } catch (error) {
        return fecha;
      }
    },

    formatearImporte(importe) {
      if (!importe || importe === 0) return '$0.00';
      try {
        return new Intl.NumberFormat('es-MX', {
          style: 'currency',
          currency: 'MXN'
        }).format(importe);
      } catch (error) {
        return `$${importe}`;
      }
    },

    mostrarAlerta(tipo, mensaje, icono) {
      this.alerta = {
        mostrar: true,
        tipo: tipo,
        mensaje: mensaje,
        icono: icono
      };
      setTimeout(() => {
        this.cerrarAlerta();
      }, 5000);
    },

    cerrarAlerta() {
      this.alerta.mostrar = false;
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
};
</script>

<style scoped>
.breadcrumb {
  background: none;
  padding: 0;
}

.table th {
  font-weight: 600;
}

.table-borderless th,
.table-borderless td {
  border: none;
  padding: 0.375rem 0.75rem;
  background-color: white !important;
  color: #333 !important;
}

.table-borderless th.text-muted {
  color: #6c757d !important;
}

.bg-light {
  background-color: #f8f9fa !important;
}

.border-bottom {
  border-bottom: 2px solid #dee2e6 !important;
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border: 1px solid rgba(0, 0, 0, 0.125);
}

.badge {
  font-size: 0.875em;
}

code {
  color: #e83e8c;
  font-size: 0.875em;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.alert {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.loading-content {
  background: white;
  padding: 2rem;
  border-radius: 0.5rem;
  text-align: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

/* SweetAlert Styles */
.swal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.4);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
}

.swal-modal {
  background: white;
  border-radius: 0.5rem;
  padding: 2rem;
  text-align: center;
  max-width: 400px;
  width: 90%;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  animation: swalSlideIn 0.3s ease-out;
}

.swal-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.swal-title {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  color: #333;
}

.swal-text {
  color: #666;
  margin-bottom: 2rem;
  line-height: 1.5;
}

.swal-footer {
  display: flex;
  justify-content: center;
}

@keyframes swalSlideIn {
  from {
    transform: scale(0.7);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

/* Toast Styles */
.toast-container {
  z-index: 9998;
}

.toast {
  opacity: 0;
  transform: translateX(100%);
  transition: all 0.3s ease;
  margin-bottom: 0.5rem;
}

.toast.show {
  opacity: 1;
  transform: translateX(0);
}

.toast-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

@media (max-width: 768px) {
  .table-responsive {
    font-size: 0.875rem;
  }

  .btn-group .btn {
    font-size: 0.875rem;
  }

  .swal-modal {
    margin: 1rem;
    padding: 1.5rem;
  }

  .toast-container {
    left: 0;
    right: 0;
    padding: 1rem;
  }
}
</style>