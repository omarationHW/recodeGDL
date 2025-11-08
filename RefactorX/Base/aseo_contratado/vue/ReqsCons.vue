<template>
  <div class="reqs-cons-page">
    <h1>Consulta de Requerimientos</h1>
    <div class="breadcrumb">Inicio / Requerimientos</div>
    <div class="form-row">
      <label>Contrato:</label>
      <input v-model="contrato" maxlength="10" @keypress="onlyNumber($event)" />
      <label>Tipo de Aseo:</label>
      <select v-model="ctrolAseo">
        <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
          {{ t.ctrol_aseo.toString().padStart(3, '0') }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
        </option>
      </select>
      <button @click="buscar">Buscar</button>
      <button @click="reset">Limpiar</button>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="contratoData">
      <h2>Datos del Contrato</h2>
      <div>Status: <b>{{ contratoData.status_vigencia }}</b></div>
      <div v-if="apremios.length">
        <h3>Requerimientos</h3>
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Importe Multa</th>
              <th>Importe Recargo</th>
              <th>Importe Gastos</th>
              <th>Fecha Emisión</th>
              <th>Fecha Practicado</th>
              <th>Vigencia</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="a in apremios" :key="a.id_control" @click="selectApremio(a)" :class="{selected: selectedApremio && selectedApremio.id_control === a.id_control}">
              <td>{{ a.folio }}</td>
              <td>{{ a.importe_multa }}</td>
              <td>{{ a.importe_recargo }}</td>
              <td>{{ a.importe_gastos }}</td>
              <td>{{ formatDate(a.fecha_emision) }}</td>
              <td>{{ formatDate(a.fecha_practicado) }}</td>
              <td>{{ a.vigencia }}</td>
              <td><button @click.stop="showPago(a)">Pagar</button></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="selectedApremio">
        <h3>Periodos del Requerimiento (Folio {{ selectedApremio.folio }})</h3>
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Año</th>
              <th>Periodo</th>
              <th>Importe</th>
              <th>Recargos</th>
              <th>Cantidad</th>
              <th>Tipo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in periodosApremio" :key="p.id_control">
              <td>{{ p.ayo }}</td>
              <td>{{ p.periodo }}</td>
              <td>{{ p.importe }}</td>
              <td>{{ p.recargos }}</td>
              <td>{{ p.cantidad }}</td>
              <td>{{ p.tipo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="showPagoForm">
        <h3>Registrar Pago de Requerimiento</h3>
        <form @submit.prevent="ejecutarPago">
          <div class="form-row">
            <label>Fecha de Pago:</label>
            <input type="date" v-model="pago.fecha" required />
          </div>
          <div class="form-row">
            <label>Recaudadora:</label>
            <select v-model="pago.id_rec" required>
              <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec.toString().padStart(2,'0') }} - {{ r.recaudadora }}</option>
            </select>
            <label>Caja:</label>
            <input v-model="pago.caja" maxlength="2" required />
          </div>
          <div class="form-row">
            <label>Consec. Operación:</label>
            <input v-model="pago.operacion" type="number" min="1" required />
            <label>Folio Recibo:</label>
            <input v-model="pago.folio_rcbo" maxlength="15" required />
          </div>
          <div class="form-row">
            <label>Importe Gastos:</label>
            <input v-model="selectedApremio.importe_gastos" readonly />
          </div>
          <button type="submit">Ejecutar Pago</button>
          <button type="button" @click="showPagoForm=false">Cancelar</button>
        </form>
        <div v-if="pagoStatus" :class="{'success': pagoStatus==='ok', 'error': pagoStatus!=='ok'}">{{ pagoMsg }}</div>
      </div>
      <div v-if="convenio">
        <h4>Convenio: {{ convenio.convenio }}</h4>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReqsConsPage',
  data() {
    return {
      contrato: '',
      ctrolAseo: '',
      tiposAseo: [],
      recaudadoras: [],
      contratoData: null,
      apremios: [],
      selectedApremio: null,
      periodosApremio: [],
      convenio: null,
      error: '',
      showPagoForm: false,
      pago: {
        fecha: '',
        id_rec: '',
        caja: '',
        operacion: '',
        folio_rcbo: ''
      },
      pagoStatus: '',
      pagoMsg: ''
    }
  },
  created() {
    this.loadTipoAseo();
    this.loadRecaudadoras();
  },
  methods: {
    onlyNumber(e) {
      if (!/[0-9]/.test(e.key)) e.preventDefault();
    },
    formatDate(d) {
      if (!d) return '';
      return new Date(d).toLocaleDateString();
    },
    reset() {
      this.contrato = '';
      this.ctrolAseo = '';
      this.contratoData = null;
      this.apremios = [];
      this.selectedApremio = null;
      this.periodosApremio = [];
      this.convenio = null;
      this.error = '';
      this.showPagoForm = false;
    },
    async loadTipoAseo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getTipoAseo' })
      });
      const data = await res.json();
      if (data.status === 'ok') {
        this.tiposAseo = data.data;
        if (this.tiposAseo.length) this.ctrolAseo = this.tiposAseo[0].ctrol_aseo;
      }
    },
    async loadRecaudadoras() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getRecaudadoras' })
      });
      const data = await res.json();
      if (data.status === 'ok') {
        this.recaudadoras = data.data;
      }
    },
    async buscar() {
      this.error = '';
      this.contratoData = null;
      this.apremios = [];
      this.selectedApremio = null;
      this.periodosApremio = [];
      this.convenio = null;
      if (!this.contrato || !this.ctrolAseo) {
        this.error = 'Falta el dato del CONTRATO o Tipo de Aseo';
        return;
      }
      // Buscar contrato
      let res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'buscarContrato', params: { contrato: this.contrato, ctrol_aseo: this.ctrolAseo } })
      });
      let data = await res.json();
      if (data.status !== 'ok' || !data.data) {
        this.error = 'No existe contrato con este dato, intentalo de nuevo';
        return;
      }
      this.contratoData = data.data;
      // Buscar apremios
      res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'buscarApremios', params: { control_contrato: this.contratoData.control_contrato } })
      });
      data = await res.json();
      if (!data.data || !data.data.length) {
        this.error = 'Contrato sin Apremios';
        return;
      }
      this.apremios = data.data;
      // Buscar convenio si status_vigencia == 'N'
      if (this.contratoData.status_vigencia === 'N') {
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'buscarConvenio', params: { idlc: this.contratoData.control_contrato } })
        });
        data = await res.json();
        if (data.data) this.convenio = data.data;
      }
    },
    async selectApremio(a) {
      this.selectedApremio = a;
      // Buscar periodos
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'buscarPeriodosApremio', params: { id_apremio: a.id_control } })
      });
      const data = await res.json();
      this.periodosApremio = data.data || [];
    },
    showPago(a) {
      this.selectedApremio = a;
      this.showPagoForm = true;
      this.pago = {
        fecha: new Date().toISOString().substr(0,10),
        id_rec: this.recaudadoras.length ? this.recaudadoras[0].id_rec : '',
        caja: '',
        operacion: '',
        folio_rcbo: ''
      };
      this.pagoStatus = '';
      this.pagoMsg = '';
    },
    async ejecutarPago() {
      this.pagoStatus = '';
      this.pagoMsg = '';
      // Validar
      if (!this.pago.fecha || !this.pago.id_rec || !this.pago.caja || !this.pago.operacion || !this.pago.folio_rcbo) {
        this.pagoStatus = 'error';
        this.pagoMsg = 'Todos los campos son obligatorios';
        return;
      }
      // Ejecutar pago
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'ejecutarPagoApremio',
          params: {
            fecha: this.pago.fecha,
            id_rec: this.pago.id_rec,
            caja: this.pago.caja,
            operacion: this.pago.operacion,
            importe_gastos: this.selectedApremio.importe_gastos,
            id_control: this.selectedApremio.id_control
          }
        })
      });
      const data = await res.json();
      if (data.status === 'ok') {
        this.pagoStatus = 'ok';
        this.pagoMsg = 'Se dio de PAGADO correctamente el Apremio';
        this.showPagoForm = false;
        this.buscar();
      } else {
        this.pagoStatus = 'error';
        this.pagoMsg = data.message || 'Error al dar de PAGADO el apremio';
      }
    }
  }
}
</script>

<style scoped>
.reqs-cons-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.selected {
  background: #e0f7fa;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>
