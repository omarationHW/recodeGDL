<template>
  <div class="prepago-page">
    <h1>Liquidación de Predial - Prepago</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <section class="contribuyente-info">
        <h2>Contribuyente</h2>
        <div><strong>Nombre:</strong> {{ resumen.ncompleto }}</div>
        <div><strong>Calle:</strong> {{ resumen.calle }} {{ resumen.noexterior }} {{ resumen.interior }}</div>
      </section>
      <section class="ubicacion-info">
        <h2>Ubicación del Predio</h2>
        <div><strong>Calle:</strong> {{ resumen.ubicacion_calle }} {{ resumen.ubicacion_noexterior }} {{ resumen.ubicacion_interior }}</div>
      </section>
      <section class="periodos">
        <h2>Periodos de Adeudo</h2>
        <table class="table table-sm">
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
            <tr v-for="p in periodos" :key="p.inicio">
              <td>{{ p.inicio }}</td>
              <td>{{ p.fin }}</td>
              <td>{{ p.valfiscal | money }}</td>
              <td>{{ p.tasa }}</td>
              <td>{{ p.axosobre }}</td>
              <td>{{ p.recvir | money }}</td>
              <td>{{ p.total | money }}</td>
              <td>{{ p.impvir | money }}</td>
              <td>{{ p.impade | money }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="resumen-pago">
        <h2>Resumen de Pago</h2>
        <div><strong>Impuesto:</strong> {{ resumen.impppag | money }}</div>
        <div><strong>Recargos:</strong> {{ resumen.recppag | money }}</div>
        <div><strong>Gastos:</strong> {{ resumen.gasto | money }}</div>
        <div><strong>Multa:</strong> {{ resumen.multa | money }}</div>
        <div><strong>Total a Pagar:</strong> <b>{{ resumen.total | money }}</b></div>
      </section>
      <section class="descuentos">
        <h2>
          <input type="checkbox" v-model="mostrarDescuentos" /> Mostrar descuentos
        </h2>
        <table v-if="mostrarDescuentos" class="table table-sm">
          <thead>
            <tr>
              <th>Descuento</th>
              <th>Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="d in descuentos" :key="d.cvedescuento">
              <td>{{ d.descripcion }}</td>
              <td>{{ d.impdescto | money }}</td>
            </tr>
          </tbody>
        </table>
      </section>
      <section class="ult-requerimiento" v-if="ultimoReq">
        <h2>Último Requerimiento</h2>
        <div><strong>Folio:</strong> {{ ultimoReq.folioreq }}</div>
        <div><strong>Fecha Notificación:</strong> {{ ultimoReq.fecent }}</div>
        <div><strong>Periodo requerido:</strong> {{ ultimoReq.iniper }} al {{ ultimoReq.finper }}</div>
      </section>
      <section class="liquidacion-parcial">
        <h2>Liquidación Parcial</h2>
        <form @submit.prevent="onLiquidacionParcial">
          <label>Bimestre Final:
            <select v-model="bimFin">
              <option v-for="b in [1,2,3,4,5,6]" :key="b" :value="b">{{ b }}</option>
            </select>
          </label>
          <label>Año Final:
            <input type="number" v-model="axoFin" min="1970" max="2100" />
          </label>
          <button type="submit">Calcular Parcial</button>
        </form>
        <div v-if="parcial">
          <h3>Resumen Parcial</h3>
          <div><strong>Impuesto:</strong> {{ parcial.impppag | money }}</div>
          <div><strong>Recargos:</strong> {{ parcial.recppag | money }}</div>
          <div><strong>Gastos:</strong> {{ parcial.gasto | money }}</div>
          <div><strong>Multa:</strong> {{ parcial.multa | money }}</div>
          <div><strong>Total a Pagar:</strong> <b>{{ parcial.total | money }}</b></div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PrePagoPage',
  data() {
    return {
      loading: true,
      cvecuenta: null,
      resumen: {},
      periodos: [],
      descuentos: [],
      mostrarDescuentos: false,
      ultimoReq: null,
      bimFin: 6,
      axoFin: new Date().getFullYear(),
      parcial: null
    };
  },
  filters: {
    money(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  created() {
    // Suponiendo que el cvecuenta viene por ruta o props
    this.cvecuenta = this.$route.params.cvecuenta || 1;
    this.loadAll();
  },
  methods: {
    async loadAll() {
      this.loading = true;
      // Resumen
      let res = await this.api('getResumen', {cvecuenta: this.cvecuenta});
      this.resumen = res;
      // Periodos
      this.periodos = await this.api('getPeriodos', {cvecuenta: this.cvecuenta});
      // Descuentos
      this.descuentos = await this.api('getDescuentos', {cvecuenta: this.cvecuenta});
      // Último requerimiento
      this.ultimoReq = await this.api('getUltimoRequerimiento', {cvecuenta: this.cvecuenta});
      this.loading = false;
    },
    async onLiquidacionParcial() {
      this.parcial = await this.api('liquidacionParcial', {
        cvecuenta: this.cvecuenta,
        asalf: this.axoFin,
        bsalf: this.bimFin
      });
    },
    async api(operation, params) {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({eRequest: {operation, params}})
      });
      const data = await resp.json();
      return data.eResponse;
    }
  }
};
</script>

<style scoped>
.prepago-page { max-width: 900px; margin: 0 auto; padding: 2rem; }
.loading { font-size: 1.5rem; color: #888; }
section { margin-bottom: 2rem; }
table { width: 100%; border-collapse: collapse; }
th, td { border: 1px solid #ccc; padding: 0.3rem 0.5rem; }
th { background: #f0f0f0; }
</style>
