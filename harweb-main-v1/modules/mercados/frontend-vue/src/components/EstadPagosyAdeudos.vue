<template>
  <div class="estad-pagos-adeudos-page">
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span>Estadística de Pagos y Adeudos</span>
    </nav>
    <h1>Estadística de Pagos y Adeudos</h1>
    <form @submit.prevent="onConsultar">
      <div class="form-row">
        <label for="recaudadora">Recaudadora:</label>
        <select v-model="form.rec" id="recaudadora" required>
          <option v-for="r in recs" :key="r.id_rec" :value="r.id_rec">{{ r.recaudadora }}</option>
        </select>
      </div>
      <div class="form-row">
        <label for="axo">Año:</label>
        <input type="number" v-model.number="form.axo" id="axo" min="1995" max="2100" required />
        <label for="mes">Mes:</label>
        <input type="number" v-model.number="form.mes" id="mes" min="1" max="12" required />
      </div>
      <div class="form-row">
        <label for="fecdsd">Fecha Desde:</label>
        <input type="date" v-model="form.fecdsd" id="fecdsd" required />
        <label for="fechst">Fecha Hasta:</label>
        <input type="date" v-model="form.fechst" id="fechst" required />
      </div>
      <div class="form-row">
        <button type="submit">Consultar</button>
        <button type="button" @click="onExport">Exportar</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result && result.length">
      <h2>Resultados</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Mercado</th>
            <th>Nombre</th>
            <th>Locales Pagados</th>
            <th>Importe Pagado</th>
            <th>Periodos Pagados</th>
            <th>Locales Capturados</th>
            <th>Importe Capturado</th>
            <th>Periodos Capturados</th>
            <th>Locales con Adeudo</th>
            <th>Importe Adeudo</th>
            <th>Periodos Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.num_mercado_nvo">
            <td>{{ row.num_mercado_nvo }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.localpag }}</td>
            <td>{{ currency(row.pagospag) }}</td>
            <td>{{ row.periodospag }}</td>
            <td>{{ row.localcap }}</td>
            <td>{{ currency(row.pagoscap) }}</td>
            <td>{{ row.periodoscap }}</td>
            <td>{{ row.localade }}</td>
            <td>{{ currency(row.pagosade) }}</td>
            <td>{{ row.periodosade }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadPagosyAdeudosPage',
  data() {
    return {
      recs: [],
      form: {
        rec: '',
        axo: new Date().getFullYear(),
        mes: new Date().getMonth() + 1,
        fecdsd: '',
        fechst: ''
      },
      result: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchRecaudadoras();
    this.form.fecdsd = this.formatDate(new Date());
    this.form.fechst = this.formatDate(new Date());
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getRecaudadoras',
              params: {}
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.recs = data.eResponse.data;
          if (this.recs.length) this.form.rec = this.recs[0].id_rec;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onConsultar() {
      this.loading = true;
      this.error = '';
      this.result = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getEstadisticaPagosyAdeudos',
              params: {
                rec: this.form.rec,
                axo: this.form.axo,
                mes: this.form.mes,
                fecdsd: this.form.fecdsd,
                fechst: this.form.fechst
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.result = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    onExport() {
      alert('Funcionalidad de exportación no implementada en este ejemplo.');
    },
    formatDate(date) {
      const d = new Date(date);
      const month = '' + (d.getMonth() + 1).toString().padStart(2, '0');
      const day = '' + d.getDate().toString().padStart(2, '0');
      const year = d.getFullYear();
      return `${year}-${month}-${day}`;
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.estad-pagos-adeudos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.95em;
  color: #888;
  margin-bottom: 1rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  min-width: 120px;
  margin-right: 0.5rem;
}
.form-row input, .form-row select {
  margin-right: 1.5rem;
  padding: 0.3em 0.5em;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2rem;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5em 0.7em;
  text-align: right;
}
.result-table th {
  background: #f5f5f5;
  text-align: center;
}
.result-table td:first-child, .result-table th:first-child {
  text-align: center;
}
.result-table td:nth-child(2), .result-table th:nth-child(2) {
  text-align: left;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
}
</style>
