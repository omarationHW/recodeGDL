<template>
  <div class="individual-folio-page">
    <h1>Consulta por Folio de Apremios</h1>
    <div class="form-section">
      <form @submit.prevent="buscarFolio">
        <div class="form-row">
          <label for="aplicacion">Aplicación:</label>
          <select v-model="form.modulo" id="aplicacion" required>
            <option v-for="ap in aplicaciones" :key="ap.id" :value="ap.id">{{ ap.descripcion }}</option>
          </select>
        </div>
        <div class="form-row">
          <label for="recaudadora">Recaudadora:</label>
          <select v-model="form.recaudadora" id="recaudadora" required>
            <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.descripcion }}</option>
          </select>
        </div>
        <div class="form-row">
          <label for="folio">Folio:</label>
          <input type="number" v-model.number="form.folio" id="folio" required min="1" />
        </div>
        <div class="form-row">
          <button type="submit">Buscar</button>
        </div>
      </form>
    </div>
    <div v-if="error" class="error-message">{{ error }}</div>
    <div v-if="folioData" class="folio-data-section">
      <h2>Datos del Folio</h2>
      <table class="folio-table">
        <tr><th>Folio</th><td>{{ folioData.folio }}</td></tr>
        <tr><th>Aplicación</th><td>{{ folioData.modulo_desc }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ folioData.zona }}</td></tr>
        <tr><th>Referencia</th><td>{{ folioData.control_otr }}</td></tr>
        <tr><th>Diligencia</th><td>{{ folioData.dil_descrip }}</td></tr>
        <tr><th>Importe Adeudo</th><td>{{ folioData.importe_global | currency }}</td></tr>
        <tr><th>Importe Multa</th><td>{{ folioData.importe_multa | currency }}</td></tr>
        <tr><th>Importe Recargo</th><td>{{ folioData.importe_recargo | currency }}</td></tr>
        <tr><th>Importe Gastos</th><td>{{ folioData.importe_gastos | currency }}</td></tr>
        <tr><th>Importe Actualización</th><td>{{ folioData.importe_actualizacion | currency }}</td></tr>
        <tr><th>Fecha Emisión</th><td>{{ folioData.fecha_emision | date }}</td></tr>
        <tr><th>Clave Practicado</th><td>{{ folioData.pra_descrip }}</td></tr>
        <tr><th>Fecha Practicado</th><td>{{ folioData.fecha_practicado | date }}</td></tr>
        <tr><th>Ejecutor</th><td>{{ folioData.nombre_eje }}</td></tr>
        <tr><th>Observaciones</th><td>{{ folioData.observaciones }}</td></tr>
        <tr><th>Vigencia</th><td>{{ folioData.vig_descrip }}</td></tr>
      </table>
      <div class="related-data">
        <h3>Historia</h3>
        <table class="history-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Diligencia</th>
              <th>Importe</th>
              <th>Usuario</th>
              <th>Observaciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="h in historia" :key="h.id_control + '-' + h.fecha_actualiz">
              <td>{{ h.fecha_actualiz | date }}</td>
              <td>{{ h.diligencia }}</td>
              <td>{{ h.importe_global | currency }}</td>
              <td>{{ h.usuario }}</td>
              <td>{{ h.observaciones }}</td>
            </tr>
          </tbody>
        </table>
        <h3>Periodos</h3>
        <table class="periods-table">
          <thead>
            <tr>
              <th>Año</th>
              <th>Periodo</th>
              <th>Importe</th>
              <th>Recargos</th>
              <th>Cantidad</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in periodos" :key="p.id_control + '-' + p.ayo + '-' + p.periodo">
              <td>{{ p.ayo }}</td>
              <td>{{ p.periodo }}</td>
              <td>{{ p.importe | currency }}</td>
              <td>{{ p.recargos | currency }}</td>
              <td>{{ p.cantidad }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <button @click="resetForm">Buscar otro folio</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'IndividualFolioPage',
  data() {
    return {
      aplicaciones: [],
      recaudadoras: [],
      form: {
        modulo: '',
        recaudadora: '',
        folio: ''
      },
      folioData: null,
      historia: [],
      periodos: [],
      error: ''
    };
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      // Cargar aplicaciones
      const apResp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalogs', params: { catalog: 'aplicaciones' } } })
      });
      const apData = await apResp.json();
      this.aplicaciones = apData.eResponse.data.map(a => ({ id: a.id, descripcion: a.descripcion }));
      // Cargar recaudadoras
      const recResp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalogs', params: { catalog: 'recaudadoras' } } })
      });
      const recData = await recResp.json();
      this.recaudadoras = recData.eResponse.data.map(r => ({ id: r.id, descripcion: r.descripcion }));
    },
    async buscarFolio() {
      this.error = '';
      this.folioData = null;
      this.historia = [];
      this.periodos = [];
      // Buscar folio principal
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'search', params: this.form } })
      });
      const data = await resp.json();
      if (!data.eResponse.success) {
        this.error = data.eResponse.message;
        return;
      }
      this.folioData = data.eResponse.data;
      // Historia
      const histResp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'history', params: { id_control: this.folioData.id_control } } })
      });
      const histData = await histResp.json();
      this.historia = histData.eResponse.data;
      // Periodos
      const perResp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'periods', params: { id_control: this.folioData.id_control } } })
      });
      const perData = await perResp.json();
      this.periodos = perData.eResponse.data;
    },
    resetForm() {
      this.folioData = null;
      this.historia = [];
      this.periodos = [];
      this.error = '';
      this.form.folio = '';
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString('es-MX');
    }
  }
};
</script>

<style scoped>
.individual-folio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 130px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  padding: 0.4rem;
  border-radius: 4px;
  border: 1px solid #ccc;
}
.folio-data-section {
  background: #fff;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.folio-table, .history-table, .periods-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1.5rem;
}
.folio-table th, .folio-table td,
.history-table th, .history-table td,
.periods-table th, .periods-table td {
  border: 1px solid #eee;
  padding: 0.5rem;
}
.folio-table th {
  background: #f0f0f0;
}
.related-data h3 {
  margin-top: 1.5rem;
}
.error-message {
  color: #b00;
  font-weight: bold;
  margin: 1rem 0;
}
</style>
