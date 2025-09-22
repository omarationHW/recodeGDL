<template>
  <div class="facturacion-page">
    <h1>Listado de Facturación</h1>
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit" class="mb-4">
      <div class="row">
        <div class="col-md-4">
          <label for="modulo">Aplicación</label>
          <select v-model="form.modulo" id="modulo" class="form-control" required>
            <option :value="11">Mercados</option>
            <option :value="16">Aseo</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="13">Cementerios</option>
          </select>
        </div>
        <div class="col-md-4">
          <label for="rec">Recaudadora</label>
          <select v-model="form.rec" id="rec" class="form-control" required>
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
          </select>
        </div>
      </div>
      <div class="row mt-3">
        <div class="col-md-2">
          <label for="fol1">Folio Desde</label>
          <input v-model.number="form.fol1" id="fol1" type="number" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label for="fol2">Folio Hasta</label>
          <input v-model.number="form.fol2" id="fol2" type="number" min="1" class="form-control" required />
        </div>
        <div class="col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Generar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="result && result.length">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Nombre</th>
            <th>Importe Global</th>
            <th>Importe Multa</th>
            <th>Importe Recargo</th>
            <th>Importe Gastos</th>
            <th>Fecha Emisión</th>
            <th>Vigencia</th>
            <!-- Agrega más columnas según el SP -->
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.importe_global | currency }}</td>
            <td>{{ row.importe_multa | currency }}</td>
            <td>{{ row.importe_recargo | currency }}</td>
            <td>{{ row.importe_gastos | currency }}</td>
            <td>{{ row.fecha_emision | date }}</td>
            <td>{{ row.vigencia }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-outline-secondary" @click="exportExcel">Exportar a Excel</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'FacturacionPage',
  data() {
    return {
      recaudadoras: [],
      form: {
        modulo: 11,
        rec: '',
        fol1: 1,
        fol2: 1
      },
      result: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    },
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString('es-MX');
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', { action: 'getRecaudadoras' });
        this.recaudadoras = res.data.data;
        if (this.recaudadoras.length) {
          this.form.rec = this.recaudadoras[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.error = '';
      if (this.form.fol1 > this.form.fol2) {
        this.error = 'El Folio Desde no puede ser mayor que el Folio Hasta';
        return;
      }
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'facturacionList',
          params: {
            modulo: this.form.modulo,
            rec: this.form.rec,
            fol1: this.form.fol1,
            fol2: this.form.fol2
          }
        });
        this.result = res.data.data;
      } catch (e) {
        this.error = e.response?.data?.error || 'Error al consultar facturación';
      } finally {
        this.loading = false;
      }
    },
    exportExcel() {
      // Implementa exportación a Excel (puedes usar SheetJS o similar)
      alert('Funcionalidad de exportación a Excel no implementada en este ejemplo.');
    }
  }
};
</script>

<style scoped>
.facturacion-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
