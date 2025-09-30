<template>
  <div class="aux-rep-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón de Concesionarios</li>
      </ol>
    </nav>
    <h2>{{ tablaNombre }}</h2>
    <div class="row mb-3">
      <div class="col-md-4">
        <label for="vigencia">Vigencia de la Concesión</label>
        <select v-model="vigencia" class="form-control" id="vigencia">
          <option value="TODOS">TODOS</option>
          <option v-for="v in vigencias" :key="v.descripcion" :value="v.descripcion">{{ v.descripcion }}</option>
        </select>
      </div>
      <div class="col-md-4 align-self-end">
        <button class="btn btn-primary mr-2" @click="fetchPadron">Buscar</button>
        <button class="btn btn-success" @click="printPadron">Imprimir</button>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <table v-if="padron.length" class="table table-bordered table-sm">
      <thead>
        <tr>
          <th>Control</th>
          <th>Concesionario</th>
          <th>Ubicación</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in padron" :key="row.control">
          <td>{{ row.control }}</td>
          <td>{{ row.concesionario }}</td>
          <td>{{ row.ubicacion }}</td>
        </tr>
      </tbody>
    </table>
    <div v-else-if="!loading">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'AuxRepPage',
  data() {
    return {
      tablaId: 3, // Por defecto, puede venir de ruta o props
      tablaNombre: '',
      vigencia: 'TODOS',
      vigencias: [],
      padron: [],
      etiquetas: {},
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchTablas();
    this.fetchEtiquetas();
    this.fetchVigencias();
    this.fetchPadron();
  },
  methods: {
    async apiRequest(action, params = {}) {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, params } })
        });
        const data = await res.json();
        if (data.eResponse && data.eResponse.error) throw new Error(data.eResponse.error);
        return data.eResponse;
      } catch (e) {
        this.error = e.message;
        return null;
      }
    },
    async fetchTablas() {
      const resp = await this.apiRequest('getTablas', { par_tab: this.tablaId });
      if (resp && resp.tablas && resp.tablas.length) {
        this.tablaNombre = resp.tablas[0].nombre;
      }
    },
    async fetchEtiquetas() {
      const resp = await this.apiRequest('getEtiquetas', { par_tab: this.tablaId });
      if (resp && resp.etiquetas && resp.etiquetas.length) {
        this.etiquetas = resp.etiquetas[0];
      }
    },
    async fetchVigencias() {
      const resp = await this.apiRequest('getVigencias', { par_tab: this.tablaId });
      if (resp && resp.vigencias) {
        this.vigencias = resp.vigencias;
      }
    },
    async fetchPadron() {
      this.loading = true;
      const resp = await this.apiRequest('getPadron', { par_tabla: this.tablaId, par_vigencia: this.vigencia });
      this.padron = (resp && resp.padron) ? resp.padron : [];
      this.loading = false;
    },
    async printPadron() {
      // Simulación: descarga CSV
      const resp = await this.apiRequest('printPadron', { par_tabla: this.tablaId, par_vigencia: this.vigencia });
      if (resp && resp.printData) {
        const csv = this.toCSV(resp.printData);
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'padron.csv';
        a.click();
        URL.revokeObjectURL(url);
      }
    },
    toCSV(rows) {
      if (!rows.length) return '';
      const headers = Object.keys(rows[0]);
      const csvRows = [headers.join(',')];
      for (const row of rows) {
        csvRows.push(headers.map(h => '"' + (row[h] ?? '') + '"').join(','));
      }
      return csvRows.join('\n');
    }
  }
};
</script>

<style scoped>
.aux-rep-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
