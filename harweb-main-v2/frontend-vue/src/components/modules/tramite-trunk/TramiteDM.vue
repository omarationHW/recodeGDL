<template>
  <div class="tramite-dm-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Trámite DM</li>
      </ol>
    </nav>
    <h1>Formulario de Trámite Patrimonial</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="folio">Folio</label>
        <input v-model="form.folio" type="number" class="form-control" id="folio" required />
      </div>
      <div class="form-group">
        <label for="cvecuenta">Cuenta Catastral</label>
        <input v-model="form.cvecuenta" type="number" class="form-control" id="cvecuenta" required />
      </div>
      <div class="form-group">
        <label for="porccoprop">Porcentaje Copropiedad</label>
        <input v-model="form.porccoprop" type="number" min="0" max="100" step="0.01" class="form-control" id="porccoprop" required />
      </div>
      <div class="form-group">
        <label for="rfc">RFC Adquiriente</label>
        <input v-model="form.rfc" type="text" class="form-control" id="rfc" required />
      </div>
      <div class="form-group">
        <label for="valortransm">Valor de la Transmisión</label>
        <input v-model="form.valortransm" type="number" min="0" step="0.01" class="form-control" id="valortransm" required />
      </div>
      <div class="form-group">
        <label for="porcbase">Porcentaje Base</label>
        <input v-model="form.porcbase" type="number" min="0" max="100" step="0.01" class="form-control" id="porcbase" required />
      </div>
      <div class="form-group">
        <label for="naturaleza">Naturaleza del Acto</label>
        <select v-model="form.naturaleza" class="form-control" id="naturaleza" required>
          <option v-for="n in catalogos.naturalezas" :key="n.idacto" :value="n.idacto">{{ n.descripcion }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="supterr">Superficie Terreno</label>
        <input v-model="form.supterr" type="number" min="0" step="0.01" class="form-control" id="supterr" />
      </div>
      <div class="form-group">
        <label for="fechaotorg">Fecha de Otorgamiento</label>
        <input v-model="form.fechaotorg" type="date" class="form-control" id="fechaotorg" />
      </div>
      <div class="form-group">
        <label for="fechafirma">Fecha de Firma</label>
        <input v-model="form.fechafirma" type="date" class="form-control" id="fechafirma" />
      </div>
      <div class="form-group">
        <label for="fechaadjudicacion">Fecha de Adjudicación</label>
        <input v-model="form.fechaadjudicacion" type="date" class="form-control" id="fechaadjudicacion" />
      </div>
      <div class="form-group">
        <label for="tasaemi">Tasa Emisión</label>
        <input v-model="form.tasaemi" type="number" min="0" step="0.00001" class="form-control" id="tasaemi" />
      </div>
      <div class="form-group">
        <label for="valfemi">Valor Fiscal Emisión</label>
        <input v-model="form.valfemi" type="number" min="0" step="0.01" class="form-control" id="valfemi" />
      </div>
      <div class="form-group">
        <label for="exento">Exento</label>
        <select v-model="form.exento" class="form-control" id="exento">
          <option value="N">No</option>
          <option value="S">Sí</option>
        </select>
      </div>
      <div class="form-group">
        <label for="tpreferencial">Tasa Preferencial</label>
        <select v-model="form.tpreferencial" class="form-control" id="tpreferencial">
          <option value="N">No</option>
          <option value="S">Sí</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary">Guardar</button>
      <button type="button" class="btn btn-secondary ml-2" @click="calcImpto">Calcular Impuesto</button>
    </form>
    <div v-if="impuestoResult" class="alert alert-info mt-4">
      <h4>Resultado del Cálculo de Impuesto</h4>
      <pre>{{ impuestoResult }}</pre>
    </div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-4">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'TramiteDMPage',
  data() {
    return {
      form: {
        folio: '',
        cvecuenta: '',
        porccoprop: '',
        rfc: '',
        valortransm: '',
        porcbase: '',
        naturaleza: '',
        supterr: '',
        fechaotorg: '',
        fechafirma: '',
        fechaadjudicacion: '',
        tasaemi: '',
        valfemi: '',
        exento: 'N',
        tpreferencial: 'N'
      },
      catalogos: {
        naturalezas: []
      },
      impuestoResult: null,
      error: '',
      success: ''
    }
  },
  created() {
    this.loadCatalogos();
  },
  methods: {
    async loadCatalogos() {
      // Cargar naturalezas de actos
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'getCatalogoNaturalezas', params: {} }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.catalogos.naturalezas = data.eResponse.data;
        }
      } catch (e) { /* ignore */ }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'saveAdquiriente', params: this.form }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.success = data.eResponse.message;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      }
    },
    async calcImpto() {
      this.impuestoResult = null;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'calcImptoTransPat', params: { folio: this.form.folio } }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.impuestoResult = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      }
    }
  }
}
</script>

<style scoped>
.tramite-dm-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
