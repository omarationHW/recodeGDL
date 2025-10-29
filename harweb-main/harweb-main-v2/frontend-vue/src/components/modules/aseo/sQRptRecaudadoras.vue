<template>
  <div class="recaudadoras-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Recaudadoras</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>MUNICIPIO DE GUADALAJARA</h3>
        <h5>DIRECCION DE INGRESOS</h5>
        <h6>Catálogo de Recaudadoras</h6>
        <div class="form-group mt-3">
          <label for="clasificacion">Clasificación por:</label>
          <select v-model="opcion" id="clasificacion" class="form-control w-auto d-inline-block ml-2" @change="fetchData">
            <option :value="1">Recaudadora</option>
            <option :value="2">Nombre</option>
            <option :value="3">Domicilio</option>
            <option :value="4">Sector y Recaudadora</option>
          </select>
        </div>
        <div class="mt-2"><strong>{{ clasificacionLabel }}</strong></div>
      </div>
      <div class="card-body">
        <table class="table table-bordered table-sm">
          <thead class="thead-light">
            <tr>
              <th style="width: 8%">Rec</th>
              <th style="width: 28%">Nombre</th>
              <th style="width: 50%">Domicilio</th>
              <th style="width: 14%">Sector</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="rec in recaudadoras" :key="rec.id_rec">
              <td class="text-center">{{ rec.id_rec }}</td>
              <td>{{ rec.recaudadora }}</td>
              <td>{{ rec.domicilio }}</td>
              <td class="text-center">{{ rec.sector }}</td>
            </tr>
            <tr v-if="recaudadoras.length === 0">
              <td colspan="4" class="text-center">No hay datos para mostrar.</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="card-footer text-muted">
        Impreso: {{ now }}
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'RecaudadorasPage',
  data() {
    return {
      opcion: 1,
      recaudadoras: [],
      now: ''
    };
  },
  computed: {
    clasificacionLabel() {
      switch (this.opcion) {
        case 1:
          return 'Clasificación por: Recaudadora';
        case 2:
          return 'Clasificación por: Nombre';
        case 3:
          return 'Clasificación por: Domicilio';
        case 4:
          return 'Clasificación por: Sector y Recaudadora';
        default:
          return '';
      }
    }
  },
  methods: {
    fetchData() {
      axios.post('/api/execute', {
        eRequest: 'getRecaudadorasReport',
        params: { opcion: this.opcion }
      })
      .then(response => {
        this.recaudadoras = response.data.data || [];
        this.now = new Date().toLocaleString();
      })
      .catch(() => {
        this.recaudadoras = [];
        this.now = new Date().toLocaleString();
      });
    }
  },
  mounted() {
    this.fetchData();
    this.now = new Date().toLocaleString();
  }
};
</script>

<style scoped>
.recaudadoras-page {
  max-width: 1100px;
  margin: 30px auto;
}
.card-header {
  background: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}
.card-footer {
  background: #f8f9fa;
  font-size: 0.95em;
}
</style>
