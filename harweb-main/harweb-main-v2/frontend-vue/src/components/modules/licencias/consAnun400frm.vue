<template>
  <div class="anuncio400-page municipal-page">
    <!-- Municipal Header with FontAwesome Icon -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="municipal-title">
            <i class="fas fa-bullhorn"></i>
            CONSULTA DE ANUNCIOS DEL AS/400
          </h2>
          <p class="municipal-subtitle mb-0">
            Sistema de consulta de anuncios publicitarios del mainframe AS/400
          </p>
        </div>
      </div>
    </div>

    <nav aria-label="breadcrumb" class="municipal-breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Anuncios AS/400</li>
      </ol>
    </nav>
    <!-- Municipal Search Form -->
    <div class="municipal-card mb-4">
      <div class="card-body">
        <form @submit.prevent="buscarAnuncio" class="municipal-form">
          <div class="row align-items-end">
            <div class="col-md-4">
              <label for="anuncio" class="form-label municipal-label">
                <i class="fas fa-search"></i> Número de Anuncio:
              </label>
              <input
                type="number"
                v-model="anuncio"
                class="form-control municipal-input"
                id="anuncio"
                required
                @keyup.enter="buscarAnuncio"
                placeholder="Ingrese el número de anuncio"
              />
            </div>
            <div class="col-md-3">
              <div class="btn-group municipal-group-btn" role="group">
                <button type="submit" class="btn btn-primary municipal-btn-primary" :disabled="loading">
                  <i class="fas fa-search"></i>
                  <span v-if="loading">Buscando...</span>
                  <span v-else>Buscar</span>
                </button>
                <button type="button" class="btn btn-outline-secondary municipal-btn-secondary" @click="limpiarBusqueda">
                  <i class="fas fa-times"></i>
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Municipal Loading State -->
    <div v-if="loading" class="alert alert-info municipal-alert">
      <i class="fas fa-spinner fa-spin"></i>
      Cargando datos del anuncio...
    </div>

    <!-- Municipal Error State -->
    <div v-if="error" class="alert alert-danger municipal-alert">
      <i class="fas fa-exclamation-triangle"></i>
      {{ error }}
    </div>

    <!-- Municipal Results Section -->
    <div v-if="anuncioData" class="municipal-results">
      <div class="municipal-card">
        <div class="card-header municipal-table-header">
          <h5 class="mb-0">
            <i class="fas fa-bullhorn"></i>
            Datos del Anuncio {{ anuncioData.numanu }}
          </h5>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-sm municipal-table">
        <tbody>
          <tr>
            <th>Recaud</th>
            <td>{{ anuncioData.cvemc }}</td>
            <th>No. Anuncio</th>
            <td>{{ anuncioData.numanu }}</td>
            <th>RFC</th>
            <td>{{ anuncioData.rfc }}</td>
          </tr>
          <tr>
            <th>Nombre Establecimiento</th>
            <td colspan="5">{{ anuncioData.nomesta }}</td>
          </tr>
          <tr>
            <th>Num. Licencia</th>
            <td>{{ anuncioData.numlica }}</td>
            <th>No. Diligencia</th>
            <td>{{ anuncioData.numdili }}</td>
            <th>Ngrupo</th>
            <td>{{ anuncioData.ngrupo }}</td>
          </tr>
          <tr>
            <th>Lsector</th>
            <td>{{ anuncioData.lsector }}</td>
            <th>Ncolon</th>
            <td>{{ anuncioData.ncolon }}</td>
            <th>Ncalle</th>
            <td>{{ anuncioData.ncalle }}</td>
          </tr>
          <tr>
            <th>Lcalle</th>
            <td>{{ anuncioData.lcalle }}</td>
            <th>Tipubic</th>
            <td>{{ anuncioData.tipubic }}</td>
            <th>Nubic</th>
            <td>{{ anuncioData.nubic }}</td>
          </tr>
          <tr>
            <th>Colonia</th>
            <td colspan="5">{{ anuncioData.nomcol }}</td>
          </tr>
          <tr>
            <th>Calle</th>
            <td colspan="5">{{ anuncioData.nomcall }}</td>
          </tr>
          <tr>
            <th>No. Ext</th>
            <td>{{ anuncioData.noext }}</td>
            <th>Letra Ext</th>
            <td>{{ anuncioData.lext }}</td>
            <th>No. Int</th>
            <td>{{ anuncioData.nint }}</td>
          </tr>
          <tr>
            <th>Letra Int</th>
            <td>{{ anuncioData.lint }}</td>
            <th>Empresa</th>
            <td>{{ anuncioData.nempre }}</td>
            <th>Nom. Causante</th>
            <td>{{ anuncioData.nomcau }}</td>
          </tr>
          <tr>
            <th>CRFC</th>
            <td>{{ anuncioData.crfc }}</td>
            <th>Cngrupo</th>
            <td>{{ anuncioData.cngrupo }}</td>
            <th>Clsector</th>
            <td>{{ anuncioData.clsector }}</td>
          </tr>
          <tr>
            <th>CNcolon</th>
            <td>{{ anuncioData.cncolon }}</td>
            <th>CNcalle</th>
            <td>{{ anuncioData.cncalle }}</td>
            <th>Clcalle</th>
            <td>{{ anuncioData.clcalle }}</td>
          </tr>
          <tr>
            <th>CTipubic</th>
            <td>{{ anuncioData.ctipubic }}</td>
            <th>CNubic</th>
            <td>{{ anuncioData.cnubic }}</td>
            <th>CNomcol</th>
            <td>{{ anuncioData.cnomcol }}</td>
          </tr>
          <tr>
            <th>CNomcall</th>
            <td>{{ anuncioData.cnomcall }}</td>
            <th>CNext</th>
            <td>{{ anuncioData.cnext }}</td>
            <th>Clext</th>
            <td>{{ anuncioData.clext }}</td>
          </tr>
          <tr>
            <th>CNint</th>
            <td>{{ anuncioData.cnint }}</td>
            <th>Clint</th>
            <td>{{ anuncioData.clint }}</td>
            <th>Tipanu</th>
            <td>{{ anuncioData.tipanu }}</td>
          </tr>
          <tr>
            <th>Pmetr</th>
            <td>{{ anuncioData.pmetr }}</td>
            <th>Smetr</th>
            <td>{{ anuncioData.smetr }}</td>
            <th>Angrupo</th>
            <td>{{ anuncioData.angrupo }}</td>
          </tr>
          <tr>
            <th>Alsector</th>
            <td>{{ anuncioData.alsector }}</td>
            <th>Ancolon</th>
            <td>{{ anuncioData.ancolon }}</td>
            <th>Ancalle</th>
            <td>{{ anuncioData.ancalle }}</td>
          </tr>
          <tr>
            <th>Alcalle</th>
            <td>{{ anuncioData.alcalle }}</td>
            <th>Anubic</th>
            <td>{{ anuncioData.anubic }}</td>
            <th>Anomcol</th>
            <td>{{ anuncioData.anomcol }}</td>
          </tr>
          <tr>
            <th>Anomcall</th>
            <td>{{ anuncioData.anomcall }}</td>
            <th>Anext</th>
            <td>{{ anuncioData.anext }}</td>
            <th>Alext</th>
            <td>{{ anuncioData.alext }}</td>
          </tr>
          <tr>
            <th>Anint</th>
            <td>{{ anuncioData.anint }}</td>
            <th>Alint</th>
            <td>{{ anuncioData.alint }}</td>
            <th>Zona</th>
            <td>{{ anuncioData.zona }}</td>
          </tr>
          <tr>
            <th>Nzona</th>
            <td>{{ anuncioData.nzona }}</td>
            <th>Nmza</th>
            <td>{{ anuncioData.nmza }}</td>
            <th>Fecha Alta</th>
            <td>{{ anuncioData.fecalt }}</td>
          </tr>
          <tr>
            <th>Feccam</th>
            <td>{{ anuncioData.feccam }}</td>
            <th>Fecbaj</th>
            <td>{{ anuncioData.fecbaj }}</td>
            <th>Nuay1</th>
            <td>{{ anuncioData.nuay1 }}</td>
          </tr>
          <tr>
            <th>Cvpa1</th>
            <td>{{ anuncioData.cvpa1 }}</td>
            <th>Fepa1</th>
            <td>{{ anuncioData.fepa1 }}</td>
            <th>Rein1</th>
            <td>{{ anuncioData.rein1 }}</td>
          </tr>
          <tr>
            <th>Recl1</th>
            <td>{{ anuncioData.recl1 }}</td>
            <th>Nuof1</th>
            <td>{{ anuncioData.nuof1 }}</td>
            <th>Impe1</th>
            <td>{{ anuncioData.impe1 }}</td>
          </tr>
          <tr>
            <th>Imiv1</th>
            <td>{{ anuncioData.imiv1 }}</td>
            <th>Pdpa1</th>
            <td>{{ anuncioData.pdpa1 }}</td>
            <th>Nuct1</th>
            <td>{{ anuncioData.nuct1 }}</td>
          </tr>
          <tr>
            <th>Nuay2</th>
            <td>{{ anuncioData.nuay2 }}</td>
            <th>Cvpa2</th>
            <td>{{ anuncioData.cvpa2 }}</td>
            <th>Fepa2</th>
            <td>{{ anuncioData.fepa2 }}</td>
          </tr>
          <tr>
            <th>Rein2</th>
            <td>{{ anuncioData.rein2 }}</td>
            <th>Recl2</th>
            <td>{{ anuncioData.recl2 }}</td>
            <th>Nuof2</th>
            <td>{{ anuncioData.nuof2 }}</td>
          </tr>
          <tr>
            <th>Impe2</th>
            <td>{{ anuncioData.impe2 }}</td>
            <th>Imiv2</th>
            <td>{{ anuncioData.imiv2 }}</td>
            <th>Pdpa2</th>
            <td>{{ anuncioData.pdpa2 }}</td>
          </tr>
          <tr>
            <th>Nuct2</th>
            <td>{{ anuncioData.nuct2 }}</td>
            <th>Nuay3</th>
            <td>{{ anuncioData.nuay3 }}</td>
            <th>Cvpa3</th>
            <td>{{ anuncioData.cvpa3 }}</td>
          </tr>
          <tr>
            <th>Fepa3</th>
            <td>{{ anuncioData.fepa3 }}</td>
            <th>Rein3</th>
            <td>{{ anuncioData.rein3 }}</td>
            <th>Recl3</th>
            <td>{{ anuncioData.recl3 }}</td>
          </tr>
          <tr>
            <th>Nuof3</th>
            <td>{{ anuncioData.nuof3 }}</td>
            <th>Impe3</th>
            <td>{{ anuncioData.impe3 }}</td>
            <th>Imiv3</th>
            <td>{{ anuncioData.imiv3 }}</td>
          </tr>
          <tr>
            <th>Pdpa3</th>
            <td>{{ anuncioData.pdpa3 }}</td>
            <th>Nuct3</th>
            <td>{{ anuncioData.nuct3 }}</td>
            <th>Fut1</th>
            <td>{{ anuncioData.fut1 }}</td>
          </tr>
          <tr>
            <th>Fut2</th>
            <td>{{ anuncioData.fut2 }}</td>
          </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer municipal-card-footer">
          <div class="btn-group municipal-group-btn" role="group">
            <router-link :to="'/anuncio400/' + anuncio + '/pagos'" class="btn btn-primary municipal-btn-primary">
              <i class="fas fa-money-bill-wave"></i>
              Ver Pagos
            </router-link>
            <button type="button" class="btn btn-outline-info municipal-btn-info" @click="exportarDatos" :disabled="!anuncioData">
              <i class="fas fa-download"></i>
              Exportar
            </button>
            <button type="button" class="btn btn-outline-secondary municipal-btn-secondary" @click="imprimirDatos" :disabled="!anuncioData">
              <i class="fas fa-print"></i>
              Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Anuncio400Page',
  data() {
    return {
      anuncio: '',
      anuncioData: null,
      loading: false,
      error: null
    };
  },
  methods: {
    async buscarAnuncio() {
      this.error = null;
      this.anuncioData = null;
      if (!this.anuncio) {
        this.error = 'Debe ingresar el número de anuncio.';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'getAnuncio400',
            params: { anuncio: this.anuncio }
          })
        });
        const data = await response.json();
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.anuncioData = data.eResponse.data[0];
        } else {
          this.error = data.eResponse.error || 'No se encontró el anuncio.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },

    limpiarBusqueda() {
      this.anuncio = '';
      this.anuncioData = null;
      this.error = null;
    },

    exportarDatos() {
      if (!this.anuncioData) return;
      // Implementar exportación a Excel/CSV
      console.log('Exportando datos del anuncio:', this.anuncioData.numanu);
    },

    imprimirDatos() {
      if (!this.anuncioData) return;
      window.print();
    }
  }
};
</script>

