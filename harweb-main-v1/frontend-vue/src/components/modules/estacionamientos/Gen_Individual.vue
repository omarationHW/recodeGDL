<template>
  <div class="gen-individual-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Generación de Folios Individuales</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Generación de Folios Individuales</div>
      <div class="card-body">
        <form @submit.prevent="onAdd">
          <div class="row mb-2">
            <div class="col-md-4">
              <label>Opción de búsqueda</label>
              <select v-model="form.opcion" class="form-control" @change="onOptionChange">
                <option :value="0">Por Placa</option>
                <option :value="1">Por Placa y Folios</option>
                <option :value="2">Por Año y Folios</option>
              </select>
            </div>
            <div class="col-md-2" v-if="showPlaca">
              <label>Placa</label>
              <input v-model="form.placa" maxlength="7" class="form-control text-uppercase" />
            </div>
            <div class="col-md-2" v-if="showAxo">
              <label>Año</label>
              <input v-model="form.axo" maxlength="4" class="form-control text-uppercase" />
            </div>
            <div class="col-md-2" v-if="showFolio">
              <label>Folio(s)</label>
              <input v-model="form.folio" maxlength="50" class="form-control text-uppercase" placeholder="Ej: 123,124" />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-primary">Añadir</button>
            </div>
          </div>
        </form>
        <div class="row mb-2">
          <div class="col-md-3">
            <label>Remesa</label>
            <input v-model="remesa" class="form-control" readonly />
          </div>
          <div class="col-md-3">
            <label>Pagos Normales</label>
            <input v-model="contadorPN" class="form-control" readonly />
          </div>
          <div class="col-md-3">
            <label>Cancelaciones</label>
            <input v-model="contadorCan" class="form-control" readonly />
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-12">
            <button class="btn btn-success mr-2" @click="onExecute" :disabled="!canExecute">Ejecutar</button>
            <button class="btn btn-info mr-2" @click="onGenerateFile" :disabled="!canGenerateFile">Generar Archivo</button>
            <button class="btn btn-secondary" @click="onConsult">Consultar</button>
            <button class="btn btn-danger float-right" @click="onExit">Salir</button>
          </div>
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Registros de la Remesa</div>
      <div class="card-body">
        <div v-if="loading" class="text-center my-3">
          <span class="spinner-border"></span> Cargando...
        </div>
        <table v-if="registros.length" class="table table-sm table-bordered">
          <thead>
            <tr>
              <th v-for="col in columns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in registros" :key="idx">
              <td v-for="col in columns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
        <div v-else class="text-muted">No hay registros para la remesa actual.</div>
      </div>
    </div>
    <a v-if="fileUrl" :href="fileUrl" download class="btn btn-outline-success mt-3">Descargar Archivo de Remesa</a>
  </div>
</template>

<script>
export default {
  name: 'GenIndividualPage',
  data() {
    return {
      form: {
        opcion: 0,
        placa: '',
        axo: '',
        folio: ''
      },
      remesa: '',
      nextRemesa: 0,
      fechaInicio: '',
      fechaFin: '',
      contadorPN: 0,
      contadorCan: 0,
      registros: [],
      columns: [],
      loading: false,
      canExecute: false,
      canGenerateFile: false,
      fileUrl: ''
    };
  },
  computed: {
    showPlaca() {
      return this.form.opcion === 0 || this.form.opcion === 1;
    },
    showAxo() {
      return this.form.opcion === 2;
    },
    showFolio() {
      return this.form.opcion === 1 || this.form.opcion === 2;
    }
  },
  mounted() {
    this.init();
  },
  methods: {
    async api(action, params = {}) {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action, params }
        });
        this.loading = false;
        return res.data.eResponse;
      } catch (e) {
        this.loading = false;
        alert(e.response?.data?.eResponse?.message || e.message);
        return null;
      }
    },
    async init() {
      const resp = await this.api('init');
      if (resp && resp.success) {
        this.nextRemesa = resp.data.next_remesa;
        this.remesa = 'ayt_gdl_r' + this.nextRemesa;
        this.fechaInicio = resp.data.fecha_inicio;
        this.fechaFin = resp.data.fecha_fin;
        this.consultRemesa();
      }
    },
    onOptionChange() {
      this.form.placa = '';
      this.form.axo = '';
      this.form.folio = '';
    },
    async onAdd() {
      // Validación básica
      if (this.form.opcion === 0 && !this.form.placa) {
        alert('Falta el dato de la Placa.');
        return;
      }
      if (this.form.opcion === 1 && (!this.form.placa || !this.form.folio)) {
        alert('Falta el dato de la Placa o el(los) Folio(s).');
        return;
      }
      if (this.form.opcion === 2 && (!this.form.axo || !this.form.folio)) {
        alert('Falta el dato del Año o el(los) Folio(s).');
        return;
      }
      const resp = await this.api('add', {
        opcion: this.form.opcion,
        placa: this.form.placa,
        axo: this.form.axo,
        folio: this.form.folio,
        remesa: this.remesa
      });
      if (resp && resp.success) {
        this.consultRemesa();
      }
    },
    async onExecute() {
      const resp = await this.api('execute', { remesa: this.remesa });
      if (resp && resp.success) {
        this.consultRemesa();
      }
    },
    async onGenerateFile() {
      const resp = await this.api('generate_file', { remesa: this.remesa });
      if (resp && resp.success) {
        this.fileUrl = resp.url;
        alert('Archivo generado. Puede descargarlo ahora.');
      }
    },
    async onConsult() {
      this.consultRemesa();
    },
    async consultRemesa() {
      const resp = await this.api('consult', { remesa: this.remesa });
      if (resp && resp.success) {
        this.registros = resp.data || [];
        this.columns = this.registros.length ? Object.keys(this.registros[0]) : [];
        // Contadores
        this.contadorPN = this.registros.filter(r => r.tipoact === 'PN').length;
        this.contadorCan = this.registros.filter(r => r.tipoact === 'C').length;
        this.canExecute = this.registros.length > 0;
        this.canGenerateFile = this.registros.length > 0;
      } else {
        this.registros = [];
        this.columns = [];
        this.canExecute = false;
        this.canGenerateFile = false;
      }
    },
    onExit() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.gen-individual-page {
  max-width: 1200px;
  margin: 0 auto;
}
.text-uppercase {
  text-transform: uppercase;
}
</style>
