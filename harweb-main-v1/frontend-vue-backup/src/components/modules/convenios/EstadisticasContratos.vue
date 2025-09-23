<template>
  <div class="estadisticas-contratos-page">
    <h1>Estadísticas de Contratos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Estadísticas Contratos</li>
      </ol>
    </nav>
    <div class="row">
      <div class="col-md-4">
        <div class="card mb-3">
          <div class="card-header">Tipo de Listado</div>
          <div class="card-body">
            <div class="form-check">
              <input class="form-check-input" type="radio" id="estadistica" value="estadistica" v-model="tipoListado">
              <label class="form-check-label" for="estadistica">Estadística</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="recaudacion" value="recaudacion" v-model="tipoListado">
              <label class="form-check-label" for="recaudacion">Recaudación por Año Obra</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="adeudos" value="adeudos" v-model="tipoListado">
              <label class="form-check-label" for="adeudos">Adeudos Fecha Actual</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="periodo" value="periodo" v-model="tipoListado">
              <label class="form-check-label" for="periodo">Estadísticas por Periodo</label>
            </div>
          </div>
        </div>
        <div v-if="tipoListado === 'estadistica' || tipoListado === 'adeudos'">
          <div class="card mb-3">
            <div class="card-header">Fondo / Programa</div>
            <div class="card-body">
              <div class="form-check">
                <input class="form-check-input" type="radio" id="ramo33" value="16" v-model="fondo">
                <label class="form-check-label" for="ramo33">Ramo 33</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="directa" value="15" v-model="fondo">
                <label class="form-check-label" for="directa">Obra Directa</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="ramo26" value="11" v-model="fondo">
                <label class="form-check-label" for="ramo26">Ramo 26</label>
              </div>
            </div>
          </div>
        </div>
        <div v-if="tipoListado === 'estadistica' || tipoListado === 'adeudos' || tipoListado === 'periodo'">
          <div class="card mb-3">
            <div class="card-header">Año de Obra</div>
            <div class="card-body">
              <input type="number" class="form-control" v-model="anioObra" min="1900" max="2100" placeholder="Año de Obra">
            </div>
          </div>
        </div>
        <div v-if="tipoListado === 'periodo'">
          <div class="card mb-3">
            <div class="card-header">Adeudo mínimo</div>
            <div class="card-body">
              <input type="number" class="form-control" v-model="adeudoMin" min="0" step="0.01" placeholder="Adeudo mínimo">
              <div class="form-check mt-2">
                <input class="form-check-input" type="checkbox" id="detalle" v-model="detalle">
                <label class="form-check-label" for="detalle">Imprimir Detalle</label>
              </div>
            </div>
          </div>
        </div>
        <div v-if="tipoListado === 'recaudacion'">
          <div class="card mb-3">
            <div class="card-header">Rango de Fechas</div>
            <div class="card-body">
              <label>Desde</label>
              <input type="date" class="form-control mb-2" v-model="fechaDesde">
              <label>Hasta</label>
              <input type="date" class="form-control" v-model="fechaHasta">
              <div class="form-check mt-2">
                <input class="form-check-input" type="radio" id="cuenta_ing" value="cuenta_ing" v-model="clasificacion">
                <label class="form-check-label" for="cuenta_ing">Cuenta de Ingreso</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="alo_obra" value="alo_obra" v-model="clasificacion">
                <label class="form-check-label" for="alo_obra">Año de Obra</label>
              </div>
            </div>
          </div>
        </div>
        <button class="btn btn-primary w-100 mb-2" @click="ejecutar">Ejecutar</button>
        <button class="btn btn-success w-100 mb-2" @click="exportarExcel" :disabled="!resultados.length">Exportar a Excel</button>
      </div>
      <div class="col-md-8">
        <div v-if="loading" class="alert alert-info">Cargando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="resultados.length">
          <h4>Resultados</h4>
          <table class="table table-bordered table-sm table-hover">
            <thead>
              <tr>
                <th v-for="(col, idx) in columnas" :key="idx">{{ col }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in resultados" :key="idx">
                <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading">
          <div class="alert alert-secondary">No hay resultados para mostrar.</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EstadisticasContratosPage',
  data() {
    return {
      tipoListado: '',
      fondo: '',
      anioObra: '',
      adeudoMin: 0,
      detalle: false,
      fechaDesde: '',
      fechaHasta: '',
      clasificacion: '',
      resultados: [],
      columnas: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async ejecutar() {
      this.error = '';
      this.loading = true;
      this.resultados = [];
      this.columnas = [];
      let action = '';
      let params = {};
      if (this.tipoListado === 'estadistica') {
        action = 'getEstadisticasContratos';
        params = { anio_obra: this.anioObra, fondo: this.fondo };
      } else if (this.tipoListado === 'adeudos') {
        action = 'getAdeudosVencidos';
        params = { anio_obra: this.anioObra, fondo: this.fondo };
      } else if (this.tipoListado === 'recaudacion') {
        action = 'getRecaudacion';
        params = {
          fecha_desde: this.fechaDesde,
          fecha_hasta: this.fechaHasta,
          clasificacion: this.clasificacion
        };
      } else if (this.tipoListado === 'periodo') {
        action = 'getEstadisticasPeriodos';
        params = {
          anio_obra: this.anioObra,
          adeudo_min: this.adeudoMin,
          detalle: this.detalle
        };
      } else {
        this.error = 'Seleccione un tipo de listado.';
        this.loading = false;
        return;
      }
      try {
        const res = await axios.post('/api/execute', {
          eRequest: { action, params }
        });
        if (res.data.eResponse.success) {
          this.resultados = res.data.eResponse.data;
          if (this.resultados.length > 0) {
            this.columnas = Object.keys(this.resultados[0]);
          }
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Simple export to CSV for demo
      if (!this.resultados.length) return;
      const csvRows = [];
      csvRows.push(this.columnas.join(','));
      this.resultados.forEach(row => {
        csvRows.push(this.columnas.map(col => '"'+(row[col] ?? '')+'"').join(','));
      });
      const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'estadisticas_contratos.csv';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.estadisticas-contratos-page {
  padding: 2rem;
}
.card {
  margin-bottom: 1rem;
}
</style>
