<template>
  <div class="adeudos-edocta-page">
    <h1>Estado de Cuenta de Adeudos</h1>
    <form @submit.prevent="onProcesar">
      <div class="form-group">
        <label for="contrato">No. Contrato</label>
        <input v-model="form.contrato" id="contrato" type="text" maxlength="10" required />
      </div>
      <div class="form-group">
        <label for="tipoAseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="tipoAseo" required>
          <option v-for="ta in tipoAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label for="vigencia">Vigencia</label>
        <select v-model="form.vigencia" id="vigencia">
          <option value="V">Periodos Vigentes</option>
          <option value="A">Otro Periodo</option>
        </select>
      </div>
      <div class="form-group" v-if="form.vigencia === 'A'">
        <label for="ejercicio">Año</label>
        <input v-model="form.ejercicio" id="ejercicio" type="number" min="2000" max="2100" />
        <label for="mes">Mes</label>
        <select v-model="form.mes" id="mes">
          <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
        </select>
      </div>
      <button type="submit">Procesar</button>
    </form>

    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="resultados.length">
      <h2>Resultados</h2>
      <div v-for="res in resultados" :key="res.contrato.control_contrato" class="contrato-result">
        <h3>Contrato: {{ res.contrato.num_contrato }} - Empresa: {{ res.contrato.des_empresa }}</h3>
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Ejercicio</th>
              <th>Detalle</th>
              <th>Adeudos</th>
              <th>Recargos</th>
              <th>Multas</th>
              <th>Gastos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="dp in res.detPagos" :key="dp.ejercicio + '-' + dp.detalle">
              <td>{{ dp.ejercicio }}</td>
              <td>{{ dp.detalle }}</td>
              <td>{{ dp.importe_adeudos | currency }}</td>
              <td>{{ dp.importe_recargos | currency }}</td>
              <td>{{ dp.importe_multas | currency }}</td>
              <td>{{ dp.importe_gastos | currency }}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <th colspan="2">Totales</th>
              <th>{{ res.detPagosSum.total_adeudos | currency }}</th>
              <th>{{ res.detPagosSum.total_recargos | currency }}</th>
              <th></th>
              <th></th>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosEdoCtaPage',
  data() {
    return {
      tipoAseo: [],
      meses: [
        { value: '01', label: 'Enero' },
        { value: '02', label: 'Febrero' },
        { value: '03', label: 'Marzo' },
        { value: '04', label: 'Abril' },
        { value: '05', label: 'Mayo' },
        { value: '06', label: 'Junio' },
        { value: '07', label: 'Julio' },
        { value: '08', label: 'Agosto' },
        { value: '09', label: 'Septiembre' },
        { value: '10', label: 'Octubre' },
        { value: '11', label: 'Noviembre' },
        { value: '12', label: 'Diciembre' }
      ],
      form: {
        contrato: '',
        ctrol_aseo: '',
        vigencia: 'V',
        ejercicio: new Date().getFullYear(),
        mes: '01',
        tipo_periodo: 'V'
      },
      resultados: [],
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      return val;
    }
  },
  created() {
    this.init();
  },
  methods: {
    async init() {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'init' } })
      });
      const data = await resp.json();
      this.tipoAseo = data.eResponse.tipoAseo;
    },
    async onProcesar() {
      this.error = '';
      this.resultados = [];
      // Validación básica
      if (!this.form.contrato || !this.form.ctrol_aseo) {
        this.error = 'Debe capturar el contrato y tipo de aseo';
        return;
      }
      const params = {
        contrato: this.form.contrato,
        ctrol_aseo: this.form.ctrol_aseo,
        vigencia: this.form.vigencia,
        ejercicio: this.form.ejercicio,
        mes: this.form.mes,
        tipo_periodo: this.form.vigencia
      };
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'procesarAdeudos', params } })
      });
      const data = await resp.json();
      if (data.eResponse.error) {
        this.error = data.eResponse.error;
      } else {
        this.resultados = data.eResponse.resultados || [];
      }
    }
  }
};
</script>

<style scoped>
.adeudos-edocta-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-group {
  margin-bottom: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
</style>
