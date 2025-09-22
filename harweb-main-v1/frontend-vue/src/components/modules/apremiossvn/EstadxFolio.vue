<template>
  <div class="estadxfolio-page">
    <h1>Estadísticas por Folio</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadísticas por Folio</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchStats">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="modulo">Aplicación</label>
          <select v-model="form.modulo" class="form-control" id="modulo" required>
            <option :value="11">Mercados</option>
            <option :value="16">Aseo Contratado</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="14">Estacionómetros</option>
            <option :value="13">Cementerios</option>
          </select>
        </div>
        <div class="col-md-2">
          <label for="folio1">Folio Desde</label>
          <input v-model.number="form.fol1" type="number" min="1" class="form-control" id="folio1" required />
        </div>
        <div class="col-md-2">
          <label for="folio2">Folio Hasta</label>
          <input v-model.number="form.fol2" type="number" min="1" class="form-control" id="folio2" required />
        </div>
        <div class="col-md-3">
          <label for="rec">Recaudadora</label>
          <select v-model="form.rec" class="form-control" id="rec" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.recaudadora }}
            </option>
          </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button type="submit" class="btn btn-primary w-100">Generar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="stats.length">
      <table class="table table-bordered table-sm mt-4">
        <thead>
          <tr>
            <th>Vigencia</th>
            <th>Clave Practicado</th>
            <th>Cuantos</th>
            <th>Importe Pagado</th>
            <th>Importe Gastos</th>
            <th>Adeudo</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in stats" :key="row.vigencia + '-' + row.clave_practicado">
            <td>{{ row.vigencia_str }}</td>
            <td>{{ row.pract_str }}</td>
            <td>{{ row.cuantos }}</td>
            <td>{{ row.gastos_pago | currency }}</td>
            <td>{{ row.gastos_gasto | currency }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>{{ row.recargos | currency }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success mt-2" @click="exportExcel">Exportar a Excel</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadxFolioPage',
  data() {
    return {
      recaudadoras: [],
      form: {
        modulo: 11,
        rec: '',
        fol1: 1,
        fol2: 1
      },
      stats: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'estadxfolio.getRecaudadoras' }
        });
        this.recaudadoras = res.data.eResponse.data;
        if (this.recaudadoras.length) {
          this.form.rec = this.recaudadoras[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async fetchStats() {
      this.loading = true;
      this.error = '';
      this.stats = [];
      if (this.form.fol1 > this.form.fol2) {
        this.error = 'El folio hasta debe ser mayor o igual al folio desde.';
        this.loading = false;
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'estadxfolio.getStats',
            params: {
              modulo: this.form.modulo,
              rec: this.form.rec,
              fol1: this.form.fol1,
              fol2: this.form.fol2
            }
          }
        });
        this.stats = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error al obtener estadísticas';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // For demo, just re-use the stats data
      // In real app, trigger backend Excel generation and download
      alert('Funcionalidad de exportar a Excel no implementada en demo.');
    }
  }
};
</script>

<style scoped>
.estadxfolio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
