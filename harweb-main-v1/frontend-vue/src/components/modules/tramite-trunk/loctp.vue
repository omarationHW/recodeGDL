<template>
  <div class="loctp-page">
    <h1>Localización de Datos Registrales de Avisos Presentados para su Trámite</h1>
    <form @submit.prevent="buscarDatos">
      <div class="form-row">
        <label>Notaría</label>
        <input v-model="form.notaria" type="number" min="1" required />
        <label>Municipio</label>
        <select v-model="form.municipio" required>
          <option value="" disabled>Seleccione...</option>
          <option v-for="m in municipios" :key="m.cvemunicipio" :value="m.cvemunicipio">{{ m.municipio }}</option>
        </select>
        <label>Número de Escrituras</label>
        <input v-model="form.escrituras" type="number" min="1" required />
        <button type="submit">Buscar Datos</button>
        <button type="button" @click="limpiarCampos" :disabled="!busquedaRealizada">Limpiar Campos</button>
      </div>
    </form>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="detalle">
      <div class="detalle-row">
        <span><b>Recaudadora:</b> {{ detalle.recaud }}</span>
        <span><b>Sector:</b> {{ detalle.urbrus }}</span>
        <span><b>Cuenta:</b> {{ detalle.cuenta }}</span>
      </div>
    </div>
    <div v-if="actos.length">
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Fecha de Entrada</th>
            <th>Status</th>
            <th>Comprobante</th>
            <th>Año</th>
            <th>Fecha de Trámite</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in actos" :key="a.folio">
            <td>{{ a.feccap | fecha }}</td>
            <td>{{ statusLabel(a) }}</td>
            <td>{{ a.nocomp }}</td>
            <td>{{ a.axocomp }}</td>
            <td>{{ a.fectram | fecha }}</td>
            <td>
              <textarea v-model="a.documentosotros" @blur="guardarObservacion(a)" rows="2" style="width:100%"></textarea>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="busquedaRealizada">
      <p>No se localizó la escritura.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LocTPPage',
  data() {
    return {
      municipios: [],
      form: {
        notaria: '',
        municipio: '',
        escrituras: ''
      },
      actos: [],
      detalle: null,
      error: '',
      busquedaRealizada: false
    };
  },
  created() {
    this.cargarMunicipios();
  },
  methods: {
    async cargarMunicipios() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'municipios' } })
      });
      const data = await res.json();
      this.municipios = data.eResponse.municipios || [];
    },
    async buscarDatos() {
      this.error = '';
      this.busquedaRealizada = false;
      this.actos = [];
      this.detalle = null;
      if (!this.form.notaria || !this.form.municipio || !this.form.escrituras) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'search',
            params: {
              notaria: this.form.notaria,
              municipio: this.form.municipio,
              escrituras: this.form.escrituras
            }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.error) {
        this.error = data.eResponse.error;
        return;
      }
      this.actos = data.eResponse.actos || [];
      this.detalle = data.eResponse.detalle && data.eResponse.detalle[0] ? data.eResponse.detalle[0] : null;
      this.busquedaRealizada = true;
    },
    async guardarObservacion(acto) {
      if (!acto.folio) return;
      await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'update_observacion',
            params: {
              folio: acto.folio,
              observacion: acto.documentosotros
            }
          }
        })
      });
    },
    limpiarCampos() {
      this.form.notaria = '';
      this.form.municipio = '';
      this.form.escrituras = '';
      this.actos = [];
      this.detalle = null;
      this.busquedaRealizada = false;
      this.error = '';
    },
    statusLabel(a) {
      switch (a.status) {
        case 'D': return 'FALTA ADQUIRIENTE';
        case 'T': return 'O.K. P/AUTORIZAR';
        case 'A': return 'AUTORIZADO P/PAGO';
        case 'P': return 'PAGADO';
        case 'R':
          if (a.axocomp !== 9999) return 'APLICADO';
          if (a.axocomp === 9999 && a.nocomp === 999999) return 'RECHAZADO';
          return 'RECHAZADO';
        default: return a.status;
      }
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.loctp-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px #ccc;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1em;
  margin-bottom: 1em;
}
.detalle-row {
  margin-bottom: 1em;
  font-size: 1.1em;
}
.table {
  width: 100%;
  margin-top: 1em;
}
.error {
  color: red;
  margin-bottom: 1em;
}
</style>
