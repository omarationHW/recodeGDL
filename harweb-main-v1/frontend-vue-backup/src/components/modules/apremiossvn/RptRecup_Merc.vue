<template>
  <div class="rptrecup-merc-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Orden de Requerimiento de Pago y Embargo (Mercados)</li>
      </ol>
    </nav>
    <h2>Orden de Requerimiento de Pago y Embargo - Mercados</h2>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="ofna">Oficina (Zona)</label>
          <input type="number" v-model="form.ofna" class="form-control" id="ofna" required>
        </div>
        <div class="form-group col-md-3">
          <label for="folio1">Folio Inicial</label>
          <input type="number" v-model="form.folio1" class="form-control" id="folio1" required>
        </div>
        <div class="form-group col-md-3">
          <label for="folio2">Folio Final</label>
          <input type="number" v-model="form.folio2" class="form-control" id="folio2" required>
        </div>
        <div class="form-group col-md-3 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="reportData.length" class="mt-4">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Mercado</th>
            <th>Contribuyente</th>
            <th>Local</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Multa</th>
            <th>Gastos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.local }}{{ row.letra_local }}</td>
            <td>{{ row.periodo }}/{{ row.ayo }}</td>
            <td>{{ formatCurrency(row.importe) }}</td>
            <td>{{ formatCurrency(row.recargos) }}</td>
            <td>{{ formatCurrency(row.importe_multa) }}</td>
            <td>{{ formatCurrency(row.importe_gastos) }}</td>
            <td>{{ formatCurrency(row.importe_global + row.importe_multa + row.importe_recargo + row.importe_gastos) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="printReport">Imprimir</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptRecupMercPage',
  data() {
    return {
      form: {
        ofna: '',
        folio1: '',
        folio2: ''
      },
      reportData: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RptRecup_Merc.getReport',
            params: {
              ofna: this.form.ofna,
              folio1: this.form.folio1,
              folio2: this.form.folio2
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse ? json.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    printReport() {
      window.print();
    }
  }
};
</script>

<style scoped>
.rptrecup-merc-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
@media print {
  .form-row, .btn, .breadcrumb {
    display: none !important;
  }
  .rptrecup-merc-page {
    padding: 0;
  }
}
</style>
