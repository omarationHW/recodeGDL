<template>
  <div class="folio-report-page">
    <h1>Reportes de Folios</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes de Folios</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body">
        <div class="form-group mb-2">
          <label><input type="radio" v-model="mode" value="elaborados" /> Reporte de los folios elaborados</label>
          <label class="ms-3"><input type="radio" v-model="mode" value="capturados" /> Reporte de los folios capturados</label>
          <label class="ms-3"><input type="radio" v-model="mode" value="por_vigilante" /> Reporte de folios hechos por vigilante</label>
        </div>
        <div class="form-group mb-2" v-if="mode !== 'por_vigilante'">
          <input type="checkbox" id="chkVigilante" v-model="filtroVigilante" />
          <label for="chkVigilante">Todos vigilantes / uno solo</label>
        </div>
        <div class="form-group mb-2" v-if="filtroVigilante && mode !== 'por_vigilante'">
          <label for="inspectorSelect">Inspector:</label>
          <select id="inspectorSelect" v-model="vigila" class="form-select">
            <option v-for="insp in inspectors" :key="insp.id_esta_persona" :value="insp.id_esta_persona">
              {{ insp.inspector }}
            </option>
          </select>
        </div>
        <div class="form-group mb-2">
          <label for="fecha">Fecha:</label>
          <input type="date" id="fecha" v-model="fecha" class="form-control" />
        </div>
        <button class="btn btn-primary mt-2" @click="generarReporte">Generar Reporte</button>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reporte.length > 0">
      <h3>Resultado</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr v-if="mode === 'por_vigilante'">
            <th>Inspector</th>
            <th>Folios hechos</th>
          </tr>
          <tr v-else>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Fecha Folio</th>
            <th>Estado</th>
            <th>Infracción</th>
            <th>Tarifa</th>
            <th>Vigilante</th>
            <th>Inspector</th>
            <th>Descripción</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reporte" :key="row.folio || row.vigilante">
            <template v-if="mode === 'por_vigilante'">
              <td>{{ row.inspector }}</td>
              <td>{{ row.folios }}</td>
            </template>
            <template v-else>
              <td>{{ row.axo }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.placa }}</td>
              <td>{{ row.fecha_folio ? row.fecha_folio.substring(0,10) : '' }}</td>
              <td>{{ row.estado }}</td>
              <td>{{ row.infraccion }}</td>
              <td>{{ row.tarifa }}</td>
              <td>{{ row.vigilante }}</td>
              <td>{{ row.inspector }}</td>
              <td>{{ row.descripcion }}</td>
              <td>{{ row.usuario }}</td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FolioReportPage',
  data() {
    return {
      mode: 'elaborados',
      filtroVigilante: false,
      vigila: null,
      fecha: new Date().toISOString().substr(0, 10),
      inspectors: [],
      reporte: [],
      loading: false,
      error: ''
    };
  },
  mounted() {
    this.fetchInspectors();
  },
  methods: {
    async fetchInspectors() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'getInspectors' })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.inspectors = data.eResponse.data;
        }
      } catch (e) {
        this.error = 'Error cargando inspectores';
      }
    },
    async generarReporte() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      let eRequest = '';
      let params = {};
      if (this.mode === 'por_vigilante') {
        eRequest = 'getFoliosByInspector';
        params = { date: this.fecha };
      } else {
        eRequest = 'getFoliosReport';
        params = {
          date: this.fecha,
          vigila: this.filtroVigilante ? this.vigila : null,
          mode: this.mode
        };
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest, params })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.reporte = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error en el reporte';
        }
      } catch (e) {
        this.error = 'Error generando reporte';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.folio-report-page {
  max-width: 900px;
  margin: 0 auto;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
