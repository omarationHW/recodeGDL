<template>
  <div class="zonas-report-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Zonas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">MUNICIPIO DE GUADALAJARA</h4>
        <div>DIRECCION DE INGRESOS</div>
        <div>Catálogo de Zonas</div>
        <div class="mt-2"><strong>{{ clasificacionLabel }}</strong></div>
      </div>
      <div class="card-body">
        <form class="form-inline mb-3" @submit.prevent="fetchReport">
          <label class="mr-2">Clasificación por:</label>
          <select v-model="opcion" class="form-control mr-2">
            <option :value="1">Número de Control</option>
            <option :value="2">Zona</option>
            <option :value="3">Sub-Zona</option>
            <option :value="4">Descripción</option>
          </select>
          <button type="submit" class="btn btn-primary">Consultar</button>
        </form>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="zonas.length > 0">
          <table class="table table-bordered table-sm">
            <thead class="thead-light">
              <tr>
                <th class="text-center">Control</th>
                <th class="text-center">Zona</th>
                <th class="text-center">Sub-Zona</th>
                <th class="text-center">Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(zona, idx) in zonas" :key="idx">
                <td class="text-center">{{ zona.ctrol_zona }}</td>
                <td class="text-center">{{ zona.zona }}</td>
                <td class="text-center">{{ zona.sub_zona }}</td>
                <td>{{ zona.descripcion }}</td>
              </tr>
            </tbody>
          </table>
          <div class="text-right text-muted">
            Impreso: {{ now }}
          </div>
        </div>
        <div v-else-if="!loading && !error">
          <div class="alert alert-info">No hay datos para mostrar.</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ZonasReportPage',
  data() {
    return {
      opcion: 1,
      zonas: [],
      loading: false,
      error: '',
      now: ''
    };
  },
  computed: {
    clasificacionLabel() {
      switch (this.opcion) {
        case 1: return 'Clasificación por: Número de Control';
        case 2: return 'Clasificación por: Zona';
        case 3: return 'Clasificación por: Sub-Zona';
        case 4: return 'Clasificación por: Descripción';
        default: return '';
      }
    }
  },
  methods: {
    fetchReport() {
      this.loading = true;
      this.error = '';
      this.zonas = [];
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'getZonasReport',
          params: { opcion: this.opcion }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse && json.eResponse.success) {
            this.zonas = json.eResponse.data;
            this.setNow();
          } else {
            this.error = json.eResponse ? json.eResponse.message : 'Error desconocido.';
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red.';
        })
        .finally(() => {
          this.loading = false;
        });
    },
    setNow() {
      const d = new Date();
      this.now = d.toLocaleString();
    }
  },
  mounted() {
    this.fetchReport();
  }
};
</script>

<style scoped>
.zonas-report-page {
  max-width: 950px;
  margin: 0 auto;
}
.card-header {
  text-align: center;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
