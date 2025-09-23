<template>
  <div class="empresas-report-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Tipos de Empresas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">MUNICIPIO DE GUADALAJARA</h4>
        <div>DIRECCION DE INGRESOS</div>
        <div>Catálogo de Tipos de Empresas</div>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label for="clasificacion" class="form-label">Clasificación por:</label>
          <select v-model="opcion" id="clasificacion" class="form-select" @change="fetchReport">
            <option :value="1">Número de Empresa</option>
            <option :value="2">Tipo de Empresa</option>
            <option :value="3">Nombre</option>
            <option :value="4">Representante</option>
          </select>
        </div>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-else>
          <table class="table table-bordered table-sm">
            <thead class="table-light">
              <tr>
                <th>Número</th>
                <th>Tipo de Empresa</th>
                <th>Nombre de la Empresa</th>
                <th>Representante</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in empresas" :key="idx">
                <td class="text-center">{{ row.num_empresa }}</td>
                <td>{{ row.descripcion_1 }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.representante }}</td>
              </tr>
              <tr v-if="empresas.length === 0">
                <td colspan="4" class="text-center">No hay datos para mostrar.</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="mt-3 text-end text-muted">
          Impreso: {{ now }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EmpresasReportPage',
  data() {
    return {
      opcion: 1,
      empresas: [],
      loading: false,
      now: ''
    };
  },
  created() {
    this.fetchReport();
    this.now = new Date().toLocaleString();
  },
  methods: {
    fetchReport() {
      this.loading = true;
      axios.post('/api/execute', {
        eRequest: 'getEmpresasReport',
        params: { opcion: this.opcion }
      })
      .then(resp => {
        if (resp.data.eResponse && resp.data.eResponse.success) {
          this.empresas = resp.data.eResponse.data;
        } else {
          this.empresas = [];
        }
      })
      .catch(() => {
        this.empresas = [];
      })
      .finally(() => {
        this.loading = false;
        this.now = new Date().toLocaleString();
      });
    }
  }
};
</script>

<style scoped>
.empresas-report-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header {
  text-align: center;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
