<template>
  <div class="cuenta-publica-page">
    <h1>Estadísticas de Adeudos (Cuenta Pública)</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cuenta Pública</li>
      </ol>
    </nav>
    <div class="form-row mb-3">
      <div class="col-md-2">
        <label>Recaudadora</label>
        <select v-model="form.oficina" class="form-control">
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
      </div>
      <div class="col-md-2">
        <label>Año</label>
        <input type="number" v-model.number="form.axo" class="form-control" min="1992" max="2999" />
      </div>
      <div class="col-md-2">
        <label>Mes</label>
        <input type="number" v-model.number="form.periodo" class="form-control" min="1" max="12" />
      </div>
      <div class="col-md-2 align-self-end">
        <button class="btn btn-primary" @click="consultar">Consultar</button>
      </div>
      <div class="col-md-2 align-self-end">
        <button class="btn btn-secondary" @click="imprimir" :disabled="!estadAdeudo.length">Imprimir</button>
      </div>
    </div>
    <div class="row">
      <div class="col-md-6">
        <h5>Total por Mercado y Mes</h5>
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th>Ofn</th>
              <th>Mer</th>
              <th>Año</th>
              <th>Mes</th>
              <th>Total</th>
              <th>Importe Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in estadAdeudo" :key="row.oficina + '-' + row.num_mercado + '-' + row.axo + '-' + row.periodo">
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.total }}</td>
              <td>{{ currency(row.adeudo) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="col-md-6">
        <h5>Total Recaudadora y Mes</h5>
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th>Ofn</th>
              <th>Año</th>
              <th>Mes</th>
              <th>Total</th>
              <th>Importe Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in totalAdeudo" :key="row.oficina + '-' + row.axo + '-' + row.periodo">
              <td>{{ row.oficina }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.total }}</td>
              <td>{{ currency(row.adeudo) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="row mt-3">
      <div class="col-md-6">
        <div class="alert alert-info">
          <strong>Meses de Adeudo:</strong> {{ totalMeses }}
        </div>
      </div>
      <div class="col-md-6">
        <div class="alert alert-success">
          <strong>Importe de Adeudo:</strong> {{ currency(totalImporte) }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'CuentaPublicaPage',
  data() {
    const now = new Date();
    return {
      recaudadoras: [],
      form: {
        oficina: '',
        axo: now.getFullYear(),
        periodo: now.getMonth() + 1
      },
      estadAdeudo: [],
      totalAdeudo: [],
      loading: false
    };
  },
  computed: {
    totalMeses() {
      return this.estadAdeudo.reduce((acc, row) => acc + Number(row.total), 0);
    },
    totalImporte() {
      return this.estadAdeudo.reduce((acc, row) => acc + Number(row.adeudo), 0);
    }
  },
  methods: {
    currency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    async loadRecaudadoras() {
      const res = await axios.post('/api/execute', { action: 'getRecaudadoras' });
      if (res.data.success) {
        this.recaudadoras = res.data.data;
        if (!this.form.oficina && this.recaudadoras.length) {
          this.form.oficina = this.recaudadoras[0].id_rec;
        }
      }
    },
    async consultar() {
      this.loading = true;
      try {
        const [estad, total] = await Promise.all([
          axios.post('/api/execute', { action: 'getEstadAdeudo', params: this.form }),
          axios.post('/api/execute', { action: 'getTotalAdeudo', params: this.form })
        ]);
        this.estadAdeudo = estad.data.data || [];
        this.totalAdeudo = total.data.data || [];
      } finally {
        this.loading = false;
      }
    },
    async imprimir() {
      // Simula descarga de PDF/Excel, aquí solo muestra alerta
      const res = await axios.post('/api/execute', { action: 'getCuentaPublicaReport', params: this.form });
      if (res.data.success) {
        // Aquí deberías descargar el archivo generado por el backend
        alert('Reporte generado correctamente (simulado).');
      } else {
        alert('Error al generar reporte: ' + res.data.message);
      }
    }
  },
  mounted() {
    this.loadRecaudadoras();
  }
};
</script>

<style scoped>
.cuenta-publica-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
