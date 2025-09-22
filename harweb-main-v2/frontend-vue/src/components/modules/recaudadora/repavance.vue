<template>
  <div class="repavance-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Avance de Recaudación de Multas</li>
      </ol>
    </nav>
    <h1>Informe de Avance de Recaudación de Multas</h1>
    <form @submit.prevent="submitForm" class="mb-4">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="mes">Mes</label>
          <select v-model="form.mes" id="mes" class="form-control" required>
            <option v-for="(m, idx) in meses" :key="idx" :value="idx">{{ m }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="anio">Año</label>
          <input v-model.number="form.anio" type="number" id="anio" class="form-control" min="2000" max="2100" required />
        </div>
        <div class="form-group col-md-4">
          <label for="recaudadora_id">Recaudadora</label>
          <input v-model="form.recaudadora_id" type="text" id="recaudadora_id" class="form-control" required placeholder="ID de recaudadora" />
        </div>
        <div class="form-group col-md-3">
          <label for="tipo">Tipo</label>
          <select v-model="form.tipo" id="tipo" class="form-control" required>
            <option value="M">Municipal</option>
            <option value="F">Federal</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Generar Reporte</button>
    </form>

    <div v-if="loading" class="alert alert-info">Generando reporte...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="report">
      <h2>Resumen</h2>
      <div class="mb-3">
        <strong>Mes:</strong> {{ meses[form.mes] }}<br />
        <strong>Año:</strong> {{ form.anio }}<br />
        <strong>Recaudadora:</strong> {{ form.recaudadora_id }}<br />
        <strong>Tipo:</strong> {{ form.tipo === 'M' ? 'Municipal' : 'Federal' }}
      </div>
      <h3>Detalle por Dependencia</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Dependencia</th>
            <th>Actas (cuantos1)</th>
            <th>Importe (total1)</th>
            <th>Actas (cuantos2)</th>
            <th>Importe (total2)</th>
            <th>Actas (cuantos3)</th>
            <th>Importe (total3)</th>
            <th>Actas (cuantos4)</th>
            <th>Importe (total4)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report.detalle" :key="row.id_dependencia">
            <td>{{ row.descripcion }}</td>
            <td class="text-right">{{ row.cuantos1 }}</td>
            <td class="text-right">{{ currency(row.total1) }}</td>
            <td class="text-right">{{ row.cuantos2 }}</td>
            <td class="text-right">{{ currency(row.total2) }}</td>
            <td class="text-right">{{ row.cuantos3 }}</td>
            <td class="text-right">{{ currency(row.total3) }}</td>
            <td class="text-right">{{ row.cuantos4 }}</td>
            <td class="text-right">{{ currency(row.total4) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Total</th>
            <th class="text-right">{{ sum('cuantos1') }}</th>
            <th class="text-right">{{ currency(sum('total1')) }}</th>
            <th class="text-right">{{ sum('cuantos2') }}</th>
            <th class="text-right">{{ currency(sum('total2')) }}</th>
            <th class="text-right">{{ sum('cuantos3') }}</th>
            <th class="text-right">{{ currency(sum('total3')) }}</th>
            <th class="text-right">{{ sum('cuantos4') }}</th>
            <th class="text-right">{{ currency(sum('total4')) }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepAvancePage',
  data() {
    return {
      meses: [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ],
      form: {
        mes: new Date().getMonth(),
        anio: new Date().getFullYear(),
        recaudadora_id: '',
        tipo: 'M'
      },
      loading: false,
      error: '',
      report: null
    };
  },
  methods: {
    async submitForm() {
      this.loading = true;
      this.error = '';
      this.report = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'repavance_generate_report',
              params: {
                mes: this.form.mes,
                anio: this.form.anio,
                recaudadora_id: this.form.recaudadora_id,
                tipo: this.form.tipo
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data.report;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    sum(field) {
      if (!this.report || !this.report.detalle) return 0;
      return this.report.detalle.reduce((acc, row) => acc + (Number(row[field]) || 0), 0);
    }
  }
};
</script>

<style scoped>
.repavance-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
