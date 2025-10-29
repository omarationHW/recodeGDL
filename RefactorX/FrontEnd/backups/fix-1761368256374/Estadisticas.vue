<template>
  <div class="module-view">
    <h1>Estadísticas de Adeudos</h1>
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Estadísticas</h1>
        <p>Mercados - Estadísticas</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="row">
      <div class="col-md-4">
        <div class="card mb-3">
          <div class="municipal-card-header">Tipo Estadística</div>
          <div class="municipal-card-body">
            <div class="form-check">
              <input class="form-check-input" type="radio" id="tipo1" value="global" v-model="tipo" />
              <label class="form-check-label" for="tipo1">Todos los Adeudos</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="tipo2" value="importe" v-model="tipo" />
              <label class="form-check-label" for="tipo2">Adeudos ≥ Importe</label>
            </div>
            <div class="form-check">
              <input class="form-check-input" type="radio" id="tipo3" value="desglose" v-model="tipo" />
              <label class="form-check-label" for="tipo3">Desglose Adeudos ≥ Importe</label>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-8">
        <form @submit.prevent="consultar">
          <div class="row mb-2">
            <div class="col">
              <label for="year">Año</label>
              <input type="number" id="year" v-model.number="year" class="municipal-form-control" min="1992" max="2999" required />
            </div>
            <div class="col">
              <label for="month">Mes</label>
              <input type="number" id="month" v-model.number="month" class="municipal-form-control" min="1" max="12" required />
            </div>
            <div class="col" v-if="tipo !== 'global'">
              <label for="importe">Importe</label>
              <input type="number" id="importe" v-model.number="importe" class="municipal-form-control" min="0" step="0.01" required />
            </div>
          </div>
          <div class="mb-2">
            <button type="submit" class="btn-municipal-primary">Consultar</button>
            <button type="button" class="btn btn-success ms-2" @click="exportarExcel" :disabled="!resultados.length">Exportar Excel</button>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="resultados.length">
          <h5 class="mt-3">Resultados</h5>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead>
                <tr>
                  <th v-for="col in columnas" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultados" :key="idx">
                  <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EstadisticasPage',
  data() {
    const today = new Date();
    return {
      tipo: 'global',
      year: today.getFullYear(),
      month: today.getMonth() + 1,
      importe: 0,
      resultados: [],
      columnas: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async consultar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      let action = '';
      if (this.tipo === 'global') action = 'getEstadisticasGlobal';
      else if (this.tipo === 'importe') action = 'getEstadisticasImporte';
      else if (this.tipo === 'desglose') action = 'getDesgloceAdeudosPorImporte';
      try {
        const params = {
          year: this.year,
          month: this.month,
          importe: this.importe
        };
        const { data } = await axios.post('/api/execute', {
          action,
          params
        });
        if (data.success) {
          this.resultados = data.data;
          this.columnas = this.resultados.length ? Object.keys(this.resultados[0]) : [];
        } else {
          this.error = data.message || 'Error desconocido';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Exportar a CSV simple (puede integrarse con libs como xlsx)
      if (!this.resultados.length) return;
      const csvRows = [];
      csvRows.push(this.columnas.join(','));
      this.resultados.forEach(row => {
        csvRows.push(this.columnas.map(col => '"' + (row[col] ?? '') + '"').join(','));
      });
      const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `estadisticas_${this.tipo}_${this.year}_${this.month}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.estadisticas-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.card {
  box-shadow: 0 2px 8px #eee;
}
</style>