<style scoped>
/* Municipal Page Layout */
.anuncio400-page {
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

.municipal-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}

/* Municipal Header */
.municipal-header {
  background: var(--municipal-primary);
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  padding: 2rem;
  border-radius: 12px;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.municipal-title {
  color: white;
  font-size: 1.75rem;
  font-weight: 600;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.municipal-title i {
  font-size: 1.5rem;
}

.municipal-subtitle {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1rem;
  margin-top: 0.5rem;
}

/* Municipal Breadcrumb */
.municipal-breadcrumb {
  margin-bottom: 1.5rem;
}

.municipal-breadcrumb .breadcrumb {
  background: none;
  padding: 0;
  margin: 0;
}

/* Municipal Cards */
.municipal-card {
  background: white;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* Municipal Forms */
.municipal-form {
  padding: 0.5rem 0;
}

.municipal-label {
  color: var(--municipal-primary);
  font-weight: 600;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.municipal-input {
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.75rem;
  font-size: 1rem;
  transition: all 0.2s ease;
}

.municipal-input:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(var(--municipal-primary-rgb), 0.1);
  outline: none;
}

/* Municipal Buttons */
.municipal-group-btn {
  display: flex;
  gap: 0.5rem;
}

.municipal-btn-primary {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.municipal-btn-primary:hover {
  background: var(--municipal-secondary);
  border-color: var(--municipal-secondary);
  transform: translateY(-1px);
}

.municipal-btn-secondary {
  border: 2px solid #6c757d;
  color: #6c757d;
  background: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.municipal-btn-secondary:hover {
  background: #6c757d;
  color: white;
  transform: translateY(-1px);
}

.municipal-btn-info {
  border: 2px solid #17a2b8;
  color: #17a2b8;
  background: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.municipal-btn-info:hover {
  background: #17a2b8;
  color: white;
  transform: translateY(-1px);
}

/* Municipal Alerts */
.municipal-alert {
  border: none;
  border-radius: 8px;
  padding: 1rem 1.5rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

/* Municipal Table */
.municipal-table-header {
  background: var(--municipal-primary);
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  border: none;
  padding: 1rem 1.5rem;
}

.municipal-table-header h5 {
  color: white;
  font-size: 1.1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.municipal-table {
  margin: 0;
  background: white;
}

.municipal-table th {
  background: #f8f9fa;
  color: var(--municipal-primary);
  font-weight: 600;
  font-size: 0.9rem;
  padding: 0.75rem;
  border: none;
  border-bottom: 2px solid #e9ecef;
  vertical-align: middle;
}

.municipal-table td {
  padding: 0.75rem;
  vertical-align: middle;
  border: none;
  border-bottom: 1px solid #f1f3f4;
  color: #495057;
}

.municipal-table tbody tr:hover {
  background-color: rgba(var(--municipal-primary-rgb), 0.05);
}

/* Municipal Card Footer */
.municipal-card-footer {
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  padding: 1rem 1.5rem;
}

/* Municipal Results */
.municipal-results {
  margin-top: 1.5rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .municipal-page {
    padding: 1rem;
  }

  .municipal-header {
    padding: 1.5rem;
    text-align: center;
  }

  .municipal-title {
    font-size: 1.5rem;
    justify-content: center;
  }

  .municipal-group-btn {
    flex-direction: column;
  }

  .municipal-group-btn .btn {
    width: 100%;
    margin-bottom: 0.5rem;
  }
}

/* Print Styles */
@media print {
  .municipal-header {
    background: white !important;
    color: var(--municipal-primary) !important;
  }

  .municipal-title {
    color: var(--municipal-primary) !important;
  }

  .municipal-card-footer,
  .municipal-btn-primary,
  .municipal-btn-secondary,
  .municipal-btn-info {
    display: none !important;
  }
}
</style>
