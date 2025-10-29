<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Tipos de Aseo</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0 text-center">MUNICIPIO DE GUADALAJARA</h4>
        <div class="text-center">DIRECCION DE INGRESOS</div>
        <div class="text-center">Catálogo de Tipos de Aseo</div>
        <div class="text-center font-italic">{{ clasificacionLabel }}</div>
      </div>
      <div class="card-body">
        <div class="mb-3 row align-items-center">
          <label class="col-sm-3 col-form-label">Clasificación por:</label>
          <div class="col-sm-6">
            <select v-model="opcion" class="form-select" @change="fetchData">
              <option :value="1">Número de Control</option>
              <option :value="2">Tipo</option>
              <option :value="3">Descripción</option>
            </select>
          </div>
          <div class="col-sm-3 text-end">
            <button class="btn btn-secondary" @click="fetchData"><i class="bi bi-arrow-clockwise"></i> Actualizar</button>
          </div>
        </div>
        <div class="table-responsive">
          <table class="table table-bordered table-striped">
            <thead class="table-light">
              <tr>
                <th class="text-center">Control</th>
                <th class="text-center">Tipo</th>
                <th class="text-center">Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in rows" :key="row.ctrol_aseo">
                <td class="text-center">{{ row.ctrol_aseo }}</td>
                <td class="text-center">{{ row.tipo_aseo }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
              <tr v-if="rows.length === 0">
                <td colspan="3" class="text-center">No hay datos para mostrar.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer text-muted text-end">
        Impreso: {{ now }}
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'TiposAseoReport',
  data() {
    return {
      opcion: 1,
      rows: [],
      now: '',
      loading: false
    };
  },
  computed: {
    clasificacionLabel() {
      switch (this.opcion) {
        case 1: return 'Clasificación por: Número de Control';
        case 2: return 'Clasificación por: Tipo';
        case 3: return 'Clasificación por: Descripción';
        default: return '';
      }
    }
  },
  methods: {
    fetchData() {
      this.loading = true;
      axios.post('/api/execute', {
        eRequest: 'get_tipos_aseo_report',
        params: { opcion: this.opcion }
      })
      .then(resp => {
        if (resp.data && resp.data.eResponse && resp.data.eResponse.success) {
          this.rows = resp.data.eResponse.data;
        } else {
          this.rows = [];
        }
      })
      .catch(() => {
        this.rows = [];
      })
      .finally(() => {
        this.loading = false;
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
.table th, .table td {
  vertical-align: middle;
}
.card-header {
  background: #0d6efd;
  color: #fff;
}
</style>
