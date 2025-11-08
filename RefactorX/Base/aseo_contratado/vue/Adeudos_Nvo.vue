<template>
  <div class="adeudos-nvo-page">
    <h1>Estado de Cuenta de Contrato</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label for="contrato">Contrato</label>
        <input v-model="form.contrato" id="contrato" maxlength="10" required />
      </div>
      <div class="form-row">
        <label for="ctrol_aseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="ctrol_aseo" required>
          <option v-for="ta in tipoAseoOptions" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label for="vigencia">Vigencia</label>
        <select v-model="form.vigencia" id="vigencia">
          <option v-for="v in vigenciasOptions" :key="v.value" :value="v.value">{{ v.label }}</option>
        </select>
      </div>
      <div class="form-row" v-if="form.vigencia === 'O'">
        <label for="anio">Año</label>
        <input v-model="form.anio" id="anio" maxlength="4" required />
        <label for="mes">Mes</label>
        <select v-model="form.mes" id="mes">
          <option v-for="m in mesesOptions" :key="m.value" :value="m.value">{{ m.label }}</option>
        </select>
      </div>
      <div class="form-row">
        <button type="submit">Consultar Estado de Cuenta</button>
        <button type="button" @click="onPrint('concentrado')">Imprimir Concentrado</button>
        <button type="button" @click="onPrint('detalle')">Imprimir Detallado</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result && result.length">
      <h2>Resultado</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Adeudos</th>
            <th>Recargos</th>
            <th>Multa</th>
            <th>Gastos</th>
            <th>Actualización</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.concepto">
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe_adeudos }}</td>
            <td>{{ row.importe_recargos }}</td>
            <td>{{ row.importe_multa }}</td>
            <td>{{ row.importe_gastos }}</td>
            <td>{{ row.importe_act }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="printData">
      <h2>Vista Previa de Impresión ({{ printMode }})</h2>
      <pre>{{ printData }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosNvoPage',
  data() {
    return {
      form: {
        contrato: '',
        ctrol_aseo: '',
        vigencia: 'V',
        anio: '',
        mes: '01'
      },
      tipoAseoOptions: [],
      vigenciasOptions: [
        { value: 'V', label: 'Periodos Vencidos' },
        { value: 'O', label: 'Otro Periodo' }
      ],
      mesesOptions: [],
      loading: false,
      error: '',
      result: null,
      printData: null,
      printMode: ''
    };
  },
  created() {
    this.fetchTipoAseo();
    this.fetchMeses();
  },
  methods: {
    async fetchTipoAseo() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getTipoAseo' }
        });
        this.tipoAseoOptions = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error al cargar tipos de aseo';
      } finally {
        this.loading = false;
      }
    },
    async fetchMeses() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getMeses' }
        });
        this.mesesOptions = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error al cargar meses';
      }
    },
    async onSubmit() {
      this.error = '';
      this.result = null;
      this.loading = true;
      try {
        const params = {
          contrato: this.form.contrato,
          ctrol_aseo: this.form.ctrol_aseo,
          vigencia: this.form.vigencia,
          anio: this.form.anio,
          mes: this.form.mes
        };
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getEstadoCuenta', params }
        });
        if (res.data.eResponse.status === 'ok') {
          this.result = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error en la consulta';
      } finally {
        this.loading = false;
      }
    },
    async onPrint(mode) {
      this.printData = null;
      this.printMode = mode;
      this.loading = true;
      try {
        const params = {
          contrato: this.form.contrato,
          ctrol_aseo: this.form.ctrol_aseo,
          vigencia: this.form.vigencia,
          anio: this.form.anio,
          mes: this.form.mes
        };
        let action = mode === 'concentrado' ? 'getEstadoCuenta' : 'getEstadoCuentaDetallado';
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action, params }
        });
        if (res.data.eResponse.status === 'ok') {
          this.printData = JSON.stringify(res.data.eResponse.data, null, 2);
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al imprimir';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.adeudos-nvo-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 120px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  margin-right: 1rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2rem;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: right;
}
.result-table th {
  background: #f0f0f0;
}
.loading {
  color: #888;
  font-style: italic;
}
.error {
  color: red;
  font-weight: bold;
}
</style>
