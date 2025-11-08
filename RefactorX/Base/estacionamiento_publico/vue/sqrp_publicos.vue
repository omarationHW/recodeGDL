<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estacionamientos Públicos</li>
      </ol>
    </nav>
    <h2>Relación de Estacionamientos Públicos</h2>
    <div class="mb-3">
      <label for="opc" class="form-label">Clasificar por:</label>
      <select v-model="opc" id="opc" class="form-select" @change="fetchReport">
        <option :value="1">Número</option>
        <option :value="2">Nombre</option>
        <option :value="3">Calle</option>
        <option :value="4">Sector y Calle</option>
        <option :value="5">Zona y Sub-Zona</option>
      </select>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="caption" class="mb-2"><strong>{{ caption }}</strong></div>
    <div v-if="reportData.length">
      <table class="table table-bordered table-sm table-hover">
        <thead class="table-light">
          <tr>
            <th>Clave</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Num</th>
            <th>Cupo</th>
            <th>Alta</th>
            <th>Inicio</th>
            <th>Vencimiento</th>
            <th>Zona</th>
            <th>SubZona</th>
            <th>Teléfono</th>
            <th>No. Licencia</th>
            <th>No. Póliza</th>
            <th>Venc. Póliza</th>
            <th>Horario 1</th>
            <th>Horario 2</th>
            <th>L</th>
            <th>M</th>
            <th>Mi</th>
            <th>J</th>
            <th>V</th>
            <th>S</th>
            <th>D</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.control">
            <td>{{ row.cve_sector }}-{{ row.cve_categ }}-{{ row.cve_numero }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num }}</td>
            <td>{{ row.cupo }}</td>
            <td>{{ formatDate(row.fecha_alta) }}</td>
            <td>{{ formatDate(row.fecha_inic) }}</td>
            <td>{{ formatDate(row.fecha_venci) }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.subzona }}</td>
            <td>{{ row.telefono }}</td>
            <td>{{ row.numlic }}</td>
            <td>{{ row.pol_num }}</td>
            <td>{{ formatDate(row.pol_fec_ven) }}</td>
            <td>{{ row.delas }} - {{ row.alas }}</td>
            <td>{{ row.delas1 }} - {{ row.alas1 }}</td>
            <td>{{ row.frec_lunes }}</td>
            <td>{{ row.frec_martes }}</td>
            <td>{{ row.frec_miercoles }}</td>
            <td>{{ row.frec_jueves }}</td>
            <td>{{ row.frec_viernes }}</td>
            <td>{{ row.frec_sabado }}</td>
            <td>{{ row.frec_domingo }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'SqrpPublicosPage',
  data() {
    return {
      opc: 1,
      reportData: [],
      loading: false,
      error: '',
      caption: ''
    };
  },
  mounted() {
    this.fetchReport();
  },
  methods: {
    fetchReport() {
      this.loading = true;
      this.error = '';
      this.caption = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'sqrp_publicos_report',
          params: { opc: this.opc }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse && json.eResponse.status === 'success') {
            this.reportData = json.eResponse.data;
            this.caption = json.eResponse.message;
          } else {
            this.error = json.eResponse ? json.eResponse.message : 'Error desconocido';
            this.reportData = [];
          }
        })
        .catch(err => {
          this.error = 'Error de red o del servidor';
          this.reportData = [];
        })
        .finally(() => {
          this.loading = false;
        });
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  font-size: 0.95em;
}
</style>
