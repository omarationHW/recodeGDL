<template>
  <div class="radeudos-opcmult-page">
    <h1>Opción Múltiple - Adeudos</h1>
    <div class="breadcrumb">Inicio / Adeudos / Opción Múltiple</div>
    <div class="form-section">
      <fieldset>
        <legend>Control del local</legend>
        <label>Número:
          <input v-model="numero" maxlength="3" @keypress="onlyNumber($event)" />
        </label>
        <label>Letra:
          <input v-model="letra" maxlength="1" style="text-transform:uppercase" />
        </label>
        <button @click="buscarLocal">Buscar</button>
      </fieldset>
      <div v-if="local">
        <p><strong>Concesionario:</strong> {{ local.concesionario }}</p>
        <p><strong>Ubicación:</strong> {{ local.ubicacion }}</p>
        <p><strong>Superficie:</strong> {{ local.superficie }}</p>
        <p><strong>Licencia:</strong> {{ local.licencia }}</p>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
    </div>
    <div v-if="adeudos.length > 0" class="adeudos-section">
      <h2>Adeudos</h2>
      <table class="adeudos-table">
        <thead>
          <tr>
            <th></th>
            <th>Registro</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.registro">
            <td><input type="checkbox" v-model="selectedRows" :value="row" /></td>
            <td>{{ row.registro }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.importe }}</td>
            <td>{{ row.recargo }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="adeudos.length > 0" class="actions-section">
      <fieldset>
        <legend>Datos de operación</legend>
        <label>Fecha de Pago:
          <input type="date" v-model="fecha" />
        </label>
        <label>Recaudadora:
          <select v-model="id_rec">
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
          </select>
        </label>
        <label>Caja:
          <select v-model="caja">
            <option v-for="c in cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
          </select>
        </label>
        <label>Consec. de Oper.:
          <input v-model="consec" maxlength="7" @keypress="onlyNumber($event)" />
        </label>
        <label>Folio del Rcbo:
          <input v-model="folio_rcbo" maxlength="20" />
        </label>
        <label>Opción a Realizar:
          <select v-model="status">
            <option value="P">P - DAR DE PAGADO</option>
            <option value="S">S - CONDONAR</option>
            <option value="C">C - CANCELAR</option>
            <option value="R">R - PRESCRIBIR</option>
          </select>
        </label>
        <button @click="ejecutarOpcion" :disabled="selectedRows.length === 0">Ejecutar</button>
      </fieldset>
      <div v-if="resultMsg" class="result-msg">{{ resultMsg }}</div>
    </div>
    <button @click="goBack">Salir</button>
  </div>
</template>

<script>
export default {
  name: 'RAdeudosOpcMultPage',
  data() {
    return {
      numero: '',
      letra: '',
      local: null,
      adeudos: [],
      selectedRows: [],
      fecha: new Date().toISOString().substr(0, 10),
      id_rec: '',
      caja: '',
      consec: '',
      folio_rcbo: '',
      status: 'P',
      opc: 'B',
      recaudadoras: [],
      cajas: [],
      error: '',
      resultMsg: ''
    };
  },
  created() {
    this.loadRecaudadoras();
    this.loadCajas();
  },
  methods: {
    onlyNumber(e) {
      if (!/[0-9]/.test(e.key)) e.preventDefault();
    },
    async buscarLocal() {
      this.error = '';
      this.local = null;
      this.adeudos = [];
      this.selectedRows = [];
      if (!this.numero) {
        this.error = 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo';
        return;
      }
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'search_local',
            params: { numero: this.numero, letra: this.letra }
          }
        })
      });
      const data = await resp.json();
      if (data.eResponse && data.eResponse.local) {
        this.local = data.eResponse.local;
        this.loadAdeudos(this.local.id_34_datos);
      } else {
        this.error = data.eResponse.error || 'Error al buscar local';
      }
    },
    async loadAdeudos(id_datos) {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'get_adeudos',
            params: { id_datos }
          }
        })
      });
      const data = await resp.json();
      this.adeudos = data.eResponse.adeudos || [];
    },
    async loadRecaudadoras() {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'get_recaudadoras', params: {} }
        })
      });
      const data = await resp.json();
      this.recaudadoras = data.eResponse.recaudadoras || [];
      if (this.recaudadoras.length > 0) this.id_rec = this.recaudadoras[0].id_rec;
    },
    async loadCajas() {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'get_cajas', params: {} }
        })
      });
      const data = await resp.json();
      this.cajas = data.eResponse.cajas || [];
      if (this.cajas.length > 0) this.caja = this.cajas[0].caja;
    },
    async ejecutarOpcion() {
      if (!this.selectedRows.length) {
        this.resultMsg = 'Debe seleccionar al menos un adeudo.';
        return;
      }
      const selected = this.selectedRows.map(row => ({
        registro: row.registro,
        axo: row.axo,
        mes: row.mes
      }));
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'execute_opc',
            params: {
              id_datos: this.local.id_34_datos,
              selected,
              fecha: this.fecha,
              id_rec: this.id_rec,
              caja: this.caja,
              consec: this.consec,
              folio_rcbo: this.folio_rcbo,
              status: this.status,
              opc: this.opc
            }
          }
        })
      });
      const data = await resp.json();
      if (data.eResponse.success) {
        this.resultMsg = 'Operación realizada correctamente.';
        this.loadAdeudos(this.local.id_34_datos);
      } else {
        this.resultMsg = data.eResponse.error || 'Error en la operación.';
      }
    },
    goBack() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.radeudos-opcmult-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 1em;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1em;
}
.form-section, .actions-section {
  margin-bottom: 1.5em;
}
.adeudos-table {
  width: 100%;
  border-collapse: collapse;
}
.adeudos-table th, .adeudos-table td {
  border: 1px solid #ccc;
  padding: 0.3em 0.5em;
}
.error {
  color: red;
  margin-top: 0.5em;
}
.result-msg {
  margin-top: 1em;
  color: green;
}
</style>
