<template>
  <div class="ligapago-page">
    <h1>Liga de Pago a Folio de Requerimiento</h1>
    <div class="breadcrumb">Inicio / Requerimientos / Liga de Pago</div>
    <div class="form-section">
      <label for="cvecuenta">Cuenta Catastral:</label>
      <input v-model="cvecuenta" type="number" id="cvecuenta" @change="onCuentaChange" />
      <span v-if="cuentaStatus.exento === 'S'" class="error">Cuenta exenta. No puede usar esta opción</span>
      <span v-if="cuentaStatus.vigente === 'C'" class="error">Cuenta cancelada. No puede usar esta opción</span>
    </div>
    <div v-if="pagos.length > 0" class="pagos-section">
      <h2>Pagos Disponibles</h2>
      <table class="pagos-table">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Caja</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.cvepago">
            <td>{{ pago.folio }}</td>
            <td>{{ pago.fecha }}</td>
            <td>{{ pago.importe }}</td>
            <td>{{ pago.caja }}</td>
            <td>
              <button @click="selectPago(pago)">Ligar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="selectedPago" class="ligar-section">
      <h2>Ligar Pago</h2>
      <form @submit.prevent="ligarPago">
        <div>
          <label>Folio de Pago:</label>
          <span>{{ selectedPago.folio }}</span>
        </div>
        <div>
          <label>Importe:</label>
          <span>{{ selectedPago.importe }}</span>
        </div>
        <div>
          <label>Tipo de Liga:</label>
          <select v-model="tipoLiga">
            <option value="2">Requerimiento Predial</option>
            <option value="22">Transmisión Patrimonial</option>
            <option value="33">Diferencia Transmisión</option>
          </select>
        </div>
        <div v-if="tipoLiga == 22 || tipoLiga == 33">
          <label>Folio de Transmisión/Diferencia:</label>
          <input v-model="folioTransmision" type="number" />
        </div>
        <div>
          <label>Usuario:</label>
          <input v-model="usuario" type="text" />
        </div>
        <div>
          <label>Fecha:</label>
          <input v-model="fecha" type="date" />
        </div>
        <button type="submit">Ligar Pago</button>
        <button type="button" @click="cancelarLigar">Cancelar</button>
      </form>
      <div v-if="ligarResult" class="ligar-result">
        <span v-if="ligarResult.success" class="success">Pago ligado correctamente</span>
        <span v-else class="error">{{ ligarResult.message }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LigaPagoPage',
  data() {
    return {
      cvecuenta: '',
      pagos: [],
      selectedPago: null,
      tipoLiga: 2,
      folioTransmision: '',
      usuario: '',
      fecha: '',
      ligarResult: null,
      cuentaStatus: {},
    };
  },
  methods: {
    async onCuentaChange() {
      this.selectedPago = null;
      this.ligarResult = null;
      this.cuentaStatus = {};
      if (!this.cvecuenta) return;
      // Consultar estado de cuenta
      const statusResp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'getCuentaStatus',
          params: { cvecuenta: this.cvecuenta }
        })
      });
      const statusData = await statusResp.json();
      if (statusData.success && statusData.data.length > 0) {
        this.cuentaStatus = statusData.data[0];
        if (this.cuentaStatus.exento === 'S' || this.cuentaStatus.vigente === 'C') {
          this.pagos = [];
          return;
        }
      }
      // Consultar pagos
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'listPagos',
          params: { cvecuenta: this.cvecuenta }
        })
      });
      const data = await resp.json();
      if (data.success) {
        this.pagos = data.data;
      } else {
        this.pagos = [];
      }
    },
    selectPago(pago) {
      this.selectedPago = pago;
      this.ligarResult = null;
      this.tipoLiga = 2;
      this.folioTransmision = '';
      this.usuario = '';
      this.fecha = new Date().toISOString().substr(0, 10);
    },
    async ligarPago() {
      let action = 'ligarPago';
      let params = {
        cvepago: this.selectedPago.cvepago,
        cvecuenta: this.cvecuenta,
        usuario: this.usuario,
        tipo: this.tipoLiga,
        folio: this.folioTransmision || null,
        fecha: this.fecha
      };
      if (this.tipoLiga == 33) {
        action = 'ligarPagoDiferencia';
      }
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      const data = await resp.json();
      this.ligarResult = data;
      if (data.success) {
        this.selectedPago = null;
        this.onCuentaChange();
      }
    },
    cancelarLigar() {
      this.selectedPago = null;
      this.ligarResult = null;
    }
  }
};
</script>

<style scoped>
.ligapago-page { max-width: 900px; margin: 0 auto; padding: 2rem; }
.breadcrumb { font-size: 0.9rem; color: #888; margin-bottom: 1rem; }
.form-section { margin-bottom: 2rem; }
.pagos-table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
.pagos-table th, .pagos-table td { border: 1px solid #ccc; padding: 0.5rem; }
.pagos-table th { background: #f5f5f5; }
.ligar-section { background: #f9f9f9; padding: 1rem; border-radius: 4px; }
.error { color: #c00; font-weight: bold; }
.success { color: #090; font-weight: bold; }
</style>
