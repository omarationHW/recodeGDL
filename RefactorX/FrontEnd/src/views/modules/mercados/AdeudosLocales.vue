<template>
  <div class="adeudos-locales-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos de Mercados</li>
      </ol>
    </nav>
    <h2>Reporte de Adeudos de Mercados</h2>
    <form @submit.prevent="fetchAdeudos">
      <div class="form-row align-items-end">
        <div class="form-group col-md-2">
          <label for="axo">Año</label>
          <input type="number" min="1992" max="2999" v-model.number="form.axo" class="form-control" id="axo" required>
        </div>
        <div class="form-group col-md-2">
          <label for="oficina">Oficina</label>
          <select v-model="form.oficina" class="form-control" id="oficina" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="periodo">Periodo</label>
          <input type="number" min="1" max="12" v-model.number="form.periodo" class="form-control" id="periodo" required>
        </div>
        <div class="form-group col-md-2">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
        <div class="form-group col-md-2">
          <button type="button" class="btn btn-success" @click="exportExcel" :disabled="!adeudos.length">Exportar Excel</button>
        </div>
        <div class="form-group col-md-2">
          <button type="button" class="btn btn-secondary" @click="printReport" :disabled="!adeudos.length">Imprimir</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="adeudos.length" class="table-responsive mt-3">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Control</th>
            <th>Rec.</th>
            <th>Merc.</th>
            <th>Cat.</th>
            <th>Sección</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Bloque</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Renta</th>
            <th>Adeudo</th>
            <th>Meses Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.id_local">
            <td>{{ row.id_local }}</td>
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ row.RentaCalc | currency }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>{{ row.meses }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosLocalesPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: '',
        periodo: new Date().getMonth() + 1
      },
      recaudadoras: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', { action: 'getRecaudadoras' });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) this.form.oficina = this.recaudadoras[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      }
    },
    async fetchAdeudos() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getAdeudosLocales',
          params: {
            axo: this.form.axo,
            oficina: this.form.oficina,
            periodo: this.form.periodo
          }
        });
        if (res.data.success) {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar adeudos';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // Puede ser una descarga directa o abrir un modal de progreso
      alert('Funcionalidad de exportación a Excel no implementada en demo.');
    },
    async printReport() {
      // Puede abrir una nueva ventana con el PDF generado
      alert('Funcionalidad de impresión no implementada en demo.');
    }
  }
};
</script>

<style scoped>
.adeudos-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
