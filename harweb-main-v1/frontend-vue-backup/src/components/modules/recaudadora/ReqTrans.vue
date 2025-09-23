<template>
  <div class="reqtrans-page">
    <h1>Captura Requerimientos Transmisiones Patrimoniales</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Folio Requerimiento</label>
        <input v-model.number="form.folioreq" type="number" required />
      </div>
      <div class="form-row">
        <label>Tipo</label>
        <select v-model="form.tipo" required>
          <option value="N">Notificación</option>
          <option value="R">Requerimiento</option>
        </select>
      </div>
      <div class="form-row">
        <label>Cuenta Catastral</label>
        <input v-model.number="form.cvecta" type="number" required />
      </div>
      <div class="form-row">
        <label>Ejecutor</label>
        <select v-model.number="form.cveejec" required>
          <option v-for="ej in ejecutores" :key="ej.cveejecutor" :value="ej.cveejecutor">
            {{ ej.cveejecutor }} - {{ ej.nombres }} {{ ej.paterno }} {{ ej.materno }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Fecha Emisión</label>
        <input v-model="form.fecemi" type="date" required />
      </div>
      <div class="form-row">
        <label>Importe</label>
        <input v-model.number="form.importe" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Recargos</label>
        <input v-model.number="form.recargos" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Multas Extemporáneas</label>
        <input v-model.number="form.multas_ex" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Otras Multas</label>
        <input v-model.number="form.multas_otr" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Gastos</label>
        <input v-model.number="form.gastos" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Gastos Req.</label>
        <input v-model.number="form.gastos_req" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Total</label>
        <input v-model.number="form.total" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label>Observaciones</label>
        <textarea v-model="form.observ"></textarea>
      </div>
      <div class="form-row">
        <label>Usuario Actual</label>
        <input v-model="form.usu_act" type="text" required />
      </div>
      <div class="form-row">
        <button type="submit">Guardar</button>
        <button type="button" @click="resetForm">Limpiar</button>
      </div>
    </form>
    <hr />
    <h2>Buscar Requerimiento</h2>
    <form @submit.prevent="onSearch">
      <div class="form-row">
        <label>Folio Requerimiento</label>
        <input v-model.number="searchFolio" type="number" />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="searchResult">
      <h3>Resultado</h3>
      <pre>{{ searchResult }}</pre>
    </div>
    <hr />
    <h2>Catálogo de Ejecutores</h2>
    <ul>
      <li v-for="ej in ejecutores" :key="ej.cveejecutor">
        {{ ej.cveejecutor }} - {{ ej.nombres }} {{ ej.paterno }} {{ ej.materno }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'ReqTransPage',
  data() {
    return {
      form: {
        folioreq: '',
        tipo: 'N',
        cvecta: '',
        cveejec: '',
        fecemi: '',
        importe: 0,
        recargos: 0,
        multas_ex: 0,
        multas_otr: 0,
        gastos: 0,
        gastos_req: 0,
        total: 0,
        observ: '',
        usu_act: ''
      },
      ejecutores: [],
      searchFolio: '',
      searchResult: null
    }
  },
  created() {
    this.loadEjecutores();
  },
  methods: {
    async loadEjecutores() {
      // Llama al endpoint unificado para catálogo de ejecutores
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalog', table: 'ejecutor' } })
      });
      const data = await res.json();
      if (data.eResponse && data.eResponse.success) {
        this.ejecutores = data.eResponse.data;
      }
    },
    async onSubmit() {
      // Llama al endpoint unificado para crear
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'create', ...this.form } })
      });
      const data = await res.json();
      if (data.eResponse && data.eResponse.success) {
        alert('Registro guardado correctamente');
        this.resetForm();
      } else {
        alert('Error: ' + (data.eResponse.message || 'Error desconocido'));
      }
    },
    resetForm() {
      this.form = {
        folioreq: '',
        tipo: 'N',
        cvecta: '',
        cveejec: '',
        fecemi: '',
        importe: 0,
        recargos: 0,
        multas_ex: 0,
        multas_otr: 0,
        gastos: 0,
        gastos_req: 0,
        total: 0,
        observ: '',
        usu_act: ''
      };
    },
    async onSearch() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'list', folio: this.searchFolio } })
      });
      const data = await res.json();
      this.searchResult = data.eResponse.data;
    }
  }
}
</script>

<style scoped>
.reqtrans-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input, .form-row select, .form-row textarea {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  margin-right: 1rem;
}
</style>
