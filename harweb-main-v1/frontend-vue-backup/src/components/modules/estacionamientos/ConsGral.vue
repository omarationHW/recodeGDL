<template>
  <div class="consgral-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta General de Placas</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header">
        <h5>PLACA A CONSULTAR</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscar">
          <div class="row align-items-end">
            <div class="col-md-3">
              <label for="placa" class="form-label">Placa</label>
              <input
                id="placa"
                v-model="placa"
                class="form-control text-uppercase"
                maxlength="9"
                required
                autocomplete="off"
                style="font-size: 1.3em; font-weight: bold; color: #800000; font-family: 'Arial Narrow', Arial, sans-serif;"
              />
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn btn-primary btn-block">
                <i class="bi bi-search"></i> Buscar
              </button>
            </div>
            <div class="col-md-2">
              <button type="button" class="btn btn-secondary btn-block" @click="salir">
                <i class="bi bi-x-circle"></i> Salir
              </button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      </div>
    </div>
    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
    </div>
    <div v-if="!loading && (aFolios.length > 0 || bFolios.length > 0)">
      <h6>Resultados de la búsqueda</h6>
      <div class="table-responsive">
        <table class="table table-bordered table-sm table-hover">
          <thead class="table-light">
            <tr>
              <th>Tipo</th>
              <th>Placa</th>
              <th>Año</th>
              <th>Folio</th>
              <th>Fec. Alta</th>
              <th>Fec. Pago</th>
              <th>Fec. Cancela</th>
              <th>Importe</th>
              <th>Concepto</th>
              <th>Remesa</th>
              <th>Folio Ec Mpio.</th>
              <th>Fecha Inicio</th>
              <th>Fecha Fin</th>
              <th>Fecha Aplic.</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in allFolios" :key="row.tipoact + '-' + row.placa + '-' + row.folio">
              <td>{{ row.tipoact }}</td>
              <td>{{ row.placa }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ formatDate(row.fechaalta) }}</td>
              <td>{{ formatDate(row.fechapago) }}</td>
              <td>{{ formatDate(row.fechacancelado) }}</td>
              <td>{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.concepto }}</td>
              <td>{{ row.remesa }}</td>
              <td>{{ row.folioecmpio }}</td>
              <td>{{ formatDate(row.fecha_in) }}</td>
              <td>{{ formatDate(row.fecha_fin) }}</td>
              <td>{{ formatDate(row.fecha_aplic) }}</td>
            </tr>
            <tr v-if="allFolios.length === 0">
              <td colspan="14" class="text-center">Sin resultados</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsGralPage',
  data() {
    return {
      placa: '',
      aFolios: [],
      bFolios: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    allFolios() {
      // Unir ambos resultados
      return [...this.aFolios, ...this.bFolios];
    }
  },
  methods: {
    async buscar() {
      this.error = '';
      this.loading = true;
      this.aFolios = [];
      this.bFolios = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.buscarPorPlaca',
          payload: { placa: this.placa }
        });
        if (res.data.status === 'success') {
          this.aFolios = res.data.data.aFolios || [];
          this.bFolios = res.data.data.bFolios || [];
        } else {
          this.error = res.data.message || 'Error desconocido.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    salir() {
      this.$router.push('/');
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      // PostgreSQL returns ISO string or YYYY-MM-DD
      return new Date(dateStr).toLocaleDateString();
    },
    formatCurrency(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.consgral-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.text-uppercase {
  text-transform: uppercase;
}
</style>
