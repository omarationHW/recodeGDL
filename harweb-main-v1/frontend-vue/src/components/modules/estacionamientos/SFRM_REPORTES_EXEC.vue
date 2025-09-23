<template>
  <div class="reportes-exec-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes de Estacionamientos Exclusivos</li>
      </ol>
    </nav>
    <h1>Reportes de Estacionamientos Exclusivos</h1>
    <div class="mb-3">
      <label for="reportType" class="form-label">Tipo de Reporte</label>
      <select v-model="reportType" id="reportType" class="form-select">
        <option value="1">Por Clasificación y Número de Exclusivo</option>
        <option value="2">Por Clasificación y Propietario</option>
        <option value="3">Reporte de Adeudos</option>
        <option value="4">Reporte de Deudores</option>
        <option value="5">Estado de Cuenta (por No. Exclusivo)</option>
      </select>
    </div>
    <div v-if="reportType == 5" class="mb-3">
      <label for="noExclusivo" class="form-label">No. Exclusivo</label>
      <input v-model="noExclusivo" id="noExclusivo" type="number" class="form-control" />
    </div>
    <button class="btn btn-primary mb-3" @click="fetchReport">Generar Reporte</button>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <table class="table table-bordered table-sm table-striped">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in reportData" :key="idx">
            <td v-for="col in columns" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="reportData && !reportData.length">
      <div class="alert alert-warning">No hay datos para mostrar.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReportesExecPage',
  data() {
    return {
      reportType: '1',
      noExclusivo: '',
      reportData: null,
      columns: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      let operation = '';
      let params = {};
      switch (this.reportType) {
        case '1':
          operation = 'get_reportes_exec';
          params = { order_by: 'clasificacion', group_by: 'no_exclusivo' };
          break;
        case '2':
          operation = 'get_reportes_exec';
          params = { order_by: 'clasificacion', group_by: 'propietario' };
          break;
        case '3':
          operation = 'get_adeudos_exec';
          break;
        case '4':
          operation = 'get_deudores_exec';
          break;
        case '5':
          if (!this.noExclusivo) {
            this.error = 'Debe ingresar el número de exclusivo.';
            this.loading = false;
            return;
          }
          operation = 'get_estado_cuenta';
          params = { no_exclusivo: this.noExclusivo };
          break;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation,
              params
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.reportData = data.eResponse.data;
          this.columns = this.reportData && this.reportData.length ? Object.keys(this.reportData[0]) : [];
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.reportes-exec-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
