<template>
  <div class="prepago-page">
    <h1>Prepago Predial</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Prepago
    </div>
    <form @submit.prevent="buscarCuenta">
      <label>Cuenta Catastral:</label>
      <input v-model="cvecuenta" required placeholder="Ingrese cuenta catastral" />
      <button type="submit">Buscar</button>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="cuenta">
      <h2>Datos del Contribuyente</h2>
      <p><strong>Nombre:</strong> {{ cuenta.ncompleto }}</p>
      <p><strong>Calle:</strong> {{ cuenta.calle }}</p>
      <p><strong>No. Exterior:</strong> {{ cuenta.noexterior }}</p>
      <p><strong>Interior:</strong> {{ cuenta.interior }}</p>
      <h3>Detalle de Adeudo</h3>
      <table class="table">
        <thead>
          <tr>
            <th>Desde</th>
            <th>Hasta</th>
            <th>Valor Fiscal</th>
            <th>Tasa</th>
            <th>ST</th>
            <th>Desc. Rec.</th>
            <th>Rec. a Pagar</th>
            <th>Desc. Imptos.</th>
            <th>Impto a Pagar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in detalle" :key="row.inicio">
            <td>{{ row.inicio }}</td>
            <td>{{ row.fin }}</td>
            <td>{{ row.valfiscal }}</td>
            <td>{{ row.tasa }}</td>
            <td>{{ row.axosobre }}</td>
            <td>{{ row.recvir }}</td>
            <td>{{ row.total }}</td>
            <td>{{ row.impvir }}</td>
            <td>{{ row.impade }}</td>
          </tr>
        </tbody>
      </table>
      <div class="totales">
        <div><strong>Impuesto:</strong> {{ totales.impppag }}</div>
        <div><strong>Recargos:</strong> {{ totales.recppag }}</div>
        <div><strong>Gastos:</strong> {{ totales.gasto }}</div>
        <div><strong>Multa:</strong> {{ totales.multa }}</div>
        <div><strong>Total:</strong> {{ totalPago }}</div>
      </div>
      <button @click="mostrarLiquidacionParcial = true">Liquidación Parcial</button>
      <button @click="mostrarDescuentos = !mostrarDescuentos">Mostrar Descuentos</button>
      <div v-if="mostrarDescuentos">
        <h4>Descuentos</h4>
        <table class="table">
          <thead>
            <tr><th>Descuento</th><th>Importe</th></tr>
          </thead>
          <tbody>
            <tr v-for="desc in descuentos" :key="desc.cvedescuento">
              <td>{{ desc.descripcion }}</td>
              <td>{{ desc.impdescto }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="ultimoReq">
        <h4>Último Requerimiento</h4>
        <p><strong>Folio:</strong> {{ ultimoReq.folioreq }}</p>
        <p><strong>Fecha Notificación:</strong> {{ ultimoReq.fecent }}</p>
        <p><strong>Periodo requerido:</strong> {{ ultimoReq.iniper }} al {{ ultimoReq.finper }}</p>
      </div>
      <div class="acciones">
        <button @click="recalcularDPP">Recalcular DPP</button>
        <button @click="eliminarDPP">Eliminar DPP</button>
        <button @click="calcularDescuentoPredial">Calcular Descuento Predial</button>
      </div>
    </div>
    <div v-if="mostrarLiquidacionParcial">
      <div class="modal">
        <h3>Liquidación Parcial</h3>
        <form @submit.prevent="liquidacionParcial">
          <label>Año Hasta:</label>
          <input v-model="liquidacion.asalf" type="number" min="1970" required />
          <label>Bimestre Hasta:</label>
          <input v-model="liquidacion.bsalf" type="number" min="1" max="6" required />
          <button type="submit">Calcular</button>
          <button type="button" @click="mostrarLiquidacionParcial = false">Cerrar</button>
        </form>
        <div v-if="liquidacionResult">
          <h4>Resultado</h4>
          <pre>{{ liquidacionResult }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PrepagoPage',
  data() {
    return {
      cvecuenta: '',
      cuenta: null,
      detalle: [],
      totales: {},
      descuentos: [],
      ultimoReq: null,
      mostrarDescuentos: false,
      mostrarLiquidacionParcial: false,
      liquidacion: { asalf: '', bsalf: '' },
      liquidacionResult: null,
      loading: false,
      error: '',
    };
  },
  computed: {
    totalPago() {
      let t = this.totales;
      return ((parseFloat(t.impppag)||0) + (parseFloat(t.recppag)||0) + (parseFloat(t.gasto)||0) + (parseFloat(t.multa)||0)).toFixed(2);
    }
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      this.cuenta = null;
      this.detalle = [];
      this.totales = {};
      this.descuentos = [];
      this.ultimoReq = null;
      try {
        let res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getPrepagoData', params: { cvecuenta: this.cvecuenta } }
        });
        if (res.data.eResponse.error) throw res.data.eResponse.error;
        this.cuenta = res.data.eResponse;
        // Detalle
        let det = await this.$axios.post('/api/execute', {
          eRequest: { action: 'liquidacionParcial', params: { cvecuenta: this.cvecuenta, asalf: new Date().getFullYear(), bsalf: 6 } }
        });
        this.detalle = det.data.eResponse.detalle || [];
        this.totales = det.data.eResponse.totales || {};
        // Descuentos
        let desc = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getDescuentos', params: { cvecuenta: this.cvecuenta } }
        });
        this.descuentos = desc.data.eResponse || [];
        // Último requerimiento
        let req = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getUltimoRequerimiento', params: { cvecuenta: this.cvecuenta } }
        });
        this.ultimoReq = req.data.eResponse;
      } catch (e) {
        this.error = e.toString();
      } finally {
        this.loading = false;
      }
    },
    async liquidacionParcial() {
      this.liquidacionResult = null;
      try {
        let res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'liquidacionParcial',
            params: {
              cvecuenta: this.cvecuenta,
              asalf: this.liquidacion.asalf,
              bsalf: this.liquidacion.bsalf
            }
          }
        });
        this.liquidacionResult = res.data.eResponse;
      } catch (e) {
        this.liquidacionResult = e.toString();
      }
    },
    async recalcularDPP() {
      try {
        let res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'recalcularDPP', params: { cvecuenta: this.cvecuenta } }
        });
        alert('Recalculo DPP: ' + JSON.stringify(res.data.eResponse));
      } catch (e) {
        alert('Error: ' + e.toString());
      }
    },
    async eliminarDPP() {
      try {
        let res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'eliminarDPP', params: { cvecuenta: this.cvecuenta } }
        });
        alert('Eliminación DPP: ' + JSON.stringify(res.data.eResponse));
      } catch (e) {
        alert('Error: ' + e.toString());
      }
    },
    async calcularDescuentoPredial() {
      try {
        let res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'calcularDescuentoPredial', params: { cvecuenta: this.cvecuenta } }
        });
        alert('Cálculo Descuento Predial: ' + JSON.stringify(res.data.eResponse));
      } catch (e) {
        alert('Error: ' + e.toString());
      }
    }
  }
}
</script>

<style scoped>
.prepago-page { max-width: 900px; margin: 0 auto; background: #fff; padding: 2rem; border-radius: 8px; }
.breadcrumb { margin-bottom: 1rem; }
.table { width: 100%; border-collapse: collapse; margin-bottom: 1rem; }
.table th, .table td { border: 1px solid #ccc; padding: 0.5rem; }
.totales { margin: 1rem 0; font-size: 1.1em; }
.acciones button { margin-right: 1rem; }
.error { color: red; }
.modal { background: #f9f9f9; border: 1px solid #ccc; padding: 1rem; position: fixed; top: 10%; left: 50%; transform: translateX(-50%); z-index: 1000; }
</style>
